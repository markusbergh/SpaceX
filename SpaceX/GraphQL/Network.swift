//
//  Network.swift
//  SpaceX
//
//  Created by Markus Bergh on 2022-02-13.
//

import Apollo
import Foundation

protocol NetworkProvider {
    associatedtype LaunchListResult
    associatedtype LaunchDetailResult
    
    var errorMessage: String { get }
    var urlString: String { get }
    
    func fetchLaunches(pageSize: Int) async throws -> LaunchListResult
    func fetchLaunch(with launchID: GraphQLID) async throws -> LaunchDetailResult
}

extension NetworkProvider {
    var errorMessage: String {
        return "Something went wrong!"
    }

    var urlString: String {
        return "https://api.spacex.land/graphql/"
    }
}

enum NetworkError: Error {
    case requestError(message: String)
    case interrupted
}

extension NetworkError: Identifiable {
    var id: UUID {
        UUID()
    }
}

class Network: NetworkProvider {
    static let shared = Network()
    
    private lazy var apollo = ApolloClient(
        url: URL(string: urlString)!
    )
}

// MARK: - NetworkProvider

extension Network {
    
    /// Will try and fetch launches with page size limit. Can throw an error.
    ///
    /// - Parameter pageSize: Number of items in each batch, defaults to `20`.
    func fetchLaunches(pageSize: Int = 20) async throws -> GraphQLResult<LaunchListQuery.Data> {
        try await withCheckedThrowingContinuation { continuation in
            if Task.isCancelled { continuation.resume(throwing: NetworkError.interrupted) }
            
            apollo.fetch(query: LaunchListQuery(pageSize: pageSize)) { result in
                switch result {
                case let .success(graphQLResult):
                    guard graphQLResult.errors == nil else {
                        return continuation.resume(throwing: NetworkError.requestError(message: self.errorMessage))
                    }
                    
                    continuation.resume(returning: graphQLResult)
                case .failure:
                    continuation.resume(throwing: NetworkError.requestError(message: self.errorMessage))
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
                switch result {
                case let .success(graphQLResult):
                    guard graphQLResult.errors == nil else {
                        return continuation.resume(throwing: NetworkError.requestError(message: self.errorMessage))
                    }
                    
                    continuation.resume(returning: graphQLResult)
                case .failure:
                    continuation.resume(throwing: NetworkError.requestError(message: self.errorMessage))
                }
            }
        }
    }
}
