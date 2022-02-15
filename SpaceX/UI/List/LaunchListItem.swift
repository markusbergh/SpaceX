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
    
    var body: some View {
        HStack {
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
                        .background(Circle())
                }
            }
            .padding(.trailing, 20)
            
            Spacer()
            
            HStack {
                VStack(alignment: .trailing, spacing: 2) {
                    Text(site ?? "No data")
                        .font(.system(size: 20, design: .monospaced))
                        .foregroundColor(.white)
                    
                    Text(missionName ?? "")
                        .font(.system(size: 12, weight: .heavy, design: .monospaced))
                        .foregroundColor(.white.opacity(0.5))
                        .multilineTextAlignment(.trailing)
                }

                Image(systemName: "chevron.right")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.white)
                    .frame(width: 12, height: 12)
                    .padding(.leading, 5)
            }
        }
    }
}

struct LaunchListItem_Previews: PreviewProvider {
    static var previews: some View {
        LaunchListItem(
            missionName: "Mission name",
            missionPatch: nil,
            site: "KSC LC 39A"
        )
    }
}
