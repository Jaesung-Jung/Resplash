//
//  ImageDetailView.swift
//  Resplash
//
//  Created by 정재성 on 8/24/25.
//

import SwiftUI
import ComposableArchitecture

struct ImageDetailView: View {
  let store: StoreOf<ImageDetailFeature>

  var body: some View {
    ScrollView {
      VStack(spacing: 8) {
        HStack(spacing: 0) {
          ProfileView(store.state.image.user)
          Spacer(minLength: 0)
        }

        RemoteImage(store.state.image.url.hd) {
          $0.resizable()
            .aspectRatio(CGSize(width: 1, height: store.state.image.width / store.state.image.height), contentMode: .fit)
        }
        .cornerRadius(4)


      }
      .padding(.horizontal, 20)
    }
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .principal) {
        Text("Image").opacity(0)
      }
    }
  }
}

// MARK: - ImageDetailView Preview

#Preview {
  NavigationStack {
    ImageDetailView(
      store: Store(initialState: ImageDetailFeature.State(image: .preview)) {
        ImageDetailFeature()
      }
    )
  }
}
