//
//  SearchView.swift
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

struct SearchView: View {
  @Bindable var store: StoreOf<SearchFeature>

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 0) {
        if let trends = store.trends {
          ForEach(trends.enumerated(), id: \.element.id) { offset, trend in
            Text("#\(offset + 1). \(trend.title)")
              .font(.body)
              .fontWeight(.bold)
              .foregroundStyle(.secondary)
              .padding(.bottom, 10)
              .padding(.top, offset == 0 ? 0 : 20)

            ForEach(trend.keywords) { keyword in
              Button {
                store.send(.selectKeyword(keyword))
              } label: {
                TrendKeywordView(keyword)
              }
              .foregroundStyle(.primary)
              .padding(.vertical, 10)
            }
          }
        }
      }
      .padding(.top, 10)
      .padding(.bottom, 40)
      .padding(.horizontal, 20)
    }
    .overlay {
      if let suggestions = store.suggestion?.suggestions, !suggestions.isEmpty {
        suggestionView(suggestions)
      }
    }
    .navigationTitle("Search")
    .scrollDismissesKeyboard(.immediately)
    .searchable(text: $store.query.sending(\.updateQuery))
    .onSubmit(of: .search) {
      store.send(.search)
    }
    .task {
      store.send(.fetchTrends)
    }
    .task(id: store.query) {
      do {
        try await Task.sleep(for: .milliseconds(300))
        await store.send(.fetchSuggestion).finish()
      } catch {}
    }
  }

  @ViewBuilder func suggestionView(_ suggestions: [String]) -> some View {
    ScrollView {
      VStack {
        ForEach(suggestions, id: \.self) { suggestion in
          Button {
            store.send(.selectSuggestion(suggestion))
          } label: {
            HStack {
              Label {
                Text(attributedString(suggestion.capitalized, query: store.query))
              } icon: {
                Image(systemName: "magnifyingglass.circle.fill")
              }
              Spacer()
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 12)
          }
          .buttonStyle(ListButtonStyle())
          .font(.title3)
          .fontWeight(.bold)
          .foregroundStyle(.secondary)
        }
        Spacer()
      }
      .padding(.horizontal, 8)
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

// MARK: - SearchView Preview

#if DEBUG

#Preview {
  SearchView(
    store: Store(initialState: SearchFeature.State()) {
      SearchFeature()
    }
  )
}

#endif
