//
//  UserProfileView.swift
//
//  Copyright © 2025 Jaesung Jung. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import SwiftUI
import ComposableArchitecture
import ResplashUI
import ResplashEntities
import ResplashDesignSystem

public struct UserProfileView: View {
  typealias TabItem = UserProfileFeature.Tab

  @Environment(\.layoutEnvironment) var layoutEnvironment
  @Namespace var namespace
  @Bindable var store: StoreOf<UserProfileFeature>

  public init(store: StoreOf<UserProfileFeature>) {
    self.store = store
  }

  public var body: some View {
    ScrollView {
      VStack(spacing: 20) {
        CircleImage(store.user.profileImageURL.raw)
          .frame(width: 120, height: 120)

        VStack(spacing: 4) {
          Text(store.user.name)
            .fontWeight(.bold)

          Text("@\(store.user.id)")
            .font(.footnote)
            .foregroundStyle(.secondary)

          HStack {
            if let location = store.user.location {
              IconLabel(icon: Image(.ds.map.pin), text: Text(location), spacing: 2)
            }

            IconLabel(icon: Image(.ds.heart), text: Text(store.user.totalLikes.formatted(.number)), spacing: 2)
          }
          .font(.footnote)
          .foregroundStyle(.secondary)
        }

        if !store.user.socials.isEmpty {
          HStack(spacing: 16) {
            ForEach(store.user.socials, id: \.self) { social in
              if let link = store.user.link(for: social) {
                Link(destination: link) {
                  let imageResource: ImageResource = switch social {
                  case .instagram:
                    .ds.social.instagram
                  case .twitter:
                    .ds.social.x
                  case .paypal:
                    .ds.social.paypal
                  case .portfolio:
                    .ds.social.portfolio
                  }
                  Image(imageResource)
                    .padding(10)
                    .background(Circle().fill(.quaternary))
                }
              }
            }
          }
        }

        if let bio = store.user.bio {
          Text(bio)
            .font(.subheadline)
            .multilineTextAlignment(.center)
            .foregroundStyle(.secondary)
        }

        Divider()

        HStack(spacing: 8) {
          tabItem(.photos, count: store.user.totalPhotos)
          tabItem(.illustrations, count: store.user.totalIllustrations)
          tabItem(.collections, count: store.user.totalCollections)
        }

        switch store.selectedTab {
        case .photos:
          if let images = store.photos?.items, !images.isEmpty {
            imageList(images) {
              store.send(.navigate(.imageDetail($0)))
            }
          } else {
            Text("Empty Photos")
          }
        case .illustrations:
          if let images = store.illustrations?.items, !images.isEmpty {
            imageList(images) {
              store.send(.navigate(.imageDetail($0)))
            }
          } else {
            Text("Empty Illustrations")
          }
        case .collections:
          if let collections = store.collections?.items, !collections.isEmpty {
            LazyVGrid(columns: [GridItem(spacing: 10), GridItem()], spacing: 20) {
              ForEach(collections) { collection in
                Button {
                  store.send(.navigate(.collectionImages(collection)))
                } label: {
                  ImageCollectionView(collection)
                }
                .buttonStyle(.ds.plain())
              }
            }
            .padding(layoutEnvironment.contentInsets([.top, .horizontal]))
          } else {
            Text("Empty Collections")
          }
        }
      }
      .padding(layoutEnvironment.contentInsets(.horizontal))
      .buttonStyle(.ds.plain())
      .animation(.spring, value: store.selectedTab)
    }
    .task {
      store.send(.fetchItems)
    }
  }

  @ViewBuilder func tabItem(_ tab: TabItem, count: Int) -> some View {
    Button {
      store.send(.selectTab(tab))
    } label: {
      VStack(spacing: 4) {
        Text(count.formatted(.number.notation(.compactName)))
          .font(.title3)
          .fontWeight(.semibold)

        let titleKey: LocalizedStringKey = switch tab {
        case .photos:
          .localizable(count > 1 ? .photos : .photo)
        case .illustrations:
          .localizable(count > 1 ? .illustrations : .illustration)
        case .collections:
          .localizable(count > 1 ? .imageCollections : .imageCollection)
        }
        Text(titleKey)
          .font(.caption)
          .foregroundStyle(.secondary)
      }
      .frame(maxWidth: .infinity)
      .padding(.vertical, 12)
      .overlay {
        if tab == store.selectedTab {
          RoundedRectangle(cornerRadius: 12)
            .fill(.quinary)
            .matchedGeometryEffect(id: "tab", in: namespace)
        }
      }
    }
  }

  @ViewBuilder func imageList(_ images: [Unsplash.Image], action: @MainActor @escaping (Unsplash.Image) -> Void) -> some View {
    MansonryGrid(images, columns: 2, spacing: 10) { image in
      Button {
        action(image)
      } label: {
        ImageItemView(image)
          .size(.compact)
          .clipShape(RoundedRectangle(cornerRadius: 8))
      }
    } size: {
      CGSize(width: $0.width, height: $0.height)
    }
    .padding(layoutEnvironment.contentInsets(.horizontal))
  }
}

// MARK: - UserProfileView Preview

#if DEBUG

import ResplashPreviewSupports

#Preview {
  NavigationStack {
    UserProfileView(store: Store(initialState: UserProfileFeature.State(user: .preview1)) {
      UserProfileFeature()
    } withDependencies: {
      $0.unsplash = .preview()
    })
  }
}

#endif
