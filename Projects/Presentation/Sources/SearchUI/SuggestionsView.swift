//
//  SuggestionsView.swift
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

struct SuggestionsView: View {
  @Environment(\.layoutEnvironment) var layoutEnvironment

  let query: String
  let suggestions: [Unsplash.SearchSuggestion]
  let action: @MainActor (Unsplash.SearchSuggestion) -> Void

  var body: some View {
    ScrollView {
      VStack(spacing: 0) {
        ForEach(suggestions, id: \.text) { suggestion in
          Button {
            action(suggestion)
          } label: {
            Label {
              Text(attributedString(suggestion.text.capitalized, query: query))
            } icon: {
              Image(systemName: "magnifyingglass.circle.fill")
            }
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
          }
          .font(.title2)
          .fontWeight(.bold)
          .foregroundStyle(.secondary)
          .buttonStyle(.ds.plain(effect: .background(padding: EdgeInsets(top: 0, leading: -8, bottom: 0, trailing: -8))))
        }
      }
      .padding(layoutEnvironment.contentInsets(.horizontal))
    }
    .background(.background)
  }

  func attributedString(_ suggestion: String, query: String) -> AttributedString {
    var attributedString = AttributedString(suggestion)
    let characterSet = Set(query.lowercased())
    for (offset, character) in suggestion.enumerated() where characterSet.contains(character.lowercased()) {
      let index = suggestion.index(suggestion.startIndex, offsetBy: offset)
      let range = index..<suggestion.index(after: index)
      if let lower = AttributedString.Index(range.lowerBound, within: attributedString), let upper = AttributedString.Index(range.upperBound, within: attributedString) {
        attributedString[lower..<upper].foregroundColor = .primary
      }
    }
    return attributedString
  }
}

// MARK: - SuggestionsView Preview

#if DEBUG

#Preview {
  SuggestionsView(
    query: "Lake",
    suggestions: [
      Unsplash.SearchSuggestion(text: "Lake", priority: 0),
      Unsplash.SearchSuggestion(text: "Lake Como", priority: 0),
      Unsplash.SearchSuggestion(text: "Lake District", priority: 0),
      Unsplash.SearchSuggestion(text: "Lake Nature", priority: 0),
      Unsplash.SearchSuggestion(text: "Lake Tahoe", priority: 0),
      Unsplash.SearchSuggestion(text: "Lake Lavender", priority: 0),
      Unsplash.SearchSuggestion(text: "Mountain Lake", priority: 0),
      Unsplash.SearchSuggestion(text: "Salt Lake City", priority: 0)
    ],
    action: { _ in
    }
  )
}

#endif
