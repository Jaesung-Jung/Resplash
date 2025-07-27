//
//  MainViewController.swift
//  Resplash
//
//  Created by 정재성 on 7/4/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit

final class MainViewController: BaseViewController<MainViewReactor> {
  private let mediaTypeBarButton = UIBarButtonItem(image: UIImage(systemName: "chevron.down"))

  private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeCollectionViewLayout()).then {
    $0.backgroundColor = .clear
    $0.refreshControl = refreshControl
  }
  private lazy var dataSource = makeCollectionViewDataSource(collectionView)

  private let refreshControl = UIRefreshControl()

  private let addToCollectionActionRelay = PublishRelay<ImageAsset>()
  private let shareActionReplay = PublishRelay<ImageAsset>()
  private let moreCollectionActionRelay = PublishRelay<Void>()

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

  override func bind(reactor: MainViewReactor) {
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

    reactor.state
      .map { !$0.isLoading }
      .distinctUntilChanged()
      .bind(to: refreshControl.rx.isEnabled)
      .disposed(by: disposeBag)

    reactor.state
      .map(\.isRefreshing)
      .distinctUntilChanged()
      .bind(to: refreshControl.rx.isRefreshing)
      .disposed(by: disposeBag)

    Observable
      .combineLatest(reactor.pulse(\.$topics), reactor.pulse(\.$collections), reactor.pulse(\.$images))
      .bind { [weak self] topics, collections, images in
        guard let self else {
          return
        }
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        if !topics.isEmpty {
          snapshot.appendSections([.topics])
          snapshot.appendItems(topics.map(Item.topic), toSection: .topics)
        }
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

    shareActionReplay
      .map(\.shareLink)
      .map { .share($0) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)

    moreCollectionActionRelay
      .withLatestFrom(reactor.state.map(\.mediaType))
      .map { .navigateToCollection($0) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)

    collectionView.rx
      .reachedBottom()
      .map { .fetchNextImages }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)

    collectionView.rx.itemSelected
      .withUnretained(dataSource)
      .compactMap { $0.itemIdentifier(for: $1) }
      .map {
        switch $0 {
        case .topic(let topic):
          return .navigateToTopicImages(topic)
        case .collection(let collection):
          return .navigateToCollectionImages(collection)
        case .image(let image):
          return .navigateToImageDetail(image)
        }
      }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)

    refreshControl.rx
      .controlEvent(.valueChanged)
      .startWith(())
      .map { .refresh }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)

    Observable
      .just(.fetch)
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
  }
}

// MARK: - MainViewController (Private)

extension MainViewController {
  private func makeCollectionViewLayout() -> UICollectionViewLayout {
    UICollectionViewCompositionalLayout { [weak self] sectionIndex, environment in
      guard let section = self?.dataSource.sectionIdentifier(for: sectionIndex) else {
        return nil
      }
      let contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 40, trailing: 20)
      let containerSize = CGSize(
        width: environment.container.effectiveContentSize.width - contentInsets.leading - contentInsets.trailing,
        height: environment.container.effectiveContentSize.height - contentInsets.top - contentInsets.bottom
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
      case .topics:
        let size = NSCollectionLayoutSize(
          widthDimension: .estimated(100),
          heightDimension: .estimated(30)
        )
        let item = NSCollectionLayoutItem(layoutSize: size)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, repeatingSubitem: item, count: 1)
        return NSCollectionLayoutSection(group: group).then {
          $0.interGroupSpacing = spacing
          $0.contentInsets = contentInsets
          $0.orthogonalScrollingBehavior = .continuous
        }

      case .collections:
        let estimatedWidth = (containerSize.width - spacing) * 0.5
        let itemWidth = estimatedWidth + estimatedWidth * 0.5 - contentInsets.trailing + 2
        let item = NSCollectionLayoutItem(
          layoutSize: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(itemWidth)
          )
        )
        let group = NSCollectionLayoutGroup
          .horizontal(
            layoutSize: NSCollectionLayoutSize(
              widthDimension: .absolute(itemWidth),
              heightDimension: .estimated(itemWidth)
            ),
            repeatingSubitem: item,
            count: 1
          )
        return NSCollectionLayoutSection(group: group).then {
          $0.interGroupSpacing = spacing
          $0.contentInsets = contentInsets
          $0.boundarySupplementaryItems = [headerSupplementaryItem]
          $0.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
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
    let topicCellRegistration = UICollectionView.CellRegistration<TopicCell, Topic> {
      $0.configure($2)
    }
    let collectionCellRegistration = UICollectionView.CellRegistration<ImageCollectionCell, ImageAssetCollection> {
      $0.configure($2)
    }

    let addToCollection = addToCollectionActionRelay
    let share = shareActionReplay
    let imageCellRegistration = UICollectionView.CellRegistration<ImageCell, ImageAsset> { cell, _, image in
      cell.configure(image, size: .regular)
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

    let dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { collectionView, indexPath, item in
      switch item {
      case .topic(let topic):
        collectionView.dequeueConfiguredReusableCell(using: topicCellRegistration, for: indexPath, item: topic)
      case .collection(let collection):
        collectionView.dequeueConfiguredReusableCell(using: collectionCellRegistration, for: indexPath, item: collection)
      case .image(let image):
        collectionView.dequeueConfiguredReusableCell(using: imageCellRegistration, for: indexPath, item: image)
      }
    }

    typealias SupplementaryRegistration = UICollectionView.SupplementaryRegistration<SupplementaryTitleView>
    let moreCollection = moreCollectionActionRelay
    let supplementaryRegistration = SupplementaryRegistration(elementKind: UICollectionView.elementKindSectionHeader) { [weak self] view, _, indexPath in
      guard let section = self?.dataSource.sectionIdentifier(for: indexPath.section) else {
        return
      }
      switch section {
      case .topics:
        break
      case .collections:
        view.title = section.title
        view.action = UIAction(title: .localized("More"), image: UIImage(systemName: "chevron.right")) { _ in
          moreCollection.accept(())
        }
      case .images:
        view.title = section.title
        view.action = nil
      }
    }
    dataSource.supplementaryViewProvider = { collectionView, _, indexPath in
      collectionView.dequeueConfiguredReusableSupplementary(using: supplementaryRegistration, for: indexPath)
    }
    return dataSource
  }
}

// MARK: - MainViewController.Section

extension MainViewController {
  nonisolated enum Section {
    case topics
    case collections
    case images

    var title: String {
      switch self {
      case .topics:
        return .localized("Topics")
      case .collections:
        return .localized("Collections")
      case .images:
        return .localized("Featured")
      }
    }
  }
}

// MARK: - MainViewController.Item

extension MainViewController {
  nonisolated enum Item: Hashable {
    case topic(Topic)
    case collection(ImageAssetCollection)
    case image(ImageAsset)
  }
}

// MARK: - MainViewController

#Preview {
  UINavigationController(
    rootViewController: MainViewController(reactor: MainViewReactor())
  )
}
