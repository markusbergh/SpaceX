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
            if let missionPatch = missionPatch {
                AsyncImage(url: URL(string: missionPatch)) { image in
                    image.resizable()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 50, height: 50)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text(site ?? "No data")
                
                Text(missionName ?? "")
                    .font(.footnote)
                    .fontWeight(.bold)
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
