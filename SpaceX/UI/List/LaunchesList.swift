//
//  LaunchesList.swift
//  SpaceX
//
//  Created by Markus Bergh on 2022-02-13.
//

import SwiftUI

struct LaunchesList: View {
    
    @StateObject private var viewModel = LaunchesListViewModel()
    
    var body: some View {
        List {
            Section("Launches") {
                ForEach(viewModel.launches, id:\.self) { launch in
                    Text(launch.site ?? "No data")
                }
            }
        }
        .alert(item: $viewModel.error) { error in
            switch error {
            case let .requestError(message):
                return Alert(
                    title: Text("Oops!"),
                    message: Text(message),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        .onAppear {
            viewModel.dispatch(action: .fetchLaunches)
        }
    }
}

// MARK: Data extension

extension LaunchListQuery.Data.Launch.Launch: Hashable, Equatable {
    public static func == (lhs: LaunchListQuery.Data.Launch.Launch, rhs: LaunchListQuery.Data.Launch.Launch) -> Bool {
        return lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
