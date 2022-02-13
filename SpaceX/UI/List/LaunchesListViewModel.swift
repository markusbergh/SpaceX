//
//  LaunchesListViewModel.swift
//  SpaceX
//
//  Created by Markus Bergh on 2022-02-13.
//

import SwiftUI

class LaunchesListViewModel: ObservableObject {
    enum Action {
        case fetchLaunches
    }
    
    /// Holder of launches data.
    @Published private(set) var launches = [LaunchListQuery.Data.Launch.Launch]()
    
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
             fetchLaunches()
        }
    }
    
    private func fetchLaunches() {
        Task {
            do {
                let graphQLResult = try await network.fetchLaunches()
                
                if let launchConnection = graphQLResult.data?.launches {
                    DispatchQueue.main.async {
                        self.launches.append(contentsOf: launchConnection.launches.compactMap { $0 })
                    }
                }
            } catch let NetworkError.requestError(message: message) {
                // TODO: Handle error
                assertionFailure("Unhandled error: \(message)")
            }
        }
    }
}
