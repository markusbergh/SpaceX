//
//  LaunchDetailViewModel.swift
//  SpaceX
//
//  Created by Markus Bergh on 2022-02-13.
//

import Foundation
import Apollo

typealias LaunchDetails = LaunchDetailsQuery.Data.Launch

protocol LaunchDetailProvider {
    func fetchLaunch(id: GraphQLID?) async throws -> LaunchDetails
}

class LaunchDetailViewModel: ObservableObject, LaunchDetailProvider {
    enum Error: Swift.Error {
        case fetchDetailsError
    }
    
    /// Network layer
    private let network: Network
    
    @Published private(set) var launch: LaunchDetails?
    
    var formattedDate: String? {
        guard let launchDateString = launch?.launchDateUtc else {
            return nil
        }
        
        // Due to limitation with format options using `ISO8601DateFormatter`, a `DateFormatter` is used instead.
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"

        guard let launchDate = dateFormatter.date(from: launchDateString) else {
            return nil
        }
        
        // Update date style
        dateFormatter.dateStyle = .short
        
        return dateFormatter.string(from: launchDate)
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
        case fetchLaunch(launchID: GraphQLID?)
    }

    func dispatch(action: Action) {
        switch action {
        case let .fetchLaunch(launchID):
            Task {
                do {
                    let launch = try await fetchLaunch(id: launchID)
                    
                    DispatchQueue.main.async {
                        self.launch = launch
                    }
                } catch {
                    // TODO: Handle error
                    assertionFailure("Error while fetching launch details")
                }
            }
        }
    }
}
