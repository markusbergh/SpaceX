//
//  SavedLaunches.swift
//  SpaceX
//
//  Created by Markus Bergh on 2022-02-17.
//

import SwiftUI

struct SavedLaunches: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Saved")
                .foregroundStyle(
                    LinearGradient(
                        colors: [.green, .green, .green, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .font(.system(size: 48, weight: .semibold, design: .monospaced))
                .padding(.top, 50)
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .frame(minWidth: 0, maxWidth: .infinity, alignment: .topLeading)
        .overlay(
            Text("You have no saved launches")
                .foregroundColor(.white)
                .font(.system(size: 16, weight: .regular, design: .monospaced))
        )
        .background(
            Image("NoImage")
                .resizable()
                .renderingMode(.template)
                .foregroundColor(.white.opacity(0.05))
                .frame(width: 175, height: 175)
        )
        .background(
            LinearGradient(
                colors: [.black, .background],
                startPoint: .top,
                endPoint: .bottom
            ).frame(height: 300).ignoresSafeArea(),
            alignment: .top
        )
        .background(Color.background)
    }
}

