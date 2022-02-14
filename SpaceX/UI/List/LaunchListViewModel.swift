//
//  LaunchListViewModel.swift
//  SpaceX
//
//  Created by Markus Bergh on 2022-02-13.
//

import Apollo
import SwiftUI

typealias Launch = LaunchListQuery.Data.Launch.Launch

protocol LaunchListProvider {
    func fetchLaunches() async throws -> [Launch]
}

class LaunchListViewModel: ObservableObject, LaunchListProvider {
    enum Action {
        case fetchLaunches
        case fetchMore
    }
    
    enum Error: Swift.Error {
        case fetchItemsError
    }
    
    /// Holder of launches data.
    @Published private(set) var launches = [Launch]()
    
    /// Error that needs handling.
    @Published var error: NetworkError?
    
    /// Network layer
    private let network: Network
    
    init(network: Network = Network.shared) {
        self.network = network
    }
    
    func dispatch(action: Action) {
        switch action {
        case .fetchLaunches:
            launches.removeAll()
            
            Task {
                do {
                    let launches = try await fetchLaunches()
                    
                    DispatchQueue.main.async {
                        self.launches.append(contentsOf: launches)
                    }
                } catch let NetworkError.requestError(message: message) {
                    // TODO: Handle error
                    assertionFailure("Unhandled error: \(message)")
                }
            }
        case .fetchMore:
            // TODO: Handle
            break
        }
    }
    
    func fetchLaunches() async throws -> [Launch] {
        guard launches.isEmpty else {
            throw Error.fetchItemsError
        }
        
        do {
            let graphQLResult = try await network.fetchLaunches(pageSize: 15)
            
            guard let launchConnection = graphQLResult.data?.launches else {
                throw Error.fetchItemsError
            }
            
            return launchConnection.launches.compactMap { $0 }
        } catch {
            throw error
        }
    }
}

// MARK: Mock

class MockLaunchListViewModel: LaunchListViewModel {
    override func fetchLaunches() async throws -> [Launch] {
        let launches = [
            Launch(
                id: .init("1"),
                site: "KSC LC 39A",
                mission: .init(
                    name: "Starlink-15 (v1.0)",
                    missionPatch: nil
                )
            ),
            Launch(
                id: .init("1"),
                site: "KSC LC 39A",
                mission: .init(
                    name: "Starlink-15 (v1.0)",
                    missionPatch: nil
                )
            ),
            Launch(
                id: .init("1"),
                site: "KSC LC 39A",
                mission: .init(
                    name: "Starlink-15 (v1.0)",
                    missionPatch: nil
                )
            ),
            Launch(
                id: .init("1"),
                site: "KSC LC 39A",
                mission: .init(
                    name: "Starlink-15 (v1.0)",
                    missionPatch: nil
                )
            ),
            Launch(
                id: .init("1"),
                site: "KSC LC 39A",
                mission: .init(
                    name: "Starlink-15 (v1.0)",
                    missionPatch: nil
                )
            )
        ]
        
        return launches
    }
    
}
