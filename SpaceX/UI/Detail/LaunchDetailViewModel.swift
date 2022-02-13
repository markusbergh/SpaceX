//
//  LaunchDetailViewModel.swift
//  SpaceX
//
//  Created by Markus Bergh on 2022-02-13.
//

import Foundation
import Apollo

class LaunchDetailViewModel: ObservableObject {
    enum Action {
        case fetchLaunch(launchID: GraphQLID)
    }
    
    /// Network layer
    private let network: Network
    
    @Published private(set) var launch: LaunchDetailsQuery.Data.Launch?
    
    init(network: Network = Network.shared) {
        self.network = network
    }
    
    func dispatch(action: Action) {
        switch action {
        case let .fetchLaunch(launchID):
             fetchLaunch(launchID)
        }
    }
    
    private func fetchLaunch(_ id: GraphQLID) {
        Task {
            do {
                let graphQLResult = try await network.fetchLaunch(with: id)
                
                if let launch = graphQLResult.data?.launch {
                    DispatchQueue.main.async {
                        self.launch = launch
                    }
                }
            } catch let NetworkError.requestError(message: message) {
                // TODO: Handle error
                assertionFailure("Unhandled error: \(message)")
            }
        }
    }
}
