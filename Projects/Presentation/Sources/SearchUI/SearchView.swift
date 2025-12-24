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
import ResplashEntities
import ResplashStrings
import ResplashDesignSystem

public struct SearchView: View {
  @Environment(\.layoutEnvironment) var layoutEnvironment
  @Bindable var store: StoreOf<SearchFeature>

  public init(store: StoreOf<SearchFeature>) {
    self.store = store
  }

  public var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 0) {
        if let trends = store.trends {
          ForEach(trends.enumerated(), id: \.element.id) { offset, trend in
            Text("#\(offset + 1). \(trend.title.capitalized)")
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
              .padding(.vertical, 10)
            }
          }
        }
      }
      .padding(layoutEnvironment.contentInsets(.all))
    }
    .overlay {
      if let suggestions = store.suggestions, !suggestions.isEmpty {
        SuggestionsView(query: store.query, suggestions: suggestions) {
          store.send(.selectSuggestion($0))
        }
      }
    }
    .buttonStyle(.ds.plain())
    .navigationTitle(.localizable(.search))
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
      } catch {
      }
    }
  }
}

// MARK: - SearchView Preview

#if DEBUG

import ResplashPreviewSupports

#Preview {
  NavigationStack {
    SearchView(store: Store(initialState: SearchFeature.State()) {
      SearchFeature()
    } withDependencies: {
      $0.unsplash = .preview()
    })
  }
}

#endif
