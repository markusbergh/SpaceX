//
//  LaunchDetailViewModel.swift
//  SpaceX
//
//  Created by Markus Bergh on 2022-02-13.
//

import Foundation
import Apollo

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
    
    @Published private(set) var launch: LaunchDetails?
    
    @Published private(set) var state: State = .idle
    
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
    
    var rocketHeight: String? {
        guard let height = launch?.rocket?.rocket?.height?.meters else {
            return nil
        }
        
        return "\(height) m"
    }
    
    var rocketDiameter: String? {
        guard let diameter = launch?.rocket?.rocket?.diameter?.meters else {
            return nil
        }
        
        return "\(diameter) m"
    }
    
    var rocketMass: String? {
        guard let mass = launch?.rocket?.rocket?.mass?.kg else {
            return nil
        }
        
        return "\(Int(round(Double(mass) / 1000))) tons"
    }
    
    init(network: Network = Network.shared) {
        self.network = network
    }
    
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
