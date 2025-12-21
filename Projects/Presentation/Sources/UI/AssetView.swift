//
//  AssetView.swift
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
import ResplashEntities
import ResplashDesignSystem

public struct AssetView<MenuContent: View>: View {
  @Environment(\.designSystemSize) var size

  @State var imageLoaded: Bool = false

  let asset: Asset
  let usesMenu: Bool
  let menuContent: MenuContent

  public init(_ asset: Asset, @ViewBuilder menuContent: () -> MenuContent) {
    self.init(asset, usesMenu: true, menuContent: menuContent)
  }

  init(_ asset: Asset, usesMenu: Bool, @ViewBuilder menuContent: () -> MenuContent) {
    self.asset = asset
    self.usesMenu = usesMenu
    self.menuContent = menuContent()
  }

  public var body: some View {
    Rectangle()
      .fill(.clear)
      .background {
        RemoteImage(size == .regular ? asset.url.hd : asset.url.sd, isCompleted: $imageLoaded) {
          $0.resizable().aspectRatio(contentMode: .fill)
        }
      }
      .overlay(alignment: .top) {
        if size == .regular {
          HStack {
            LikeView(asset.likes)
              .foregroundStyle(.white)
              .padding(16)
            Spacer(minLength: 0)
          }
          .background(
            gradient(startPoint: .top, endPoint: .bottom).opacity(imageLoaded ? 1 : 0)
          )
        }
      }
      .overlay(alignment: .bottom) {
        BottomContentLayout {
          if size == .regular {
            UserView(asset.user)
              .foregroundStyle(.white)
          } else {
            UserView(asset.user)
              .hidden()
          }

          if usesMenu {
            Menu {
              menuContent
            } label: {
              Image(systemName: "ellipsis")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxHeight: .infinity)
            }
            .foregroundStyle(.primary)
            .buttonStyle(.glass)
          }
        }
        .padding(16)
        .background(
          gradient(startPoint: .bottom, endPoint: .top).opacity(imageLoaded && size == .regular ? 1 : 0)
        )
      }
      .clipShape(RoundedRectangle(cornerRadius: size == .regular ? 12 : 0))
  }

  @inlinable func gradient(startPoint: UnitPoint, endPoint: UnitPoint) -> some ShapeStyle {
    .linearGradient(
      colors: [.black.opacity(0.5), .black.opacity(0)],
      startPoint: startPoint,
      endPoint: endPoint
    )
  }
}

// MARK: - AssetView<EmptyView>

extension AssetView where MenuContent == EmptyView {
  public init(_ asset: Asset) {
    self.init(asset, usesMenu: false, menuContent: {})
  }
}

// MARK: - AssetView.BottomContentLayout

extension AssetView {
  struct MenuLayout: Layout {
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
      guard let menu = subviews[safe: 0] else {
        return .zero
      }
      let menuSize = menu.sizeThatFits(.unspecified)
      let size = max(menuSize.width, menuSize.height)
      return CGSize(width: size, height: size)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
      guard let menu = subviews[safe: 0] else {
        return
      }
      print("b: \(bounds), p: \(proposal)")
      menu.place(at: bounds.origin, proposal: ProposedViewSize(width: 44, height: 44))
    }
  }

  struct BottomContentLayout: Layout {
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Cache) -> CGSize {
      guard let profile = subviews[safe: 0] else {
        return .zero
      }
      let profileSize = profile.sizeThatFits(.unspecified)
      cache.profileSize = profileSize
      return CGSize(width: proposal.width ?? 0, height: profileSize.height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Cache) {
      guard let profile = subviews[safe: 0] else {
        return
      }
      let intrinsicProfileSize = cache.profileSize ?? profile.sizeThatFits(proposal)
      let menuSize: CGSize
      if let menu = subviews[safe: 1] {
        menuSize = CGSize(width: intrinsicProfileSize.height, height: intrinsicProfileSize.height)
        menu.place(
          at: CGPoint(x: bounds.maxX - menuSize.width, y: bounds.minY),
          proposal: ProposedViewSize(menuSize)
        )
      } else {
        menuSize = .zero
      }

      let profileSize = CGSize(
        width: min(intrinsicProfileSize.width, bounds.width - menuSize.width),
        height: intrinsicProfileSize.height
      )
      profile.place(
        at: CGPoint(x: bounds.minX, y: bounds.minY),
        proposal: ProposedViewSize(profileSize)
      )
    }

    func makeCache(subviews: Subviews) -> Cache { Cache() }

    struct Cache {
      var profileSize: CGSize?
    }
  }
}

// MARK: - ImageAssetView Preview

#if DEBUG

import ResplashPreviewSupports

#Preview {
  VStack(spacing: 20) {
    AssetView(.preview1) {
      Button("Apple", systemImage: "apple.logo") {
      }
      Button("Swift", systemImage: "swift") {
      }
    }
    .size(.compact)
    .frame(height: 200)
    .padding(20)

    AssetView(.preview2) {
      Button("Apple", systemImage: "apple.logo") {
      }
      Button("Swift", systemImage: "swift") {
      }
    }
    .frame(height: 300)
    .padding(20)
  }
}

#endif
