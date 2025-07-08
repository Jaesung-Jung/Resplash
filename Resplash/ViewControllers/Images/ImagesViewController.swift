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
  private let mediaTypeBarButton = UIBarButtonItem(image: UIImage(systemName: "chevron.down"))

  private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeCollectionViewLayout())

  private lazy var dataSource = makeCollectionViewDataSource(collectionView)

  private let viewModel = ImagesViewModel()

  private var cancellables: Set<AnyCancellable> = []

  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Images"
    navigationItem.trailingItemGroups = [
      UIBarButtonItemGroup(
        barButtonItems: [mediaTypeBarButton],
        representativeItem: nil
      )
    ]

    view.addSubview(collectionView)
    collectionView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }

    viewModel.$state
      .sink { [weak self] state in
        self?.update(state)
      }
      .store(in: &cancellables)

    viewModel.$error
      .sink {
        print($0)
      }
      .store(in: &cancellables)

    viewModel.perform(.fetchImages)
  }
}

// MARK: - ImagesViewController (Private)

extension ImagesViewController {
  private func bindAction() {
  }

  private func update(_ state: ImagesViewModel.State) {
    switch state.mediaType {
    case .photo:
      title = "Photos"
    case .illustration:
      title = "Illustrations"
    }

    mediaTypeBarButton.menu = UIMenu(
      title: "Media Type",
      children: [
        UIAction(title: "Photos", state: state.mediaType == .photo ? .on : .off) { [weak self] _ in
          self?.viewModel.perform(.selectMediaType(.photo))
          self?.viewModel.perform(.fetchImages)
        },
        UIAction(title: "Illustrations", state: state.mediaType == .illustration ? .on : .off) { [weak self] _ in
          self?.viewModel.perform(.selectMediaType(.illustration))
          self?.viewModel.perform(.fetchImages)
        }
      ]
    )

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
    UICollectionViewCompositionalLayout { [weak self] sectionIndex, environemtn in
      guard let section = self?.dataSource.sectionIdentifier(for: sectionIndex) else {
        return NSCollectionLayoutSection(
          group: .horizontal(
            layoutSize: NSCollectionLayoutSize(widthDimension: .absolute(0), heightDimension: .absolute(0)),
            repeatingSubitem: NSCollectionLayoutItem(
              layoutSize: NSCollectionLayoutSize(widthDimension: .absolute(0), heightDimension: .absolute(0))
            ),
            count: 1
          )
        )
      }
      let contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 40, trailing: 20)
      let containerSize = CGSize(
        width: environemtn.container.effectiveContentSize.width - contentInsets.leading - contentInsets.trailing,
        height: environemtn.container.effectiveContentSize.height - contentInsets.top - contentInsets.bottom
      )
      let spacing: CGFloat = 10
      let headerSupplementaryItem = NSCollectionLayoutBoundarySupplementaryItem(
        layoutSize: NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1),
          heightDimension: .estimated(50)
        ),
        elementKind: UICollectionView.elementKindSectionHeader,
        alignment: .top
      )

      switch section {
      case .collections:
        let estimatedWidth = (containerSize.width - spacing) * 0.5
        let itemWidth = estimatedWidth + estimatedWidth * 0.5 + spacing
        let item = NSCollectionLayoutItem(
          layoutSize: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1)
          )
        )
        let group = NSCollectionLayoutGroup
          .horizontal(
            layoutSize: NSCollectionLayoutSize(
              widthDimension: .absolute(itemWidth),
              heightDimension: .absolute(itemWidth)
            ),
            repeatingSubitem: item,
            count: 1
          )
        return NSCollectionLayoutSection(group: group).then {
          $0.interGroupSpacing = spacing
          $0.contentInsets = contentInsets
          $0.boundarySupplementaryItems = [headerSupplementaryItem]
          $0.orthogonalScrollingBehavior = .continuous
        }

      case .images:
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
          $0.boundarySupplementaryItems = [headerSupplementaryItem]
        }
      }
    }
  }

  private func makeCollectionViewDataSource(_ collectionView: UICollectionView) -> UICollectionViewDiffableDataSource<Section, Item> {
    let collectionCellRegistration = UICollectionView.CellRegistration<ImageAssetCollectionCell, ImageAssetCollection> { cell, _, collection in
      cell.configure(collection)
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

    typealias SupplementaryRegistration = UICollectionView.SupplementaryRegistration<CollectionTitleView>
    let supplementaryRegistration = SupplementaryRegistration(elementKind: UICollectionView.elementKindSectionHeader) { [weak self] cell, _, indexPath in
      cell.title = self?.dataSource.sectionIdentifier(for: indexPath.section)?.title
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

    var title: String {
      switch self {
      case .collections:
        return "Collections"
      case .images:
        return "Featured"
      }
    }
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
