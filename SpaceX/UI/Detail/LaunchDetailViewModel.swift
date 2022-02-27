//
//  LaunchDetailViewModel.swift
//  SpaceX
//
//  Created by Markus Bergh on 2022-02-13.
//

import Foundation
import Apollo
import SwiftUI

typealias LaunchDetails = LaunchDetailsQuery.Data.Launch
typealias Rocket = LaunchDetailsQuery.Data.Launch.Rocket.Rocket

protocol LaunchDetailProvider {
    func fetchLaunch(id: GraphQLID?) async throws -> LaunchDetails
}

class LaunchDetailViewModel: ObservableObject, LaunchDetailProvider {
    enum State: Equatable {
        case idle
        case pending
        case error(Error)
        case success
    }
    
    enum Error: Swift.Error {
        case fetchDetailsError
    }
    
    /// Network layer
    private let network: Network
    
    /// Current launch detail
    @Published private(set) var launch: LaunchDetails? {
        didSet {
            checkSavedStatus()
        }
    }
    
    /// State of the view
    @Published private(set) var state: State = .idle
    
    /// Holder of saved launch
    @Published private(set) var isSaved = false
    
    /// Will return a formatted string if possible
    var formattedDate: String? {
        guard let launchDateString = launch?.launchDateUtc else {
            return nil
        }
        
        // Cannot use `ISO8601DateFormatter` because of less date style options
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"

        guard let launchDate = dateFormatter.date(from: launchDateString) else {
            return nil
        }
        
        // Update date style
        dateFormatter.dateStyle = .short
        
        return dateFormatter.string(from: launchDate)
    }
    
    /// Convenience getter for rocket height
    var rocketHeight: String? {
        guard let height = launch?.rocket?.rocket?.height?.meters else {
            return nil
        }
        
        return "\(height) m"
    }
    
    /// Convenience getter for rocket diameter
    var rocketDiameter: String? {
        guard let diameter = launch?.rocket?.rocket?.diameter?.meters else {
            return nil
        }
        
        return "\(diameter) m"
    }
    
    /// Convenience getter for rocket mass
    var rocketMass: String? {
        guard let mass = launch?.rocket?.rocket?.mass?.kg else {
            return nil
        }
        
        return "\(Int(round(Double(mass) / 1000))) tons"
    }
    
    init(network: Network = Network.shared) {
        self.network = network
    }

    /// Will fetch and return launch detail data based on id. Cannot be declared
    /// in an extension due to needed override for SwiftUI Previews mocks.
    ///
    ///- Parameter id: The `GraphQLID` to fetch details for.
    ///- Returns: A `LaunchDetailsQuery` result.
    func fetchLaunch(id: GraphQLID?) async throws -> LaunchDetails {
        guard let id = id else {
            throw Error.fetchDetailsError
        }
        
        do {
            let graphQLResult = try await network.fetchLaunch(with: id)
            
            guard let launch = graphQLResult.data?.launch else {
                throw Error.fetchDetailsError
            }
            
            return launch
        } catch {
            throw error
        }
    }
}

// MARK: Save favourite

extension LaunchDetailViewModel {
    
    private var savedLaunchesDefaultsKey: String {
        return "com.marber.SpaceX.saved-launches"
    }
    
    /// Will check if current launch is previously saved.
    func checkSavedStatus() {
        guard let launch = launch else { return }
        
        do {
            guard let previousSavedLaunches = UserDefaults.standard.array(forKey: savedLaunchesDefaultsKey) as? [Data] else {
                return
            }

            try previousSavedLaunches.forEach { data in
                guard let jsonObject = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? JSONObject else {
                    return
                }
                
                if try LaunchDetails(jsonObject: jsonObject).id == launch.id {
                    withAnimation {
                        isSaved = true
                    }
                    
                    return
                }
            }
        } catch {
            isSaved = false
        }
    }
    
    /// Will either save or unsave a launch from user defaults.
    private func toggleSave() {
        guard let launch = launch else { return }
        
        if !isSaved {
            save(launch: launch)
        } else {
            unsave(launch: launch)
        }
    }
    
    /// Will save a launch from user defaults.
    ///
    /// - Parameter launch: The actual launch to save.
    private func save(launch: LaunchDetails) {
        do {
            let encodedLaunch = try NSKeyedArchiver.archivedData(withRootObject: launch.jsonObject, requiringSecureCoding: false)
            
            if var previousSavedLaunches = UserDefaults.standard.array(forKey: savedLaunchesDefaultsKey) as? [Data] {
                // Removes any duplicates
                previousSavedLaunches = try previousSavedLaunches.filter { data in
                    let decodedLaunch = try decodedLaunch(for: data)
                    
                    if decodedLaunch?.id == launch.id {
                        return false
                    }
                    
                    return true
                }
                
                previousSavedLaunches.append(encodedLaunch)
                
                UserDefaults.standard.set(previousSavedLaunches, forKey: savedLaunchesDefaultsKey)
            } else {
                // No previous list, just save the item
                UserDefaults.standard.set([encodedLaunch], forKey: savedLaunchesDefaultsKey)
            }
                        
            isSaved = true
        } catch {
            // TODO: Handle error
        }
    }
    
    /// Will unsave a launch from user defaults.
    ///
    /// - Parameter launch: The actual launch to unsave.
    private func unsave(launch: LaunchDetails) {
        do {
            guard let previousSavedLaunches = UserDefaults.standard.array(forKey: savedLaunchesDefaultsKey) as? [Data] else {
                return
            }
            
            // Remove any matches
            let savedLaunches = try previousSavedLaunches.filter { data in
                let decodedLaunch = try decodedLaunch(for: data)
                
                if decodedLaunch?.id == launch.id {
                    return false
                }
                
                return true
            }

            // Update list
            UserDefaults.standard.set(savedLaunches, forKey: savedLaunchesDefaultsKey)
            
            isSaved = false
        } catch {
            // TODO: Handle error
        }
    }
    
    /// Will decode `Data` into `LaunchDetails` object.
    ///
    /// - Parameter data: Data holding launch details
    /// - Returns: An optional `LaunchDetails`.
    private func decodedLaunch(for data: Data) throws -> LaunchDetails? {
        guard let jsonObject = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? JSONObject else {
            return nil
        }
        
        return try LaunchDetails(jsonObject: jsonObject)
    }
}

// MARK: - Actions

extension LaunchDetailViewModel {
    enum Action {
        case toggleSave
        case fetchLaunch(id: GraphQLID?)
    }

    func dispatch(action: Action) {
        switch action {
        case let .fetchLaunch(id):
            state = .pending

            Task {
                do {
                    let launch = try await fetchLaunch(id: id)
                    
                    DispatchQueue.main.async {
                        self.launch = launch
                        self.state = .success
                    }
                } catch {
                    // TODO: Handle error
                    assertionFailure("Error while fetching launch details")
                }
            }
        case .toggleSave:
            toggleSave()
        }
    }
}
