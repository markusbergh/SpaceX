//
//  Spinner.swift
//  SpaceX
//
//  Created by Markus Bergh on 2022-02-16.
//

import SwiftUI

struct Spinner: View {

    // Single animation
    private let rotationTime: Double = 0.75
    
    // Sum of all animation times
    private let animationTime: Double = 1.9
    
    private let fullRotation: Angle = .degrees(360)
    private static let initialDegree: Angle = .degrees(270)

    @State var spinnerStart: CGFloat = 0.0
    @State var spinnerEndS1: CGFloat = 0.0
    @State var spinnerEndS2S3: CGFloat = 0.0

    @State var rotationSpinner: Double = 0.0

    @State var rotationDegreeS1 = Self.initialDegree
    @State var rotationDegreeS2 = Self.initialDegree
    @State var rotationDegreeS3 = Self.initialDegree
    
    var body: some View {
        ZStack {
            SpinnerCircle(
                start: spinnerStart,
                end: spinnerEndS2S3,
                rotation: rotationDegreeS3,
                color: .green
            )
            
            SpinnerCircle(
                start: spinnerStart,
                end: spinnerEndS2S3,
                rotation: rotationDegreeS2,
                color: .purple
            )
            
            SpinnerCircle(
                start: spinnerStart,
                end: spinnerEndS1,
                rotation: rotationDegreeS1,
                color: .green
            )
        }
        .frame(width: 60, height: 60)
        .rotationEffect(.degrees(rotationSpinner))
        .onAppear() {
            let foreverAnimation: Animation = .linear(duration: 3.0)
                .repeatForever(autoreverses: false)
            
            withAnimation(foreverAnimation) {
                rotationSpinner = 360
            }
            
            animateSpinner()
            
            Timer.scheduledTimer(withTimeInterval: animationTime, repeats: true) { _ in
                animateSpinner()
            }
        }
    }

    private func animate(with duration: Double, completion: @escaping (() -> Void)) {
        Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { _ in
            withAnimation(.easeInOut(duration: self.rotationTime)) {
                completion()
            }
        }
    }

    private func animateSpinner() {
        animate(with: rotationTime) {
            self.spinnerEndS1 = 1.0
        }

        animate(with: (rotationTime * 2) - 0.025) {
            self.rotationDegreeS1 += fullRotation
            self.spinnerEndS2S3 = 0.8
        }

        animate(with: (rotationTime * 2)) {
            self.spinnerEndS1 = 0.03
            self.spinnerEndS2S3 = 0.03
        }

        animate(with: (rotationTime * 2) + 0.0525) {
            self.rotationDegreeS2 += fullRotation
        }
        
        animate(with: (rotationTime * 2) + 0.225) {
            self.rotationDegreeS3 += fullRotation
        }
    }
}

// MARK: - Components

struct SpinnerCircle: View {
    var start: CGFloat
    var end: CGFloat
    var rotation: Angle
    var color: Color

    var body: some View {
        Circle()
            .trim(from: start, to: end)
            .stroke(
                style: StrokeStyle(
                    lineWidth: 5,
                    lineCap: .round
                )
            )
            .fill(color)
            .rotationEffect(rotation)
    }
}

// MARK: - Preview

struct Spinner_Previews: PreviewProvider {
    static var previews: some View {
        Spinner()
    }
}
