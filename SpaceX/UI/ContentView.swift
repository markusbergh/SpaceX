//
//  ContentView.swift
//  SpaceX
//
//  Created by Markus Bergh on 2022-02-13.
//

import SwiftUI

struct ContentView: View {
    private enum Tab {
        case none
        case list
        case saved
        case about
    }

    @StateObject private var viewModel = LaunchListViewModel()
    @State private var currentTab: Tab = .list
    
    init() {
        configureTabBar()
        configureNavigationBar()
        configureSearchBar()
    }

    var body: some View {
        TabView {
            LaunchList(viewModel: viewModel)
                .onAppear {
                    animate(tab: .list)
                }
                .opacity(opacity(for: .list))
                .background(height: 300)
                .tabItem {
                    Label("Launches", systemImage: "paperplane.fill")
                }
            
            SavedLaunches()
                .onAppear {
                    animate(tab: .saved)
                }
                .opacity(opacity(for: .saved))
                .background(height: 300)
                .tabItem {
                    Label("Saved", systemImage: "heart.text.square")
                }
            
            AppAbout()
                .onAppear {
                    animate(tab: .about)
                }
                .opacity(opacity(for: .about))
                .background(height: 300)
                .tabItem {
                    Label("About", systemImage: "cursorarrow.rays")
                }
        }
        .accentColor(.green)
    }
    
    /// Returns the opacity if the tab is the current selected tab. Is animated.
    private func opacity(for tab: Tab) -> CGFloat {
        return currentTab == tab ? 1.0 : 0.0
    }
    
    /// This methods is a `hack` to have transition effects between tabs.
    /// It uses an internal state variable to animate on, which is used to set
    /// opacity on the tab content.
    ///
    /// - Parameter tab: The active tab to transition to.
    private func animate(tab: Tab) {
        // Always reset selection
        currentTab = .none
        
        withAnimation(.linear) {
            currentTab = tab
        }
    }
}

// MARK: - Appearance

extension ContentView {
    private func configureTabBar() {
        // Content scrolled under
        let standardAppearance = UITabBarAppearance()
        standardAppearance.configureWithTransparentBackground()
        standardAppearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        UITabBar.appearance().standardAppearance = standardAppearance
        
        // Nothing is under
        let scrollEdgeAppearance = UITabBarAppearance()
        scrollEdgeAppearance.configureWithTransparentBackground()
        scrollEdgeAppearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        UITabBar.appearance().scrollEdgeAppearance = scrollEdgeAppearance
    }
    
    private func configureNavigationBar() {
        // Content scrolled under
        let standardAppearance = UINavigationBarAppearance()
        standardAppearance.configureWithTransparentBackground()
        standardAppearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        UINavigationBar.appearance().standardAppearance = standardAppearance
        
        // Nothing is under
        let scrollEdgeAppearance = UINavigationBarAppearance()
        scrollEdgeAppearance.configureWithTransparentBackground()
        scrollEdgeAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        UINavigationBar.appearance().scrollEdgeAppearance = scrollEdgeAppearance
    }
    
    private func configureSearchBar() {
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.green]
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
