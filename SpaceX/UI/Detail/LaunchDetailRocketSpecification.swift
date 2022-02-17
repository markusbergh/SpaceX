//
//  LaunchDetailRocketSpecification.swift
//  SpaceX
//
//  Created by Markus Bergh on 2022-02-17.
//

import SwiftUI

struct LaunchDetailRocketSpecification: View {
    /// Specifications
    let diameter: String?
    let height: String?
    let mass: String?
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Rocket specifications")
                .foregroundColor(.white)
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .padding(.bottom, 5)
            
            HStack {
                HStack {
                    Image(systemName: "arrow.up.backward.and.arrow.down.forward")
                    
                    VStack(alignment: .leading) {
                        Text("Diameter")
                            .font(.system(size: 10, weight: .regular, design: .monospaced))

                        Text("\(diameter ?? "Unknown")")
                    }
                    .foregroundColor(.green)
                }
                
                Spacer()
                
                HStack {
                    Image(systemName: "arrow.up.and.down")

                    VStack(alignment: .leading) {
                        Text("Height")
                            .font(.system(size: 10, weight: .regular, design: .monospaced))

                        Text("\(height ?? "Unknown")")
                    }
                    .foregroundColor(.green)
                }
                
                Spacer()
                
                HStack {
                    Image(systemName: "scalemass")
                    
                    VStack(alignment: .leading) {
                        Text("Mass")
                            .font(.system(size: 10, weight: .regular, design: .monospaced))

                        Text("\(mass ?? "Unknown")")
                    }
                    .foregroundColor(.green)
                }
            }
            .foregroundColor(.white )
            .font(.system(size: 14, weight: .regular, design: .monospaced))
        }
    }
}
