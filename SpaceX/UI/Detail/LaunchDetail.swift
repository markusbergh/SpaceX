//
//  LaunchDetail.swift
//  SpaceX
//
//  Created by Markus Bergh on 2022-02-13.
//

import SwiftUI
import Apollo

struct LaunchDetail: View {
    
    @ObservedObject var viewModel: LaunchDetailViewModel
    
    var launchID: GraphQLID?
    
    init(launchID: GraphQLID?, viewModel: LaunchDetailViewModel) {
        self.launchID = launchID
        self.viewModel = viewModel
        
        viewModel.dispatch(action: .fetchLaunch(launchID: launchID))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                if let formattedDate = viewModel.formattedDate {
                    Text("Launch date: \(formattedDate)")
                        .foregroundColor(.white)
                        .textCase(.uppercase)
                        .font(.system(size: 12, weight: .semibold, design: .monospaced))
                        .padding(.vertical, 8)
                        .padding(.horizontal, 10)
                        .background(Capsule().fill(.green))
                        .padding(.top, 50)
                        .padding(.bottom, 10)
                }

                if let missionName = viewModel.launch?.missionName {
                    Text(missionName)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.green, .green, .green, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .font(.system(size: 28, weight: .semibold, design: .monospaced))
                        .padding(.bottom, 20)
                }
                
                HStack(spacing: 25) {
                    if let missionPatch = viewModel.launch?.links?.missionPatch {
                        AsyncImage(url: URL(string: missionPatch)) { image in
                            image.resizable()
                        } placeholder: {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .green))
                                .frame(width: 125, height: 125)
                                .background(Color.listItemPrimary)
                                .clipShape(Circle())
                        }
                        .frame(width: 125, height: 125)
                    }
                    
                    VStack(alignment: .leading, spacing: 5) {
                        if let siteName = viewModel.launch?.launchSite?.siteName {
                            Text(siteName)
                        }
                        
                        if let launchID = launchID {
                            Text("Launch: \(launchID)")
                                .fontWeight(.bold)
                        }
                        
                        if let rocketName = viewModel.launch?.rocket?.rocketName,
                           let rocketType = viewModel.launch?.rocket?.rocketType {
                            Text("\(rocketName) (\(rocketType))")
                        }
                    }
                    .font(.system(size: 16, weight: .regular, design: .monospaced))
                    .foregroundColor(.white)
                    
                    Spacer()
                }
                .padding(.bottom, 15)
                
                if let description = viewModel.launch?.details {
                    Text(description)
                        .foregroundColor(.white )
                        .font(.system(size: 16, weight: .regular, design: .monospaced))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationBarTitleDisplayMode(.inline)
            .padding(.horizontal, 30)
        }
        .background(Color.background)
    }
}

// MARK: - Gallery

struct LaunchDetailGallery: View {
    
    let images: [String]
    
    private var imagesURL: [URL] {
        return images.map { URL(string: $0)! }
    }
    
    var body: some View {
        VStack(spacing: 15) {
            ForEach(images.indices) { index in
                let imageUrl = imagesURL[index]
                
                AsyncImage(url: imageUrl) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .frame(height: 300)
                    } else {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .green))
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .frame(height: 300)
                    }
                }
                .background(Color.listItemPrimary)
                .cornerRadius(16.0)
            }
        }
    }
}

// MARK: - Mock

class MockLaunchDetailViewModel: LaunchDetailViewModel {
    override func fetchLaunch(id: GraphQLID?) async throws -> LaunchDetails {
        return LaunchDetails(
            launchSite: .init(siteName: "Site name"),
            missionName: "Mission name",
            launchDateUtc: "2022-01-01T12:00:00.000Z",
            rocket: .init(
                rocketName: "Rocket name",
                rocketType: "Rocket type"
            ),
            details: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed dictum, quam vel tristique consectetur, lorem nunc tincidunt tellus, eu mattis nulla tellus sit amet ligula. Nam pretium odio enim. Nunc et cursus nunc, sed dapibus tortor. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae; Sed vehicula mauris ac urna vehicula consectetur. Donec sollicitudin nulla ut sem rutrum feugiat. Fusce eget neque sapien.",
            links: .init(
                missionPatch: "https://images2.imgbox.com/d2/3b/bQaWiil0_o.png",
                flickrImages: [
                    "https://live.staticflickr.com/65535/50617626408_fb0bba0f89_o.jpg"
                ],
                wikipedia: nil,
                articleLink: nil
            ),
            upcoming: false
        )
    }
}

struct LaunchDetail_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = MockLaunchDetailViewModel()
        
        LaunchDetail(launchID: "123", viewModel: viewModel)
    }
}
