//
//  SavedListItemViewModel.swift
//  SpaceX
//
//  Created by Markus Bergh on 2022-02-27.
//

import Foundation

class SavedListItemViewModel: ObservableObject {
    
    private let launch: LaunchDetails
    
    init(launch: LaunchDetails) {
        self.launch = launch
    }
    
    var missionPatch: String? {
        return launch.links?.missionPatch
    }
    
    var missionName: String? {
        return launch.missionName
    }
    
    var siteName: String? {
        return launch.launchSite?.siteName
    }
    
    /// Will return a formatted string if possible
    var formattedDate: String? {
        guard let launchDateString = launch.launchDateUtc else {
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

}
