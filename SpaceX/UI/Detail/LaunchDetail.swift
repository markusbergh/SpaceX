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
            VStack(alignment: .leading) {
                Text(viewModel.launch?.launchSite?.siteName ?? "")
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.green, .green, .green, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .font(.system(size: 38, weight: .semibold, design: .monospaced))
                    .padding(.bottom, 20)
                
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
                    
                    VStack(alignment: .leading) {
                        if let missionName = viewModel.launch?.missionName {
                            Text(missionName)
                                .font(.system(size: 19, weight: .regular, design: .monospaced))
                        }
                        
                        if let launchID = launchID {
                            Text("Launch: \(launchID)")
                                .font(.system(size: 16, weight: .bold, design: .monospaced))
                        }
                        
                        if let rocketName = viewModel.launch?.rocket?.rocketName,
                           let rocketType = viewModel.launch?.rocket?.rocketType {
                            Text("\(rocketName) (\(rocketType))")
                                .font(.system(size: 16, weight: .regular, design: .monospaced))
                        }
                    }
                    .foregroundColor(.white)
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
