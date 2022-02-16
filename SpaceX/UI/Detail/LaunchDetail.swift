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
    
    init(launchID: GraphQLID?, viewModel: LaunchDetailViewModel) {
        self.launchID = launchID
        self.viewModel = viewModel
        
        viewModel.dispatch(action: .fetchLaunch(launchID: launchID))
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                if let formattedDate = viewModel.formattedDate {
                    Text("Launch date: \(formattedDate)")
                        .foregroundColor(.white)
                        .textCase(.uppercase)
                        .font(.system(size: 12, weight: .regular, design: .monospaced))
                        .padding(.vertical, 8)
                        .padding(.horizontal, 10)
                        .background(Capsule().fill(.green))
                        .padding(.bottom, 10)
                }

                if let missionName = viewModel.launch?.missionName {
                    Text(missionName)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.green, .green, .green, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .font(.system(size: 32, weight: .semibold, design: .monospaced))
                        .padding(.bottom, 20)
                }
                
                HStack(spacing: 25) {
                    if let missionPatch = viewModel.launch?.links?.missionPatch {
                        AsyncImage(url: URL(string: missionPatch)) { image in
                            image.resizable()
                        } placeholder: {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .green))
                                .frame(width: 125, height: 125)
                        }
                        .frame(width: 125, height: 125)
                    }
                    
                    VStack(alignment: .leading, spacing: 5) {
                        if let siteName = viewModel.launch?.launchSite?.siteName {
                            Text(siteName)
                        }
                        
                        if let launchID = launchID {
                            Text("Launch: \(launchID)")
                                .fontWeight(.bold)
                        }
                        
                        if let rocketName = viewModel.launch?.rocket?.rocketName,
                           let rocketType = viewModel.launch?.rocket?.rocketType {
                            Text("\(rocketName) (\(rocketType))")
                        }
                        
                        if let siteName = viewModel.launch?.launchSite?.siteName {
                            Text(siteName)
                        }
                    }
                    .font(.system(size: 16, weight: .regular, design: .monospaced))
                    .foregroundColor(.white)
                }
                .padding(.bottom, 15)
                
                if let description = viewModel.launch?.details {
                    Text(description)
                        .foregroundColor(.white )
                        .font(.system(size: 16, weight: .regular, design: .monospaced))
                }
                
                Spacer()
            }
            .padding(.horizontal, 30)
            .navigationBarTitleDisplayMode(.inline)
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .topLeading)
            .background(Color.background)
        }
    }
}
