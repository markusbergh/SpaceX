//
//  ContentView.swift
//  SpaceX
//
//  Created by Markus Bergh on 2022-02-13.
//

import SwiftUI

struct ContentView: View {

    @StateObject private var viewModel = LaunchListViewModel()
    
    init() {
        configureTabBar()
        configureNavigationBar()
        configureSearchBar()
    }

    var body: some View {
        TabView {
            LaunchList(viewModel: viewModel)
                .tabItem {
                    Label("Launches", systemImage: "paperplane.fill")
                }
            
            SavedLaunches()
                .tabItem {
                    Label("Saved", systemImage: "text.badge.star")
                }
            
            AppAbout()
                .tabItem {
                    Label("About", systemImage: "cursorarrow.rays")
                }
        }
        .accentColor(.green)
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
