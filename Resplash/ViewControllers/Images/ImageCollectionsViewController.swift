//
//  ImageCollectionsViewController.swift
//  Resplash
//
//  Created by 정재성 on 7/10/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit

final class ImageCollectionsViewController: BaseViewController<ImageCollectionsViewReactor> {
  private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeCollectionViewLayout()).then {
    $0.backgroundColor = .clear
  }

  private lazy var dataSource = makeCollectionViewDataSource(collectionView)

  override func viewDidLoad() {
    super.viewDidLoad()
    title = .localized("Collections")

    view.addSubview(collectionView)
    collectionView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
  }

  override func bind(reactor: ImageCollectionsViewReactor) {
    reactor
      .pulse(\.$collections)
      .bind { [dataSource] collections in
        var snapshot = NSDiffableDataSourceSnapshot<Int, ImageAssetCollection>()
        snapshot.appendSections([0])
        snapshot.appendItems(Array(collections), toSection: 0)
        dataSource.apply(snapshot)
      }
      .disposed(by: disposeBag)

    collectionView.rx
      .reachedBottom()
      .map { .fetchNextCollections }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)

    collectionView.rx.itemSelected
      .withLatestFrom(reactor.pulse(\.$collections)) { $1[$0.item] }
      .map { .navigateToCollectionImages($0) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)

    Observable
      .just(.fetchCollections)
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
  }
}

// MARK: - ImageCollectionsViewController (Private)

extension ImageCollectionsViewController {
  private func makeCollectionViewLayout() -> UICollectionViewLayout {
    UICollectionViewCompositionalLayout { _, environment in
      let contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)
      let containerSize = CGSize(
        width: environment.container.effectiveContentSize.width - contentInsets.leading - contentInsets.trailing,
        height: environment.container.effectiveContentSize.height - contentInsets.top - contentInsets.bottom
      )
      let spacing: CGFloat = 10
      let itemWidth = (containerSize.width - spacing) * 0.5
      let item = NSCollectionLayoutItem(
        layoutSize: NSCollectionLayoutSize(
          widthDimension: .absolute(itemWidth),
          heightDimension: .estimated(itemWidth)
        )
      )
      let group = NSCollectionLayoutGroup
        .horizontal(
          layoutSize: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(itemWidth)
          ),
          repeatingSubitem: item,
          count: 2
        )
        .then {
          $0.interItemSpacing = .fixed(spacing)
        }
      return NSCollectionLayoutSection(group: group).then {
        $0.interGroupSpacing = spacing * 2
        $0.contentInsets = contentInsets
      }
    }
  }

  private func makeCollectionViewDataSource(_ collectionView: UICollectionView) -> UICollectionViewDiffableDataSource<Int, ImageAssetCollection> {
    let imageCellRegistration = UICollectionView.CellRegistration<ImageCollectionCell, ImageAssetCollection> {
      $0.configure($2)
    }
    return UICollectionViewDiffableDataSource(collectionView: collectionView) {
      $0.dequeueConfiguredReusableCell(using: imageCellRegistration, for: $1, item: $2)
    }
  }
}

// MARK: - ImageCollectionsViewController Preview

#Preview {
  UINavigationController(
    rootViewController: ImageCollectionsViewController(
      reactor: ImageCollectionsViewReactor(mediaType: .photo)
    )
  )
}
