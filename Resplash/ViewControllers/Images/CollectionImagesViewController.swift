//
//  CollectionImagesViewController.swift
//  Resplash
//
//  Created by 정재성 on 7/12/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit
import Kingfisher

final class CollectionImagesViewController: BaseViewController<CollectionImagesViewReactor> {
  private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeCollectionViewLayout()).then {
    $0.backgroundColor = .clear
  }

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

  override func bind(reactor: CollectionImagesViewReactor) {
    reactor.state
      .map(\.collection.title)
      .take(1)
      .bind(to: rx.title)
      .disposed(by: disposeBag)

    reactor
      .pulse(\.$images)
      .bind { [dataSource] images in
        var snapshot = NSDiffableDataSourceSnapshot<Int, ImageAsset>()
        snapshot.appendSections([0])
        snapshot.appendItems(Array(images), toSection: 0)
        dataSource.apply(snapshot)
      }
      .disposed(by: disposeBag)

    collectionView.rx
      .reachedBottom()
      .map { .fetchNextImages }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)

    Observable.just(.fetchImages)
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
  }
}

// MARK: - CollectionImagesViewController (Private)

extension CollectionImagesViewController {
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
    let imageCellRegistration = UICollectionView.CellRegistration<ImageAssetCell, ImageAsset> { cell, _, asset in
      cell.configure(asset)
      cell.menuButtonSize = .small
      cell.isBorderHidden = true
      cell.isProfileHidden = true
      cell.isBottomGradientHidden = true
      cell.cornerRadius = 0
      cell.menu = UIMenu(
        children: [
          UIAction(title: "Add to Collection", image: UIImage(systemName: "rectangle.stack.badge.plus")) { _ in
            addToCollection.accept(asset)
          },
          UIAction(title: "Share", image: UIImage(systemName: "square.and.arrow.up")) { _ in
            share.accept(asset)
          }
        ]
      )
    }
    return UICollectionViewDiffableDataSource(collectionView: collectionView) {
      $0.dequeueConfiguredReusableCell(using: imageCellRegistration, for: $1, item: $2)
    }
  }
}

// MARK: - CollectionImagesViewController Preview

#Preview {
  UINavigationController(
    rootViewController: CollectionImagesViewController(
      reactor: CollectionImagesViewReactor(collection: .preview)
    )
  )
}
