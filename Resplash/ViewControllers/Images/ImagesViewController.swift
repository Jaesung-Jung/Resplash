//
//  ImagesViewController.swift
//  Resplash
//
//  Created by 정재성 on 7/4/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit

final class ImagesViewController: BaseViewController<ImagesViewReactor> {
  private let mediaTypeBarButton = UIBarButtonItem(image: UIImage(systemName: "chevron.down"))

  private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeCollectionViewLayout())
  private lazy var dataSource = makeCollectionViewDataSource(collectionView)

  override func viewDidLoad() {
    super.viewDidLoad()
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
  }

  override func bind(reactor: ImagesViewReactor) {
    let mediaTypeSelected = PublishRelay<MediaType>()

    let mediaType = reactor.state
      .map(\.mediaType)
      .distinctUntilChanged()
      .share(replay: 1)

    mediaType
      .map(\.description)
      .bind(to: rx.title)
      .disposed(by: disposeBag)

    mediaType
      .map { [mediaTypeSelected] in
        UIMenu(
          title: .localized("Media Type"),
          children: [
            UIAction(title: .localized("Photos"), state: $0 == .photo ? .on : .off) { _ in
              mediaTypeSelected.accept(.photo)
            },
            UIAction(title: .localized("Illustrations"), state: $0 == .illustration ? .on : .off) { _ in
              mediaTypeSelected.accept(.illustration)
            }
          ]
        )
      }
      .bind(to: mediaTypeBarButton.rx.menu)
      .disposed(by: disposeBag)

    Observable
      .combineLatest(reactor.pulse(\.$collections), reactor.pulse(\.$images))
      .bind { [weak self] collections, images in
        guard let self else {
          return
        }
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        if !collections.isEmpty {
          snapshot.appendSections([.collections])
          snapshot.appendItems(collections.map(Item.collection))
        }
        if !images.isEmpty {
          snapshot.appendSections([.images])
          snapshot.appendItems(images.map(Item.image))
        }
        dataSource.apply(snapshot)
      }
      .disposed(by: disposeBag)

    mediaTypeSelected
      .map { .selectMediaType($0) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)

    collectionView.rx
      .reachedBottom()
      .skip(1)
      .map { .fetchNextImages }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)

    Observable
      .just(.fetchImages)
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
  }
}

// MARK: - ImagesViewController (Private)

extension ImagesViewController {
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
