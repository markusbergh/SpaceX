//
//  SavedLaunches.swift
//  SpaceX
//
//  Created by Markus Bergh on 2022-02-17.
//

import SwiftUI

struct SavedLaunches: View {
    
    @StateObject var viewModel: SavedLaunchesViewModel = SavedLaunchesViewModel()
    
    private var columns: [GridItem] = Array(
        repeating: .init(.flexible(), spacing: 10.0, alignment: nil),
        count: 2
    )
    
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

            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(viewModel.savedItems, id:\.id) { item in
                        SavedListItem(launch: item)
                    }
                }
            }
        
            Spacer()
        }
        .onAppear {
            viewModel.dispatch(action: .getSavedLaunches)
        }
        .padding(.horizontal, 20)
        .frame(minWidth: 0, maxWidth: .infinity, alignment: .topLeading)
        .overlay(overlay)
        .background(background)
    }
    
    @ViewBuilder private var overlay: some View {
        if viewModel.savedItems.isEmpty {
            Text("You have no saved launches")
                .foregroundColor(.white)
                .font(.system(size: 16, weight: .regular, design: .monospaced))
        } else {
            EmptyView()
        }
        
    }
    
    @ViewBuilder private var background: some View {
        if viewModel.savedItems.isEmpty {
            Image("NoImage")
                .resizable()
                .renderingMode(.template)
                .foregroundColor(.white.opacity(0.05))
                .frame(width: 175, height: 175)
        } else {
            EmptyView()
        }
    }
}

struct SavedLaunches_Previews: PreviewProvider {
    static var previews: some View {
        SavedLaunches()
    }
}
