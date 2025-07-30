//
//  SearchResultViewController.swift
//  Resplash
//
//  Created by 정재성 on 7/29/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit

final class SearchResultViewController: BaseViewController<SearchResultViewReactor> {
  private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeCollectionViewLayout()).then {
    $0.backgroundColor = .clear
  }

  private lazy var dataSource = makeCollectionViewDataSource(collectionView)

  override func viewDidLoad() {
    super.viewDidLoad()
    view.addSubview(collectionView)
    collectionView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
  }

  override func bind(reactor: SearchResultViewReactor) {
    reactor.state
      .map(\.query)
      .distinctUntilChanged()
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
      .map { .searchNext }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)

    collectionView.rx.itemSelected
      .withUnretained(dataSource)
      .compactMap { $0.itemIdentifier(for: $1) }
      .map { .navigateToImageDetail($0) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)

    Observable.just(.search)
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
  }
}

// MARK: - SearchResultViewController (Private)

extension SearchResultViewController {
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
    let imageCellRegistration = UICollectionView.CellRegistration<ImageCell, ImageAsset> { cell, _, image in
      cell.configure(image, size: .compact)
    }
    return UICollectionViewDiffableDataSource(collectionView: collectionView) {
      $0.dequeueConfiguredReusableCell(using: imageCellRegistration, for: $1, item: $2)
    }
  }
}
