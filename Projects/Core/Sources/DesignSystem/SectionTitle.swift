//
//  SectionTitle.swift
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

public struct SectionTitle<Title: View, Subtitle: View>: View {
  let title: Title
  let subtitle: Subtitle
  let disclosureIndicator: Bool

  public init(@ViewBuilder title: () -> Title, @ViewBuilder subtitle: () -> Subtitle, disclosureIndicator: Bool = false) {
    self.title = title()
    self.subtitle = subtitle()
    self.disclosureIndicator = disclosureIndicator
  }

  public var body: some View {
    LabeledContent {
      if disclosureIndicator {
        Image(systemName: "chevron.right")
          .foregroundStyle(.secondary)
      }
    } label: {
      HStack(alignment: .firstTextBaseline) {
        title
        subtitle
      }
      .lineLimit(1)
    }
    .fontWeight(.bold)
    .foregroundStyle(.primary)
    .contentShape(Rectangle())
  }
}

// MARK: - SectionTitle<Text, EmptyView>

extension SectionTitle where Title == Text, Subtitle == EmptyView {
  public init(_ titleKey: LocalizedStringKey, disclosureIndicator: Bool = false) {
    self.init(
      title: { Text(titleKey) },
      subtitle: { EmptyView() },
      disclosureIndicator: disclosureIndicator
    )
  }

  public init<S: StringProtocol>(_ title: S, disclosureIndicator: Bool = false) {
    self.init(
      title: { Text(title).font(.title2) },
      subtitle: { EmptyView() },
      disclosureIndicator: disclosureIndicator
    )
  }
}

// MARK: - SectionTitle<Text, Text>

extension SectionTitle where Title == Text, Subtitle == Text {
  public init(_ titleKey: LocalizedStringKey, subtitle subtitleKey: LocalizedStringKey, disclosureIndicator: Bool = false) {
    self.init(
      title: { Text(titleKey).font(.title2) },
      subtitle: { Text(subtitleKey).font(.subheadline).foregroundStyle(.secondary) },
      disclosureIndicator: disclosureIndicator
    )
  }

  public init<TitleString: StringProtocol, SubtitleString: StringProtocol>(_ title: TitleString, subtitle: SubtitleString, disclosureIndicator: Bool = false) {
    self.init(
      title: { Text(title).font(.title2) },
      subtitle: { Text(subtitle).font(.subheadline).foregroundStyle(.secondary) },
      disclosureIndicator: disclosureIndicator
    )
  }

  public init<S: StringProtocol>(_ title: LocalizedStringKey, subtitle: S, disclosureIndicator: Bool = false) {
    self.init(
      title: { Text(title).font(.title2) },
      subtitle: { Text(subtitle).font(.subheadline).foregroundStyle(.secondary) },
      disclosureIndicator: disclosureIndicator
    )
  }

  public init<S: StringProtocol>(_ title: S, subtitle: LocalizedStringKey, disclosureIndicator: Bool = false) {
    self.init(
      title: { Text(title).font(.title2) },
      subtitle: { Text(subtitle).font(.subheadline).foregroundStyle(.secondary) },
      disclosureIndicator: disclosureIndicator
    )
  }
}

// MARK: - SectionTitle<Text, Subtitle>

extension SectionTitle where Title == Text {
  public init(_ titleKey: LocalizedStringKey, @ViewBuilder subtitle: () -> Subtitle, disclosureIndicator: Bool = false) {
    self.init(
      title: { Text(titleKey).font(.title2) },
      subtitle: subtitle,
      disclosureIndicator: disclosureIndicator
    )
  }

  public init<S: StringProtocol>(_ title: S, @ViewBuilder subtitle: () -> Subtitle, disclosureIndicator: Bool = false) {
    self.init(
      title: { Text(title).font(.title2) },
      subtitle: subtitle,
      disclosureIndicator: disclosureIndicator
    )
  }
}

// MARK: - SectionTitle Preview

#Preview {
  VStack(spacing: 20) {
    SectionTitle("Title")
    SectionTitle("Title with Indicator", disclosureIndicator: true)
    SectionTitle("Title", subtitle: "Subtitle", disclosureIndicator: true)
  }
  .padding(.horizontal, 20)
}
