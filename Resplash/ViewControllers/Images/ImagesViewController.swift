//
//  ImagesViewController.swift
//  Resplash
//
//  Created by 정재성 on 7/27/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit

final class ImagesViewController: BaseViewController<ImagesViewReactor> {
  private lazy var collectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: makeCollectionViewLayout()
  )

  private lazy var dataSource = makeCollectionViewDataSource(collectionView)

  private let addToCollectionActionRelay = PublishRelay<ImageAsset>()
  private let shareActionReplay = PublishRelay<ImageAsset>()

  override func viewDidLoad() {
    super.viewDidLoad()
    view.addSubview(collectionView)
    collectionView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
  }

  override func bind(reactor: ImagesViewReactor) {
    reactor.state
      .map(\.title)
      .take(1)
      .bind(to: rx.title)
      .disposed(by: disposeBag)

    reactor
      .pulse(\.$images)
      .bind { [dataSource] images in
        var snapshot = NSDiffableDataSourceSnapshot<Int, ImageAsset>()
        snapshot.appendSections([0])
        snapshot.appendItems(images, toSection: 0)
        dataSource.apply(snapshot)
      }
      .disposed(by: disposeBag)

    collectionView.rx
      .reachedBottom()
      .map { .fetchNextImages }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)

    collectionView.rx.itemSelected
      .withUnretained(dataSource)
      .compactMap { $0.itemIdentifier(for: $1) }
      .map { .navigateToImageDetail($0) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)

    Observable.just(.fetchImages)
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
  }
}

// MARK: - ImagesViewController (Private)

extension ImagesViewController {
  private func makeCollectionViewLayout() -> UICollectionViewLayout {
    UICollectionViewCompositionalLayout { [weak self] section, environment in
      let column = environment.traitCollection.horizontalSizeClass == .compact ? 2 : 4
      let items = self?.dataSource.snapshot(for: section).items ?? []
      return MansonryCollectionLayoutSection(
        columns: column,
        contentInsets: .zero,
        spacing: 2,
        environment: environment,
        sizes: items.map { CGSize(width: $0.width, height: $0.height) }
      )
    }
  }

  private func makeCollectionViewDataSource(_ collectionView: UICollectionView) -> UICollectionViewDiffableDataSource<Int, ImageAsset> {
    let addToCollection = addToCollectionActionRelay
    let share = shareActionReplay
    let imageCellRegistration = UICollectionView.CellRegistration<ImageCell, ImageAsset> { cell, _, image in
      cell.configure(image)
      cell.menuButtonSize = .small
      cell.isBorderHidden = true
      cell.isProfileHidden = true
      cell.cornerRadius = 0
      cell.menu = UIMenu(
        children: [
          UIAction(title: "Add to Collection", image: UIImage(systemName: "rectangle.stack.badge.plus")) { _ in
            addToCollection.accept(image)
          },
          UIAction(title: "Share", image: UIImage(systemName: "square.and.arrow.up")) { _ in
            share.accept(image)
          }
        ]
      )
    }
    return UICollectionViewDiffableDataSource(collectionView: collectionView) {
      $0.dequeueConfiguredReusableCell(using: imageCellRegistration, for: $1, item: $2)
    }
  }
}

// MARK: - ImagesViewController Preview

#Preview {
  UINavigationController(
    rootViewController: ImagesViewController(
      reactor: ImagesViewReactor(title: "Images") {
        UnsplashService.previewValue.photos(page: $0)
      }
    )
  )
}
