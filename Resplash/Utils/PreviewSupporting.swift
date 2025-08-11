//
//  PreviewSupporting.swift
//  Resplash
//
//  Created by 정재성 on 8/11/25.
//

#if DEBUG

import SwiftUI

// MARK: - PreviewSupporting

public protocol PreviewSupporting {
}

extension PreviewSupporting where Self: UIView {
  @MainActor public func preview(_ update: (@MainActor (Self) -> Void)? = nil) -> UIViewPreview<Self> {
    UIViewPreview(self, update: update)
  }
}

extension UIView: PreviewSupporting {
}

// MARK: - UIViewPreview

public struct UIViewPreview<Content: UIView>: UIViewRepresentable {
  let content: Content
  let update: (@MainActor (Content) -> Void)?

  init(_ content: Content, update: (@MainActor (Content) -> Void)? = nil) {
    self.content = content
    self.update = update
  }

  public func makeUIView(context: Context) -> Content { content }

  public func updateUIView(_ view: Content, context: Context) {
    update?(view)
  }

  public func sizeThatFits(_ proposal: ProposedViewSize, uiView: Content, context: Context) -> CGSize? {
    let intrinsicContentSize = content.intrinsicContentSize
    let width = intrinsicContentSize.width > 0 ? intrinsicContentSize.width : proposal.width ?? 0
    let height = intrinsicContentSize.height > 0 ? intrinsicContentSize.height : proposal.height ?? 0
    return CGSize(width: width, height: height)
  }

  public func size(width: UIViewPreviewSizeStrategy = .fit, height: UIViewPreviewSizeStrategy = .fit) -> some View {
    ResizableUIViewPreview(self, width: width, height: height)
  }
}

// MARK: - ResizableUIViewPreview

public struct ResizableUIViewPreview<Content: UIView>: UIViewRepresentable {
  let container = UIView()
  let preview: UIViewPreview<Content>
  let widthSize: UIViewPreviewSizeStrategy
  let heightSize: UIViewPreviewSizeStrategy

  init(_ preview: UIViewPreview<Content>, width: UIViewPreviewSizeStrategy, height: UIViewPreviewSizeStrategy) {
    self.preview = preview
    self.widthSize = width
    self.heightSize = height

    container.addSubview(preview.content)
    preview.content.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      preview.content.topAnchor.constraint(equalTo: container.topAnchor),
      preview.content.leadingAnchor.constraint(equalTo: container.leadingAnchor),
      preview.content.bottomAnchor.constraint(equalTo: container.bottomAnchor),
      preview.content.trailingAnchor.constraint(equalTo: container.trailingAnchor)
    ])
  }

  public func makeUIView(context: Context) -> UIView {
    container
  }

  public func updateUIView(_ view: UIView, context: Context) {
    preview.update?(preview.content)
  }

  public func sizeThatFits(_ proposal: ProposedViewSize, uiView: UIView, context: Context) -> CGSize? {
    let width: CGFloat? = switch widthSize {
    case .fit:
      preview.content.intrinsicContentSize.width > 0 ? preview.content.intrinsicContentSize.width : nil
    case .fill:
      proposal.width ?? preview.content.intrinsicContentSize.width
    case .constant(let value):
      value
    }

    let height: CGFloat? = switch heightSize {
    case .fit:
      preview.content.intrinsicContentSize.height > 0 ? preview.content.intrinsicContentSize.height : nil
    case .fill:
      proposal.height ?? preview.content.intrinsicContentSize.height
    case .constant(let value):
      value
    }

    if let width, let height {
      return CGSize(width: width, height: height)
    }

    let targetSize = CGSize(width: width ?? proposal.width ?? 0, height: height ?? proposal.height ?? 0)
    let horizontalPriority: UILayoutPriority = width == nil ? .fittingSizeLevel : .required
    let verticalPriority: UILayoutPriority = height == nil ? .fittingSizeLevel : .required
    return uiView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: horizontalPriority, verticalFittingPriority: verticalPriority)
  }
}

// MARK: - UIViewPreviewSizeStrategy

public enum UIViewPreviewSizeStrategy: ExpressibleByIntegerLiteral, ExpressibleByFloatLiteral {
  case fit
  case fill
  case constant(CGFloat)

  public init(floatLiteral value: FloatLiteralType) {
    self = .constant(CGFloat(value))
  }

  public init(integerLiteral value: IntegerLiteralType) {
    self = .constant(CGFloat(value))
  }
}

#endif
