//
//  LaunchListItem.swift
//  SpaceX
//
//  Created by Markus Bergh on 2022-02-14.
//

import SwiftUI

struct LaunchListItem: View {
    
    let missionName: String?
    let missionPatch: String?
    let site: String?
    let date: String?
    
    private var backgroundColor: Color {
        return .listItemPrimary
    }
    
    var body: some View {
        HStack {
            HStack {
                LaunchListItemImage(missionPatch: missionPatch)
                    .padding(.trailing, 20)
                
                Spacer()
                
                HStack {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(date ?? "")
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(.green)
                            .padding(.bottom, 5)
                        
                        Text(site ?? "No data")
                            .font(.system(size: 20, design: .monospaced))
                            .foregroundColor(.white)
                        
                        Text(missionName ?? "")
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                            .foregroundColor(.white.opacity(0.5))
                            .multilineTextAlignment(.trailing)
                    }
                }
            }
            .padding()
            
            disclosureIndicator
                .background(.green)
                .padding(.leading, 5)
                .cornerRadius(15.0, corners: [.topRight, .bottomRight])
        }
        .background(
            RoundedRectangle(cornerRadius: 15.0)
                .fill(backgroundColor)
                .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 10.0)
        )
    }
    
    private var disclosureIndicator: some View {
        VStack {
            Image(systemName: "chevron.right")
                .resizable()
                .scaledToFit()
                .foregroundColor(.white)
                .frame(width: 12, height: 12)
        }
        .frame(width: 35)
        .frame(minHeight: 0, maxHeight: .infinity)
    }
}

// MARK: - Components

// MARK: Image

struct LaunchListItemImage: View {
    let missionPatch: String?
    
    var body: some View {
        Group {
            if let missionPatch = missionPatch {
                AsyncImage(url: URL(string: missionPatch)) { image in
                    image.resizable()
                } placeholder: {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .green))
                }
                .colorMultiply(.green)
                .frame(width: 50, height: 50)
            } else {
                Image("NoImage")
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(.green)
                    .frame(width: 25, height: 25)
                    .frame(width: 50, height: 50)
                    .background(Circle().fill(Color.listItemNoImage))
            }
        }
    }
}

struct LaunchListItem_Previews: PreviewProvider {
    static var previews: some View {
        LaunchListItem(
            missionName: "Mission name",
            missionPatch: nil,
            site: "KSC LC 39A",
            date: "11/11/11"
        )
    }
}
