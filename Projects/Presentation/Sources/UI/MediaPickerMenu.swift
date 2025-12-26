//
//  MediaPickerMenu.swift
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
import ResplashStrings

public struct MediaPickerMenu: View {
  @Binding var selectedMediaType: Unsplash.MediaType

  public init(mediaType: Binding<Unsplash.MediaType>) {
    self._selectedMediaType = mediaType
  }

  public var body: some View {
    Menu {
      Section(.localizable(.media)) {
        ForEach(Unsplash.MediaType.allCases, id: \.self) { mediaType in
          Button {
            if selectedMediaType != mediaType {
              selectedMediaType = mediaType
            }
          } label: {
            HStack {
              if selectedMediaType == mediaType {
                Image(systemName: "checkmark")
              }
              Text(localizedString(mediaType))
            }
          }
        }
      }
    } label: {
      HStack {
        let systemName = switch selectedMediaType {
        case .photo:
          "photo.on.rectangle.angled"
        case .illustration:
          "pencil.and.scribble"
        }
        Image(systemName: systemName)
        Text(localizedString(selectedMediaType))
      }
    }
  }

  @inlinable func localizedString(_ mediaType: Unsplash.MediaType) -> LocalizedStringKey {
    switch mediaType {
    case .photo:
      return .localizable(.photo)
    case .illustration:
      return .localizable(.illustration)
    }
  }
}
