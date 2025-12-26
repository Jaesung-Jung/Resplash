//
//  UserView.swift
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

public struct UserView: View {
  @Environment(\.designSystemSize) var size
  let user: Unsplash.User

  public init(_ user: Unsplash.User) {
    self.user = user
  }

  public var body: some View {
    switch size {
    case .regular:
      RegularContent(user: user)
    case .compact:
      CompactContent(user: user)
    }
  }
}

// MARK: - UserView.Size

extension UserView {
  public enum Size: Sendable {
    case regular
    case compact
  }
}

// MARK: - UserView.RegularContent

extension UserView {
  struct RegularContent: View {
    @Environment(\.colorScheme) var colorScheme
    let user: Unsplash.User

    var body: some View {
      ContentLayout(forHire: user.forHire, imageSpacing: 8, textSpacing: 2) {
        RemoteImage(user.profileImageURL.medium) {
          $0.resizable()
            .aspectRatio(1, contentMode: .fill)
        }
        .clipShape(Circle())
        .overlay {
          Circle()
            .strokeBorder(colorScheme == .dark ? .primary : .quinary, lineWidth: 1)
        }

        Text(user.name)
          .font(.body)
          .fontWeight(.bold)

        Text(user.id)
          .font(.caption)
          .foregroundStyle(.secondary)
      }
      .lineLimit(1)
    }

    struct ContentLayout: Layout {
      let forHire: Bool
      let imageSpacing: CGFloat
      let textSpacing: CGFloat

      func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Cache) -> CGSize {
        guard let image = subviews[safe: 0], let name = subviews[safe: 1], let hire = subviews[safe: 2] else {
          return .zero
        }
        let intrinsicImageSize = image.sizeThatFits(.unspecified)
        let intrinsicNameSize = name.sizeThatFits(.unspecified)
        let intrinsicHireSize = hire.sizeThatFits(.unspecified)
        let intrinsicTextSize = CGSize(
          width: max(intrinsicNameSize.width, intrinsicHireSize.width),
          height: intrinsicNameSize.height + textSpacing + intrinsicHireSize.height
        )

        let ratio = if intrinsicImageSize.height > 0 { intrinsicTextSize.height / intrinsicImageSize.height } else { CGFloat(0) }
        let imageSize = CGSize(
          width: intrinsicImageSize.width * ratio,
          height: intrinsicImageSize.height * ratio
        )

        let availableSize = ProposedViewSize(
          width: proposal.width.map { max(0, $0 - imageSize.width - imageSpacing) },
          height: proposal.height
        )
        let nameSize = name.sizeThatFits(availableSize)
        let hireSize = hire.sizeThatFits(availableSize)

        cache.imageSize = imageSize
        cache.nameSize = nameSize
        cache.hireSize = hireSize

        return CGSize(
          width: imageSize.width + imageSpacing + max(nameSize.width, hireSize.width),
          height: nameSize.height + textSpacing + hireSize.height
        )
      }

      func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Cache) {
        guard let image = subviews[safe: 0], let name = subviews[safe: 1], let hire = subviews[safe: 2] else {
          return
        }
        let imageSize = cache.imageSize ?? .zero
        image.place(
          at: CGPoint(x: bounds.minX, y: bounds.minY),
          anchor: .topLeading,
          proposal: ProposedViewSize(imageSize)
        )

        let nameSize = cache.nameSize ?? .zero
        let hireSize = cache.hireSize ?? .zero
        if forHire {
          let namePoint = CGPoint(x: bounds.minX + imageSize.width + imageSpacing, y: bounds.minY)
          name.place(at: namePoint, anchor: .topLeading, proposal: ProposedViewSize(nameSize))

          let hirePoint = CGPoint(x: namePoint.x, y: namePoint.y + nameSize.height + textSpacing)
          hire.place(at: hirePoint, anchor: .topLeading, proposal: ProposedViewSize(hireSize))
        } else {
          let point = CGPoint(x: bounds.minX + imageSize.width + imageSpacing, y: bounds.midY - nameSize.height * 0.5)
          name.place(at: point, anchor: .topLeading, proposal: ProposedViewSize(nameSize))
          hire.place(at: .zero, proposal: .zero)
        }
      }

      func makeCache(subviews: Subviews) -> Cache { Cache() }

      struct Cache {
        var imageSize: CGSize?
        var nameSize: CGSize?
        var hireSize: CGSize?
      }
    }
  }
}

// MARK: - UserView.CompactContent

extension UserView {
  struct CompactContent: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.displayScale) var displayScale
    let user: Unsplash.User

    var body: some View {
      IconLabel(spacing: 8) {
        RemoteImage(user.profileImageURL.medium) {
          $0.resizable()
            .aspectRatio(1, contentMode: .fill)
        }
        .clipShape(Circle())
        .overlay {
          Circle()
            .strokeBorder(colorScheme == .dark ? .primary : .quinary, lineWidth: 1 / displayScale)
        }
      } content: {
        Text(user.name)
          .font(.subheadline)
          .fontWeight(.semibold)
          .frame(minHeight: 32)
      }
    }
  }
}

// MARK: - ProfileView Preview

#if DEBUG

import ResplashPreviewSupports

struct TestStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .scaleEffect(configuration.isPressed ? 1.1 : 1)
      .animation(.spring(duration: 0.3, bounce: 0.2), value: configuration.isPressed)
  }
}

#Preview {
  VStack(alignment: .leading, spacing: 40) {
    UserView(.preview1)
    UserView(.preview2)
      .size(.compact)
  }
}

#endif
