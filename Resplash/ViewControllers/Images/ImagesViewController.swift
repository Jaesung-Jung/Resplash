//
//  ImagesViewController.swift
//  Resplash
//
//  Created by 정재성 on 7/4/25.
//

import UIKit
import Combine
import SnapKit

final class ImagesViewController: BaseViewController {
  private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeCollectionViewLayout())
  private lazy var dataSource = makeCollectionViewDataSource(collectionView)

  private let viewModel = ImagesViewModel()

  private var cancellables: Set<AnyCancellable> = []

  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Images"
    view.addSubview(collectionView)
    collectionView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }

    viewModel.$state
      .sink { [weak self] state in
        self?.update(state)
      }
      .store(in: &cancellables)

    viewModel.perform(.fetchImages)
  }
}

// MARK: - ImagesViewController (Private)

extension ImagesViewController {
  private func update(_ state: ImagesViewModel.State) {
    var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
    if !state.collections.isEmpty {
      snapshot.appendSections([.collections])
      snapshot.appendItems(state.collections.map(Item.collection))
    }
    if !state.images.isEmpty {
      snapshot.appendSections([.images])
      snapshot.appendItems(state.images.map(Item.image))
    }
    dataSource.apply(snapshot)
  }

  private func makeCollectionViewLayout() -> UICollectionViewLayout {
    UICollectionViewCompositionalLayout { _, environemtn in
      let contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 0, trailing: 20)
      let containerSize = CGSize(
        width: environemtn.container.effectiveContentSize.width - contentInsets.leading - contentInsets.trailing,
        height: environemtn.container.effectiveContentSize.height - contentInsets.top - contentInsets.bottom
      )
      let spacing: CGFloat = 10

      let itemWidth = (containerSize.width - spacing) * 0.5
      let itemHeight = itemWidth
      let item = NSCollectionLayoutItem(
        layoutSize: NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1),
          heightDimension: .estimated(itemHeight)
        )
      )
      let group = NSCollectionLayoutGroup
        .horizontal(
          layoutSize: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(itemHeight)
          ),
          repeatingSubitem: item,
          count: 1
        )
      return NSCollectionLayoutSection(group: group).then {
        $0.interGroupSpacing = spacing
        $0.contentInsets = contentInsets
        $0.boundarySupplementaryItems = [
          NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: NSCollectionLayoutSize(
              widthDimension: .fractionalWidth(1),
              heightDimension: .estimated(50)
            ),
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
          )
        ]
      }
    }
  }

  private func makeCollectionViewDataSource(_ collectionView: UICollectionView) -> UICollectionViewDiffableDataSource<Section, Item> {
    let collectionCellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, ImageAssetCollection> { cell, _, collection in
      cell.backgroundColor = UIColor(hue: .random(in: 0...1), saturation: 1, brightness: 1, alpha: 1)
    }
    let imageCellRegistration = UICollectionView.CellRegistration<ImageAssetCell, ImageAsset> { cell, _, asset in
      cell.configure(asset)
    }
    let dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { collectionView, indexPath, item in
      switch item {
      case .collection(let collection):
        collectionView.dequeueConfiguredReusableCell(using: collectionCellRegistration, for: indexPath, item: collection)
      case .image(let asset):
        collectionView.dequeueConfiguredReusableCell(using: imageCellRegistration, for: indexPath, item: asset)
      }
    }

    let supplementaryRegistration = UICollectionView.SupplementaryRegistration<CollectionTitleView>(elementKind: UICollectionView.elementKindSectionHeader) { cell, _, _ in
      cell.title = "Title"
    }
    dataSource.supplementaryViewProvider = { collectionView, _, indexPath in
      collectionView.dequeueConfiguredReusableSupplementary(using: supplementaryRegistration, for: indexPath)
    }
    return dataSource
  }
}

// MARK: - ImagesViewController.Section

extension ImagesViewController {
  nonisolated enum Section {
    case collections
    case images
  }
}

// MARK: - ImagesViewController.Item

extension ImagesViewController {
  nonisolated enum Item: Hashable {
    case collection(ImageAssetCollection)
    case image(ImageAsset)
  }
}

// MARK: - ImagesViewController

#Preview {
  UINavigationController(rootViewController: ImagesViewController())
}
