//
//  AppAbout.swift
//  SpaceX
//
//  Created by Markus Bergh on 2022-02-14.
//

import SwiftUI

struct AppAbout: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("About")
                .foregroundStyle(
                    LinearGradient(
                        colors: [.green, .green, .green, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .font(.system(size: 48, weight: .semibold, design: .monospaced))
                .padding(.top, 50)
            
            Text("""
            This is a tiny demo app to evaluate and learn some about using GraphQL on iOS.
            
            It uses [Apollo Client](https://www.apollographql.com/docs/ios/) for iOS to fetch data of SpaceX launches from a spec-compliant GraphQL server.
            
            It was totally built just for fun and to dive a little into the query language and connecting the data with the view layer.
            
            Made with <3 in 2022
            """).foregroundColor(.white).font(.system(size: 16, weight: .regular, design: .monospaced))
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .frame(minWidth: 0, maxWidth: .infinity, alignment: .topLeading)
        .background(
            Image("Planet")
                .resizable()
                .renderingMode(.template)
                .foregroundColor(.white.opacity(0.05))
                .frame(width: 175, height: 175)
                .offset(y: 190)
        )
    }
}
