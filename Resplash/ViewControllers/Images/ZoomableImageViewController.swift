//
//  ZoomableImageViewController.swift
//  Resplash
//
//  Created by 정재성 on 7/27/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class ZoomableImageViewController: UIViewController {
  private let imageView = ZoomableImageView()

  private let closeButton = UIButton(configuration: .glass(.plain())).then {
    $0.configuration?.image = UIImage(systemName: "xmark")
    $0.configuration?.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(font: .preferredFont(forTextStyle: .subheadline).withWeight(.bold))
      .applying(UIImage.SymbolConfiguration(hierarchicalColor: .white.withAlphaComponent(0.5)))
    $0.configuration?.background.backgroundInsets = NSDirectionalEdgeInsets(top: -5, leading: -5, bottom: -5, trailing: -5)
    if #unavailable(iOS 26.0) {
      $0.configuration?.background.visualEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
      $0.configuration?.cornerStyle = .capsule
    }
  }

  private let disposeBag = DisposeBag()

  init(image: UIImage) {
    super.init(nibName: nil, bundle: nil)
    imageView.image = image
    modalPresentationStyle = .fullScreen
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .black

    view.addSubview(imageView)
    imageView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }

    view.addSubview(closeButton)
    closeButton.snp.makeConstraints {
      $0.top.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
    }

    closeButton.rx.tap
      .bind { [weak self] _ in
        self?.dismiss(animated: true)
      }
      .disposed(by: disposeBag)
  }
}

// MARK: - ZoomableImageViewController

#Preview {
  ZoomableImageViewController(image: .actions)
}
