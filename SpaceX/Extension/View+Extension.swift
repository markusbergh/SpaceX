//
//  View+Extension.swift
//  SpaceX
//
//  Created by Markus Bergh on 2022-02-14.
//

import SwiftUI

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
 
        return Path(path.cgPath)
    }
}

// MARK: - Corner radius

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

// MARK: - Background

extension View {
    func background(height: CGFloat = 300) -> some View {
        let linearGradient = LinearGradient(
            colors: [.black, .background],
            startPoint: .top,
            endPoint: .bottom
        )

        return self.background(
            linearGradient.frame(height: height).ignoresSafeArea(),
            alignment: .top
        ).background(Color.background)
    }
}
