//
//  LaunchDetail.swift
//  SpaceX
//
//  Created by Markus Bergh on 2022-02-13.
//

import SwiftUI
import Apollo

struct LaunchDetail: View {
    
    @ObservedObject var viewModel: LaunchDetailViewModel
    
    var launchID: GraphQLID?
    
    init(launchID: GraphQLID, viewModel: LaunchDetailViewModel) {
        self.launchID = launchID
        self.viewModel = viewModel
        
        viewModel.dispatch(action: .fetchLaunch(launchID: launchID))
    }
    
    var body: some View {
        VStack {
            HStack(spacing: 15) {
                if let missionPatch = viewModel.launch?.mission?.missionPatch {
                    AsyncImage(url: URL(string: missionPatch)) { image in
                        image.resizable()
                    } placeholder: {
                        ProgressView()
                            .frame(width: 150, height: 150)
                    }
                    .frame(width: 150, height: 150)
                }
                
                VStack {
                    if let missionName = viewModel.launch?.mission?.name {
                        Text(missionName)
                            .font(.title)
                    }
                    
                    if let launchID = launchID {
                        Text("Launch: \(launchID)")
                    }
                    
                    if let rocketName = viewModel.launch?.rocket?.name,
                       let rocketType = viewModel.launch?.rocket?.type {
                        Text("🚀 \(rocketName) (\(rocketType))")
                    }
                }
            }
            
            Spacer()
        }
    }
}
