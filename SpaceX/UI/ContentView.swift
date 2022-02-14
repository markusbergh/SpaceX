//
//  ContentView.swift
//  SpaceX
//
//  Created by Markus Bergh on 2022-02-13.
//

import SwiftUI

struct ContentView: View {

    @StateObject private var viewModel = LaunchListViewModel()

    var body: some View {
        NavigationView {
            LaunchList(viewModel: viewModel)
                .navigationBarHidden(true)
                .background(spaceShuttle, alignment: .top)
                .background(Color.background)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private var spaceShuttle: some View {
        Image("SpaceShuttle")
            .resizable()
            .renderingMode(.original)
            .colorMultiply(Color.background)
            .scaledToFit()
            .frame(width: UIScreen.main.bounds.width * 2)
            .offset(y: -185)
            .ignoresSafeArea()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
