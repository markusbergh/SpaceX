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
    
    let id: GraphQLID?
    let missionName: String
    
    init(
        id: GraphQLID?,
        missionName: String,
        viewModel: LaunchDetailViewModel
    ) {
        self.id = id
        self.missionName = missionName
        self.viewModel = viewModel
        
        viewModel.dispatch(action: .fetchLaunch(id: id))
    }
    
    /// Will return placeholder content if currently loading.
    private var description: String {
        guard let description = viewModel.launch?.details else {
            if isLoading {
                return "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Duis accumsan et tortor quis rhoncus. Fusce eu dolor at mi tincidunt faucibus vel nec nulla. Ut posuere vel neque at dignissim. Donec placerat eros at lacus fermentum facilisis. Sed a dui lacinia, rutrum metus vel, ultricies massa. Praesent pellentesque ante sed ultrices bibendum."
            }
            
            return "No description available."
        }
        
        return description
    }
    
    /// Treats `pending` and `idle` as loading.
    private var isLoading: Bool {
        return viewModel.state == .pending || viewModel.state == .idle
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text(missionName)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.green, .green, .green, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .font(.system(size: 36, weight: .semibold, design: .monospaced))
                    .padding(.top, 25)
                    .padding(.bottom, 15)
                
                Text("Launch: \(viewModel.formattedDate ?? "No loaded date")")
                    .foregroundColor(.white)
                    .textCase(.uppercase)
                    .font(.system(size: 12, weight: .semibold, design: .monospaced))
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Capsule().fill(.green))
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 5.0)
                    .padding(.bottom, 25)
                    .redacted(reason: isLoading ? .placeholder : [])
            
                HStack(spacing: 25) {
                    if let missionPatch = viewModel.launch?.links?.missionPatch {
                        let imageTransaction = Transaction(animation: .linear)
                        let imageUrl = URL(string: missionPatch)
                        
                        AsyncImage(url: imageUrl, transaction: imageTransaction) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .green))
                                    .frame(width: 125, height: 125)
                                    .background(Color.listItemPrimary)
                                    .clipShape(Circle())
                            case let .success(image):
                                image
                                    .resizable()
                                    .frame(width: 125, height: 125)
                            case .failure:
                                Image("NoImage")
                                    .resizable()
                                    .renderingMode(.template)
                                    .foregroundColor(.white)
                                    .frame(width: 50, height: 50)
                                    .frame(width: 125, height: 125)
                                    .background(Color.listItemPrimary)
                                    .clipShape(Circle())
                            @unknown default:
                                fatalError("Unhandled phase")
                            }
                        }
                    } else {
                        if !isLoading {
                            Image("NoImage")
                                .resizable()
                                .renderingMode(.template)
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                                .frame(width: 125, height: 125)
                                .background(Color.listItemPrimary)
                                .clipShape(Circle())
                        } else {
                            Circle()
                                .fill(Color.listItemPrimary)
                                .frame(width: 125, height: 125)
                        }
                    }

                    VStack(alignment: .leading, spacing: 5) {
                        Text(viewModel.launch?.launchSite?.siteName ?? "No loaded site name")
                        
                        Text("Launch: \(id ?? "No loaded launch id")")
                            .fontWeight(.bold)
                        
                        let rocketName = viewModel.launch?.rocket?.rocketName ?? "No loaded rocket name"
                        let rocketType = viewModel.launch?.rocket?.rocketType ?? "No loaded rocket type"
                        
                        Text("\(rocketName) (\(rocketType))")
                    }
                    .font(.system(size: 16, weight: .regular, design: .monospaced))
                    .foregroundColor(.white)
                    .redacted(reason: isLoading ? .placeholder : [])
                    
                    Spacer()
                }
                .padding(.bottom, 25)
                
                LaunchDetailRocketSpecification(
                    diameter: viewModel.rocketDiameter,
                    height: viewModel.rocketHeight,
                    mass: viewModel.rocketMass
                )
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 8.0)
                        .stroke(.white.opacity(0.05), lineWidth: 1.0)
                        .background(Color.white.opacity(0.05).cornerRadius(8.0))
                )
                .padding(.bottom, 25)
                .redacted(reason: isLoading ? .placeholder : [])

                Text(description)
                    .lineSpacing(2.5)
                    .foregroundColor(.white )
                    .font(.system(size: 16, weight: .regular, design: .monospaced))
                    .redacted(reason: isLoading ? .placeholder : [])
                    .padding(.bottom, 25)
                
                if let wikipediaUrl = viewModel.launch?.links?.wikipedia {
                    VStack {
                        Button(action: {
                            guard let url = URL(string: wikipediaUrl) else {
                                return
                            }
                            
                            if UIApplication.shared.canOpenURL(url) {
                                UIApplication.shared.open(url)
                            }
                        }, label: {
                            Text("Read more on Wikipedia")
                                .font(.system(size: 14, weight: .medium, design: .monospaced))
                                .foregroundColor(.white)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                        })
                        .buttonStyle(PlainButtonStyle())
                        .background(Capsule().fill(.green))
                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 5.0)
                        .padding(.bottom, 30)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationBarTitleDisplayMode(.inline)
            .padding(.horizontal, 30)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.toggleSave()
                    }) {
                        HStack {
                            Image(systemName: viewModel.isSaved ? "heart.fill" : "heart")
                        }
                        .transition(.opacity)
                    }
                }
            }
        }
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

// MARK: - Components

// MARK: Gallery

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
        
        LaunchDetail(id: "123", missionName: "Mission name", viewModel: viewModel)
    }
}
