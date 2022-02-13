//
//  LaunchList.swift
//  SpaceX
//
//  Created by Markus Bergh on 2022-02-13.
//

import SwiftUI

struct LaunchList: View {
    
    @StateObject private var viewModel = LaunchListViewModel()
    
    var body: some View {
        List {
            Section("Launches") {
                ForEach(viewModel.launches, id:\.self) { launch in
                    NavigationLink(
                        destination: NavigationLazyView(
                            LaunchDetail(
                                launchID: launch.id,
                                viewModel: LaunchDetailViewModel()
                            )
                        )
                    ) {
                        HStack {
                            if let missionPatch = launch.mission?.missionPatch {
                                AsyncImage(url: URL(string: missionPatch)) { image in
                                    image.resizable()
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(width: 50, height: 50)
                                
                                Spacer()
                            }
                            
                            Text(launch.site ?? "No data")
                        }
                    }
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

// MARK: - Lazy navigation item

struct NavigationLazyView<Content: View>: View {
    let build: () -> Content
    
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
    
    var body: Content {
        build()
    }
}

// MARK: - Data extension

extension LaunchListQuery.Data.Launch.Launch: Hashable, Equatable {
    public static func == (lhs: LaunchListQuery.Data.Launch.Launch, rhs: LaunchListQuery.Data.Launch.Launch) -> Bool {
        return lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
