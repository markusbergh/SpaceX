//
//  LaunchListViewModel.swift
//  SpaceX
//
//  Created by Markus Bergh on 2022-02-13.
//

import Apollo
import SwiftUI

typealias Launch = LaunchListQuery.Data.LaunchesPast

protocol LaunchListProvider {
    func fetchLaunches() async throws -> [Launch]
}

class LaunchListViewModel: ObservableObject, LaunchListProvider {
    enum Action {
        case cancel
        case fetchLaunches
        case fetchMore
    }
    
    enum State {
        case idle
        case pending
        case error(NetworkError)
    }
    
    enum Error: Swift.Error {
        case fetchItemsError
    }
    
    /// Holder of launch data.
    @Published private(set) var launches = [Launch]()
    
    /// State that needs handling.
    @Published var state: State = .idle
    
    /// Network layer
    private let network: Network
    
    /// Cancellable task
    private var cancellable: Task<Void, Swift.Error>?
    
    init(network: Network = Network.shared) {
        self.network = network
    }
    
    func formattedDate(for launch: Launch) -> String? {
        guard let launchDateString = launches.first(where: { launch.id == $0.id })?.launchDateUtc else {
            return nil
        }
        
        // Cannot use `ISO8601DateFormatter` because of less date style options
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"

        guard let launchDate = dateFormatter.date(from: launchDateString) else {
            return nil
        }
        
        // Update date style
        dateFormatter.dateFormat = "YYYY-MM-dd"
        
        return dateFormatter.string(from: launchDate)
    }
    
    func dispatch(action: Action) {
        switch action {
        case .fetchLaunches:
            guard launches.isEmpty else { return }
            
            cancellable = Task { () throws in
                do {
                    let launches = try await fetchLaunches()
                                        
                    DispatchQueue.main.async {
                        self.launches.append(contentsOf: launches)
                        
                        // All good!
                        self.state = .idle
                    }
                } catch NetworkError.requestError {
                    DispatchQueue.main.async {
                        self.state = .error(.requestError(message: "Something went wrong while fetching data."))
                    }
                }
            }
        case .fetchMore:
            // TODO: Handle
            break
        case .cancel:
            cancellable?.cancel()
        }
    }
    
    func fetchLaunches() async throws -> [Launch] {
        guard launches.isEmpty else {
            throw Error.fetchItemsError
        }
        
        DispatchQueue.main.async {
            self.state = .pending
        }
        
        do {
            let graphQLResult = try await network.fetchLaunches(pageSize: 15)
            
            guard let launchesPast = graphQLResult.data?.launchesPast else {
                throw Error.fetchItemsError
            }
            
            return launchesPast.compactMap { $0 }
        } catch {
            throw error
        }
    }
}

// MARK: - Mock

class MockLaunchListViewModel: LaunchListViewModel {
    override func fetchLaunches() async throws -> [Launch] {
        let launches = [
            Launch(
                id: .init("1"),
                launchSite: .init(siteName: "KSC LC 39A"),
                missionName: "Starlink-15 (v1.0)",
                links: .init(missionPatchSmall: nil),
                launchYear: "2020",
                launchDateUtc: "2020-10-24T15:31:00.000Z"
            ),
            Launch(
                id: .init("1"),
                launchSite: .init(siteName: "KSC LC 39A"),
                missionName: "Starlink-15 (v1.0)",
                links: .init(missionPatchSmall: nil),
                launchYear: "2020",
                launchDateUtc: "2020-10-24T15:31:00.000Z"
            ),
            Launch(
                id: .init("1"),
                launchSite: .init(siteName: "KSC LC 39A"),
                missionName: "Starlink-15 (v1.0)",
                links: .init(missionPatchSmall: nil),
                launchYear: "2020",
                launchDateUtc: "2020-10-24T15:31:00.000Z"
            ),
            Launch(
                id: .init("1"),
                launchSite: .init(siteName: "KSC LC 39A"),
                missionName: "Starlink-15 (v1.0)",
                links: .init(missionPatchSmall: nil),
                launchYear: "2020",
                launchDateUtc: "2020-10-24T15:31:00.000Z"
            ),
        ]
        
        return launches
    }
}
