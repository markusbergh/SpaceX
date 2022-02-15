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
                        let backgroundColor: Color = index % 2 == 0 ? .listItemPrimary : .listItemSecondary
                        
                        ZStack {
                            NavigationLink(
                                destination: NavigationLazyView(
                                    LaunchDetail(
                                        launchID: launch.id,
                                        viewModel: LaunchDetailViewModel()
                                    )
                                )
                            ) {
                                EmptyView()
                            }

                            VStack(alignment: .trailing, spacing: 0) {
                                Text(Date(), style: .date)
                                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                                    .foregroundColor(.green)
                                    .padding(.trailing, 5)
                                    .padding(.bottom, 5)
                                
                                LaunchListItem(
                                    missionName: launch.mission?.name,
                                    missionPatch: launch.mission?.missionPatch,
                                    site: launch.site
                                )
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 15.0)
                                        .fill(backgroundColor)
                                        .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 10.0)
                                )
                                .padding(.bottom, 25)
                                
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
                                .padding(.bottom, 15)
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
            .padding(.horizontal, 10)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .background(spaceShuttle, alignment: .top)
            .background(Color.background)
        }
        .searchable(text: $text, prompt: "Search for launches")
    }
    
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
