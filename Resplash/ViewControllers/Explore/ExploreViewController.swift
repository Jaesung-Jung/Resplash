//
//  ExploreViewController.swift
//  Resplash
//
//  Created by 정재성 on 7/4/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit

final class ExploreViewController: BaseViewController<ExploreViewReactor> {
  private lazy var collectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: makeCollectionViewLayout()
  ).then {
    $0.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
  }
  private lazy var dataSource = makeCollectionViewDataSource(collectionView)

  override func viewDidLoad() {
    super.viewDidLoad()
    title = .localized("Explore")

    view.addSubview(collectionView)
    collectionView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
  }

  override func bind(reactor: ExploreViewReactor) {
    Observable
      .combineLatest(reactor.pulse(\.$categories), reactor.pulse(\.$images))
      .bind { [dataSource] categories, images in
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        for category in categories {
          snapshot.appendSections([.category(category)])
          snapshot.appendItems(category.items.map { .categoryItem($0) }, toSection: .category(category))
        }
        if !images.isEmpty {
          snapshot.appendSections([.popularImages])
          snapshot.appendItems(images.map { .image($0) }, toSection: .popularImages)
        }

        dataSource.apply(snapshot)
      }
      .disposed(by: disposeBag)

    collectionView.rx.itemSelected
      .withUnretained(dataSource)
      .compactMap {
        switch $0.itemIdentifier(for: $1) {
        case .categoryItem(let item):
          return AppStep.categoryImages(item)
        case .image(let image):
          return AppStep.imageDetail(image)
        default:
          return nil
        }
      }
      .bind(to: steps)
      .disposed(by: disposeBag)

    collectionView.rx
      .reachedBottom()
      .map { .fetchPopularImages }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)

    rx.viewDidLoad
      .map { .fetchCategories }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
  }
}

// MARK: - ExploreViewController (Private)

extension ExploreViewController {
  private func makeCollectionViewLayout() -> UICollectionViewLayout {
    UICollectionViewCompositionalLayout { [weak self] sectionIndex, environment in
      guard let self, let section = dataSource.sectionIdentifier(for: sectionIndex) else {
        return nil
      }
      let headerSupplementaryItem = NSCollectionLayoutBoundarySupplementaryItem(
        layoutSize: NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1),
          heightDimension: .estimated(50)
        ),
        elementKind: UICollectionView.elementKindSectionHeader,
        alignment: .top
      )

      switch section {
      case .category:
        let contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 40, trailing: 20)
        let containerSize = CGSize(
          width: environment.container.effectiveContentSize.width - contentInsets.leading - contentInsets.trailing,
          height: environment.container.effectiveContentSize.height - contentInsets.top - contentInsets.bottom
        )
        let spacing: CGFloat = 10
        let itemWidth = (containerSize.width - spacing) * 0.5
        let item = NSCollectionLayoutItem(
          layoutSize: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1)
          )
        )
        let group = NSCollectionLayoutGroup.horizontal(
          layoutSize: NSCollectionLayoutSize(
            widthDimension: .absolute(itemWidth),
            heightDimension: .absolute(itemWidth)
          ),
          subitems: [item]
        ).then {
          $0.interItemSpacing = .fixed(spacing)
        }
        return NSCollectionLayoutSection(group: group).then {
          $0.boundarySupplementaryItems = [headerSupplementaryItem]
          $0.interGroupSpacing = spacing
          $0.contentInsets = contentInsets
          $0.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
        }

      case .popularImages:
        let column = environment.traitCollection.horizontalSizeClass == .compact ? 2 : 4
        let items = dataSource.snapshot(for: section).items.lazy.compactMap { item -> ImageAsset? in
          if case .image(let image) = item {
            return image
          }
          return nil
        }
        return MansonryCollectionLayoutSection(
          columns: column,
          contentInsets: NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 0, trailing: 20),
          spacing: 2,
          environment: environment,
          sizes: items.map { CGSize(width: $0.width, height: $0.height) }
        ).then {
          $0.boundarySupplementaryItems = [headerSupplementaryItem]
        }
      }
    }
  }

  private func makeCollectionViewDataSource(_ collectionView: UICollectionView) -> UICollectionViewDiffableDataSource<Section, Item> {
    let categoryCellRegistration = UICollectionView.CellRegistration<CategoryItemCell, Category.Item> {
      $0.configure($2)
    }
    let imageCellRegistration = UICollectionView.CellRegistration<ImageCell, ImageAsset> {
      $0.configure($2, size: .compact)
    }
    let dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { collectionView, indexPath, item in
      switch item {
      case .categoryItem(let categoryItem):
        collectionView.dequeueConfiguredReusableCell(using: categoryCellRegistration, for: indexPath, item: categoryItem)
      case .image(let image):
        collectionView.dequeueConfiguredReusableCell(using: imageCellRegistration, for: indexPath, item: image)
      }
    }

    typealias SupplementaryRegistration = UICollectionView.SupplementaryRegistration<SupplementaryTitleView>
    let supplementaryRegistration = SupplementaryRegistration(elementKind: UICollectionView.elementKindSectionHeader) { [weak self] view, _, indexPath in
      guard let section = self?.dataSource.sectionIdentifier(for: indexPath.section) else {
        return
      }
      view.title = section.title
    }
    dataSource.supplementaryViewProvider = { collectionView, _, indexPath in
      collectionView.dequeueConfiguredReusableSupplementary(using: supplementaryRegistration, for: indexPath)
    }
    return dataSource
  }
}

// MARK: - ExploreViewController.Section

extension ExploreViewController {
  enum Section: Hashable {
    case category(Category)
    case popularImages

    var title: String {
      switch self {
      case .category(let item):
        return item.title
      case .popularImages:
        return .localized("Popular Images")
      }
    }
  }
}

// MARK: - ExploreViewController.Item

extension ExploreViewController {
  enum Item: Hashable {
    case categoryItem(Category.Item)
    case image(ImageAsset)
  }
}

// MARK: - ExploreViewReactor Preview

#Preview {
  UINavigationController(
    rootViewController: ExploreViewController(reactor: ExploreViewReactor())
  )
}
