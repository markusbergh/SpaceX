//
//  LaunchList.swift
//  SpaceX
//
//  Created by Markus Bergh on 2022-02-13.
//

import SwiftUI

struct LaunchList: View {
    
    @ObservedObject var viewModel: LaunchListViewModel
    
    @State private var searchText = ""
    @State private var currentError: NetworkError?
        
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                List {
                    Text("SpaceX")
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.green, .green, .green, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .font(.system(size: 48, weight: .semibold, design: .monospaced))
                        .padding(.bottom, 20)
                    
                    ForEach(listItems, id:\.id) { launch in                       
                        ZStack {
                            NavigationLink(
                                destination: NavigationLazyView(
                                    LaunchDetail(
                                        id: launch.id,
                                        missionName: launch.missionName ?? "No mission name",
                                        viewModel: LaunchDetailViewModel()
                                    )
                                )
                            ) {
                                EmptyView()
                            }

                            VStack(alignment: .trailing, spacing: 0) {
                                LaunchListItem(
                                    missionName: launch.missionName,
                                    missionPatch: launch.links?.missionPatchSmall,
                                    site: launch.launchSite?.siteName,
                                    date: viewModel.formattedDate(for: launch)
                                )
                                .padding(.bottom, 20)
                                
                                LaunchListItemDivider()
                                    .padding(.bottom, 10)
                            }
                        }
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    }
                }
                .onAppear {
                    viewModel.dispatch(action: .fetchLaunches)
                }
                .onDisappear {
                    viewModel.dispatch(action: .cancel)
                }
                .onReceive(viewModel.$state) { state in
                    if case let .error(requestError) = state {
                        currentError = requestError
                    }
                }
                .alert(item: $currentError) { currentError in
                    var errorMessage = "Something went wrong!"
                    
                    switch currentError {
                    case let .requestError(message):
                        errorMessage = message
                    case .interrupted:
                        break
                    }
                    
                    return Alert(
                        title: Text("Oops!"),
                        message: Text(errorMessage),
                        dismissButton: .default(Text("OK"))
                    )
                }
                .listStyle(.plain)
            }
            .overlay(overlayView)
            .navigationBarTitleDisplayMode(.inline)
            .background(spaceShuttle, alignment: .top)
            .background(Color.background)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .searchable(text: $searchText, prompt: "Search for launches")
    }
    
    /// Returns list content, can be filtered.
    private var listItems: [Launch] {
        if searchText.isEmpty {
            return viewModel.launches
        } else {
            return viewModel.launches.filter {
                ($0.missionName?.localizedCaseInsensitiveContains(searchText) ?? false)
                || ($0.launchSite?.siteName?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
    }
    
    /// Renders a spinner if needed.
    @ViewBuilder private var overlayView: some View {
        switch viewModel.state {
        case .pending:
            Spinner()
                // Magic number ✨
                .offset(y: 50.0)
        case .idle, .error:
            EmptyView()
        }
    }
    
    /// Rendered in top of list.
    private var spaceShuttle: some View {
        Image("SpaceShuttle")
            .resizable()
            .renderingMode(.original)
            .saturation(0.0)
            .colorMultiply(Color.background)
            .scaledToFit()
            .frame(width: UIScreen.main.bounds.width * 2)
            .offset(y: -215)
            .ignoresSafeArea()
    }
}

// MARK: - Components

// MARK: Divider

struct LaunchListItemDivider: View {
    var body: some View {
        Divider().frame(height: 2).background(
            LinearGradient(
                colors: [
                    .clear,
                    .green.opacity(0.1),
                    .green.opacity(0.2),
                    .green.opacity(0.3)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .padding(.trailing, 5)
    }
}

// MARK: Lazy navigation item

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

extension LaunchListQuery.Data.LaunchesPast: Hashable, Equatable {
    public static func == (lhs: LaunchListQuery.Data.LaunchesPast, rhs: LaunchListQuery.Data.LaunchesPast) -> Bool {
        return lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Preview

struct LaunchList_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = MockLaunchListViewModel()

        LaunchList(viewModel: viewModel)
    }
}
