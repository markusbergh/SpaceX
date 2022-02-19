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
            isLaunchSaved()
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
    func isLaunchSaved() {
        guard let jsonValue = launch?.id?.jsonValue else { return }
        
        do {
            let id = try String(jsonValue: jsonValue)
            
            withAnimation {
                isSaved = UserDefaults.standard.object(forKey: id) != nil
            }
        } catch {
            isSaved = false
        }
    }
    
    func toggleSave() {
        guard let launch = launch, let jsonValue = launch.id?.jsonValue else { return }

        guard !isSaved else {
            do {
                let id = try String(jsonValue: jsonValue)
    
                UserDefaults.standard.removeObject(forKey: id)
                
                isSaved = false
            } catch {
                // TODO: Handle error
            }
            
            return
        }
                
        do {
            let id = try String(jsonValue: jsonValue)
            let encodedLaunch = try NSKeyedArchiver.archivedData(withRootObject: launch.jsonObject, requiringSecureCoding: false)
            
            UserDefaults.standard.set(encodedLaunch, forKey: id)
            
            isSaved = true
        } catch {
            // TODO: Handle error
        }
    }
}

// MARK: - Actions

extension LaunchDetailViewModel {
    enum Action {
        case fetchLaunch(id: GraphQLID?)
    }

    func dispatch(action: Action) {
        switch action {
        case let .fetchLaunch(launchID):
            state = .pending

            Task {
                do {
                    let launch = try await fetchLaunch(id: launchID)
                    
                    DispatchQueue.main.async {
                        self.launch = launch
                        self.state = .success
                    }
                } catch {
                    // TODO: Handle error
                    assertionFailure("Error while fetching launch details")
                }
            }
        }
    }
}
