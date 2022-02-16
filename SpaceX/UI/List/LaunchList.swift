//
//  LaunchList.swift
//  SpaceX
//
//  Created by Markus Bergh on 2022-02-13.
//

import SwiftUI

struct LaunchList: View {
    
    @ObservedObject var viewModel: LaunchListViewModel
    
    @State private var text = ""
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
                        .listRowBackground(Color.clear)
                        .font(.system(size: 48, weight: .semibold, design: .monospaced))
                        .padding(.bottom, 20)
                    
                    ForEach(viewModel.launches.indices, id:\.self) { index in
                        let launch = viewModel.launches[index]
                        
                        ZStack {
                            NavigationLink(
                                destination: NavigationLazyView(
                                    LaunchDetail(
                                        launchID: launch.id ?? "",
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
                                    site: launch.launchSite?.siteName
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
                .listStyle(.plain)
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
                    }
                    
                    return Alert(
                        title: Text("Oops!"),
                        message: Text(errorMessage),
                        dismissButton: .default(Text("OK"))
                    )
                }
            }
            .overlay(overlayView)
            .padding(.horizontal, 10)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .background(spaceShuttle, alignment: .top)
            .background(Color.background)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .searchable(text: $text, prompt: "Search for launches")
    }
    
    /// Renders a spinner if
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
            .offset(y: -185)
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
