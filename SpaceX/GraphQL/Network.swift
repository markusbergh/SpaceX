//
//  Network.swift
//  SpaceX
//
//  Created by Markus Bergh on 2022-02-13.
//

import Apollo
import Foundation

enum NetworkError: Error {
    case requestError(message: String)
}

extension NetworkError: Identifiable {
    var id: UUID {
        UUID()
    }
}

class Network {
    static let shared = Network()
    
    private var urlString = "https://apollo-fullstack-tutorial.herokuapp.com/graphql"
    private lazy var apollo = ApolloClient(url: URL(string: urlString)!)
}

// MARK: Public

extension Network {
    
    /// Will try and fetch all launches. Can throw an error.
    func fetchLaunches() async throws -> GraphQLResult<LaunchListQuery.Data> {
        try await withCheckedThrowingContinuation { continuation in
            apollo.fetch(query: LaunchListQuery()) { result in
                let errorMessage = "Something went wrong!"
                
                switch result {
                case let .success(graphQLResult):
                    guard graphQLResult.errors == nil else {
                        return continuation.resume(throwing: NetworkError.requestError(message: errorMessage))
                    }
                    
                    continuation.resume(returning: graphQLResult)
                case .failure:
                    continuation.resume(throwing: NetworkError.requestError(message: errorMessage))
                }
            }
        }
    }
    
    /// Will fetch details for a launch.
    ///
    /// - Parameter launchID:The id of the launch to fetch details for.
    func fetchLaunch(with launchID: GraphQLID) async throws -> GraphQLResult<LaunchDetailsQuery.Data> {
        try await withCheckedThrowingContinuation { continuation in
            apollo.fetch(query: LaunchDetailsQuery(launchId: launchID)) { result in
                let errorMessage = "Something went wrong!"
                
                switch result {
                case let .success(graphQLResult):
                    guard graphQLResult.errors == nil else {
                        return continuation.resume(throwing: NetworkError.requestError(message: errorMessage))
                    }
                    
                    continuation.resume(returning: graphQLResult)
                case .failure:
                    continuation.resume(throwing: NetworkError.requestError(message: errorMessage))
                }
            }
        }
    }
}
