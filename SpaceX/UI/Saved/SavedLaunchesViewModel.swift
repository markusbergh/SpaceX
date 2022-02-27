//
//  SavedLaunchesViewModel.swift
//  SpaceX
//
//  Created by Markus Bergh on 2022-02-19.
//

import Apollo
import SwiftUI

class SavedLaunchesViewModel: ObservableObject {
    
    @Published private(set) var savedItems: [LaunchDetails] = []
    
    private var savedLaunchesDefaultsKey: String {
        return "com.marber.SpaceX.saved-launches"
    }
    
    private func getSavedLaunches() {
        do {
            guard let previousSavedLaunches = UserDefaults.standard.array(forKey: savedLaunchesDefaultsKey) as? [Data] else {
                return
            }
            
            let savedItems = try previousSavedLaunches.compactMap { data -> LaunchDetails? in
                guard let jsonObject = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? JSONObject else {
                    return nil
                }

                return try LaunchDetails(jsonObject: jsonObject)
            }
            
            withAnimation {
                self.savedItems = savedItems
            }
        } catch {
            // TODO: Handle error
        }
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
