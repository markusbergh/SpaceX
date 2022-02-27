//
//  SavedListItem.swift
//  SpaceX
//
//  Created by Markus Bergh on 2022-02-24.
//

import Apollo
import SwiftUI

struct SavedListItem: View {
    
    private let viewModel: SavedListItemViewModel
    
    init(launch: LaunchDetails) {
        viewModel = SavedListItemViewModel(launch: launch)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                if let missionPatch = viewModel.missionPatch {
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
            
            Text("\(viewModel.formattedDate ?? "")")
                .foregroundColor(.green)
                .font(.system(size: 14, design: .monospaced))
            
            Text("\(viewModel.siteName ?? "")")
                .foregroundColor(.white)
                .font(.system(size: 16, design: .monospaced))

            Text("\(viewModel.missionName ?? "")")
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
        let launch = LaunchDetails(
            id: "1",
            launchSite: .init(siteName: "Site name"),
            missionName: "Mission name",
            launchDateUtc: "2022-01-01T12:00:00.000Z",
            rocket: nil,
            details: nil,
            links: nil,
            upcoming: false
        )
        
        SavedListItem(launch: launch)
            .previewLayout(.fixed(width: 375, height: 135))
    }
}
