//
//  SavedLaunches.swift
//  SpaceX
//
//  Created by Markus Bergh on 2022-02-17.
//

import SwiftUI

struct SavedLaunches: View {
    
    @StateObject var viewModel: SavedLaunchesViewModel = SavedLaunchesViewModel()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Saved")
                .foregroundStyle(
                    LinearGradient(
                        colors: [.green, .green, .green, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .font(.system(size: 48, weight: .semibold, design: .monospaced))
                .padding(.top, 50)
            
            ForEach(viewModel.savedItems, id:\.id) { item in
                SavedListItem(
                    missionPatch: item.links?.missionPatch,
                    siteName: item.launchSite?.siteName,
                    missionName: item.missionName,
                    launchDate: item.launchDateUtc
                )
            }
            
            Spacer()
        }
        .onAppear {
            viewModel.dispatch(action: .getSavedLaunches)
        }
        .padding(.horizontal, 20)
        .frame(minWidth: 0, maxWidth: .infinity, alignment: .topLeading)
        .overlay(overlay)
        .background(
            Image("NoImage")
                .resizable()
                .renderingMode(.template)
                .foregroundColor(.white.opacity(0.05))
                .frame(width: 175, height: 175)
        )
    }
    
    private var overlay: AnyView {
        viewModel.savedItems.isEmpty ?
            AnyView(
                Text("You have no saved launches")
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .regular, design: .monospaced)
                )
            )
        : AnyView(EmptyView())
    }
}

