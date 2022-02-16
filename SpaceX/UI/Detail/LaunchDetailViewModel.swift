//
//  LaunchDetailViewModel.swift
//  SpaceX
//
//  Created by Markus Bergh on 2022-02-13.
//

import Foundation
import Apollo

class LaunchDetailViewModel: ObservableObject {
    /// Network layer
    private let network: Network
    
    @Published private(set) var launch: LaunchDetailsQuery.Data.Launch?
    
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
}

// MARK: - Actions

extension LaunchDetailViewModel {
    enum Action {
        case fetchLaunch(launchID: GraphQLID?)
    }

    func dispatch(action: Action) {
        switch action {
        case let .fetchLaunch(launchID):
             fetchLaunch(launchID)
        }
    }
}

// MARK: - Private

extension LaunchDetailViewModel {
    private func fetchLaunch(_ id: GraphQLID?) {
        guard let id = id else { return }
        
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
