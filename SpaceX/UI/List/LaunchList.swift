//
//  LaunchList.swift
//  SpaceX
//
//  Created by Markus Bergh on 2022-02-13.
//

import SwiftUI

struct LaunchList: View {
    
    @ObservedObject var viewModel: LaunchListViewModel
        
    var body: some View {
        VStack(alignment: .leading) {
            Text("SpaceX")
                .foregroundColor(.listTitle)
                .font(.system(size: 48, weight: .semibold))
                .padding()

            List {
                ForEach(viewModel.launches.indices, id:\.self) { index in
                    let launch = viewModel.launches[index]
                    let backgroundColor: Color = index % 2 == 0 ? .listItemPrimary : .listItemSecondary
                    
                    NavigationLink(
                        destination: NavigationLazyView(
                            LaunchDetail(
                                launchID: launch.id,
                                viewModel: LaunchDetailViewModel()
                            )
                        )
                    ) {
                        LaunchListItem(
                            missionName: launch.mission?.name,
                            missionPatch: launch.mission?.missionPatch,
                            site: launch.site
                        )
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15.0)
                            .fill(backgroundColor)
                            .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 10.0)
                    )
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .padding(.bottom)
                }
            }
            .onAppear {
                viewModel.dispatch(action: .fetchLaunches)
            }
            .listStyle(.plain)
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
        }
        .padding()
        .edgesIgnoringSafeArea(.bottom)
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

struct LaunchList_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = MockLaunchListViewModel()

        LaunchList(viewModel: viewModel)
    }
}
