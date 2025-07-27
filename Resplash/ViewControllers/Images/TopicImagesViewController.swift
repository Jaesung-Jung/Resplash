//
//  TopicImagesViewController.swift
//  Resplash
//
//  Created by 정재성 on 7/10/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit

final class TopicImagesViewController: BaseViewController<TopicImagesViewReactor> {
  private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeCollectionViewLayout()).then {
    $0.backgroundColor = .clear
  }

  private lazy var dataSource = makeCollectionViewDataSource(collectionView)

  private let addToCollectionActionRelay = PublishRelay<ImageAsset>()
  private let shareActionReplay = PublishRelay<ImageAsset>()

  private let backgroundImageView = UIImageView().then {
    $0.contentMode = .scaleAspectFill
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.addSubview(collectionView)
    collectionView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }

    let backgroundView = UIView()
    backgroundView.addSubview(backgroundImageView)
    backgroundImageView.snp.makeConstraints {
      $0.top.leading.trailing.equalToSuperview()
      $0.bottom.equalTo(backgroundView.snp.centerY)
    }

    let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
    backgroundView.addSubview(effectView)
    effectView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
    collectionView.backgroundView = backgroundView
  }

  override func bind(reactor: TopicImagesViewReactor) {
    reactor.state
      .map(\.topic.title)
      .take(1)
      .bind(to: rx.title)
      .disposed(by: disposeBag)

    reactor.state
      .map(\.topic.coverImage.url.low)
      .take(1)
      .bind(to: backgroundImageView.rx.imageURL)
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

// MARK: - TopicImagesViewController (Private)

extension TopicImagesViewController {
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

// MARK: - TopicImagesViewController Preview

#Preview {
  UINavigationController(
    rootViewController: TopicImagesViewController(
      reactor: TopicImagesViewReactor(topic: .preview)
    )
  )
}
