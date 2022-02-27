//
//  SavedLaunchesViewModel.swift
//  SpaceX
//
//  Created by Markus Bergh on 2022-02-19.
//

import Foundation

class SavedLaunchesViewModel: ObservableObject {
    
    @Published private var savedItems: [LaunchDetails]?
    
    private func getSavedLaunches() {
        
    }
}

// MARK: - Action

extension SavedLaunchesViewModel {
    enum Action {
        case getSavedLaunches
    }
    
    func dispatch(action: Action) {
        switch action {
        case .getSavedLaunches:
            getSavedLaunches()
        }
    }
}
