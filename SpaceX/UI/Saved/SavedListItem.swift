//
//  SavedListItem.swift
//  SpaceX
//
//  Created by Markus Bergh on 2022-02-24.
//

import SwiftUI

struct SavedListItem: View {
    
    let missionPatch: String?
    let siteName: String?
    let missionName: String?
    let launchDate: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                if let missionPatch = missionPatch {
                    AsyncImage(url: URL(string: missionPatch)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .green))
                                .frame(width: 50, height: 50)
                        case let .success(image):
                            image
                                .resizable()
                                .colorMultiply(.green)
                                .frame(width: 50, height: 50)
                        case .failure:
                            Image("NoImage")
                                .resizable()
                                .renderingMode(.template)
                                .foregroundColor(.green)
                                .frame(width: 30, height: 30)
                                .frame(width: 50, height: 50)
                                .background(Circle().fill(Color.listItemNoImage))
                        @unknown default:
                            fatalError("Unhandled phase")
                        }
                    }
                }
                
                Spacer()
                
                Image(systemName: "heart.fill")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.green)
            }
            
            Text("\(launchDate ?? "")")
                .foregroundColor(.green)
                .font(.system(size: 14, design: .monospaced))
            
            Text("\(siteName ?? "")")
                .foregroundColor(.white)
                .font(.system(size: 16, design: .monospaced))

            Text("\(missionName ?? "")")
                .foregroundColor(.white)
                .font(.system(size: 14, design: .monospaced))
            
        }
        .padding()
        .background(Color.listItemPrimary)
        .cornerRadius(16.0)
    }
}

struct SavedListItem_Previews: PreviewProvider {
    static var previews: some View {
        SavedListItem(missionPatch: nil, siteName: "Site name", missionName: "Mission name", launchDate: "2022-02-22")
    }
}
