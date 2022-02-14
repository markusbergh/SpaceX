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
        configure()
    }
    
    private func configure() {
        // Content scrolled under
        let standardAppearance = UITabBarAppearance()
        standardAppearance.configureWithTransparentBackground()
        standardAppearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        UITabBar.appearance().standardAppearance = standardAppearance
        
        // Nothing is under
        let scrollEdgeAppearance = UITabBarAppearance()
        scrollEdgeAppearance.configureWithTransparentBackground()
        UITabBar.appearance().scrollEdgeAppearance = scrollEdgeAppearance
    }

    var body: some View {
        TabView {
            LaunchList(viewModel: viewModel)
                .tabItem {
                    Label("Launches", systemImage: "paperplane.fill")
                }
            
            VStack {
                Text("About")
            }
            .tabItem {
                Label("About", systemImage: "cursorarrow.rays")
            }
        }
        .accentColor(.green)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
