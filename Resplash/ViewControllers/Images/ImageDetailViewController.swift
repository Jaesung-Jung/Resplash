//
//  ImageDetailViewController.swift
//  Resplash
//
//  Created by 정재성 on 7/14/25.
//

import SwiftUI
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit

final class ImageDetailViewController: BaseViewController<ImageDetailViewReactor> {
  typealias View = SwiftUI.View

  private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeCollectionViewLayout())
  private lazy var dataSource = makeCollectionViewDataSource(collectionView)

  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.largeTitleDisplayMode = .never
    navigationItem.titleView = UIView()

    view.addSubview(collectionView)
    collectionView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
  }

  override func bind(reactor: ImageDetailViewReactor) {
    reactor.state
      .map { $0.image.description ?? $0.image.user.name }
      .bind(to: rx.title)
      .disposed(by: disposeBag)

    Observable
      .combineLatest(
        reactor.state.map(\.image),
        reactor.state.map(\.detail),
        reactor.pulse(\.$relatedImages)
      )
      .bind { [weak dataSource] image, detail, relatedImage in
        guard let dataSource else {
          return
        }
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.detail])
        snapshot.appendItems(to: .detail) {
          Item.profile(image.user)
          Item.image(image)
          if let detail {
            Item.info(detail)
          }
        }

        if let detail {
          snapshot.appendSections([.tags])
          snapshot.appendItems(detail.tags.map(Item.tag), toSection: .tags)
        }

        if !relatedImage.isEmpty {
          snapshot.appendSections([.related])
          snapshot.appendItems(relatedImage.map(Item.relatedImage), toSection: .related)
        }
        dataSource.apply(snapshot)
      }
      .disposed(by: disposeBag)

    collectionView.rx.itemSelected
      .withUnretained(dataSource) { $0.itemIdentifier(for: $1) }
      .compactMap {
        switch $0 {
        case .relatedImage(let image):
          return .navigateToImageDetail(image)
        default:
          return nil
        }
      }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)

    collectionView.rx
      .reachedBottom()
      .map { .fetchNextRelatedImages }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)

    Observable
      .just(.fetchImageDetail)
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
  }
}

// MARK: - ImageDetailViewController (Private)

extension ImageDetailViewController {
  private func makeCollectionViewLayout() -> UICollectionViewLayout {
    UICollectionViewCompositionalLayout { [weak self] sectionIndex, environment in
      guard let self, let section = dataSource.sectionIdentifier(for: sectionIndex) else {
        return nil
      }
      switch section {
      case .detail:
        let item = NSCollectionLayoutItem(
          layoutSize: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(200)
          )
        )
        let group = NSCollectionLayoutGroup.horizontal(
          layoutSize: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(200)
          ),
          subitems: [item]
        )
        return NSCollectionLayoutSection(group: group).then {
          $0.interGroupSpacing = 8
          $0.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
        }
      case .tags:
        let item = NSCollectionLayoutItem(
          layoutSize: NSCollectionLayoutSize(
            widthDimension: .estimated(50),
            heightDimension: .estimated(20)
          )
        )
        let group = NSCollectionLayoutGroup.horizontal(
          layoutSize: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(20)
          ),
          subitems: [item]
        ).then {
          $0.interItemSpacing = .fixed(8)
        }
        return NSCollectionLayoutSection(group: group).then {
          $0.interGroupSpacing = 8
          $0.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 40, trailing: 20)
        }
      case .related:
        let headerSupplementaryItem = NSCollectionLayoutBoundarySupplementaryItem(
          layoutSize: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(50)
          ),
          elementKind: UICollectionView.elementKindSectionHeader,
          alignment: .top
        )
        let column = environment.traitCollection.horizontalSizeClass == .compact ? 2 : 4
        return MansonryCollectionLayoutSection(
          columns: column,
          contentInsets: NSDirectionalEdgeInsets(top: 16, leading: 20, bottom: 0, trailing: 20),
          spacing: 1,
          environment: environment,
          sizes: dataSource.snapshot(for: section).items
            .compactMap {
              if case .relatedImage(let image) = $0 {
                CGSize(width: image.width, height: image.height)
              } else {
                nil
              }
            }
        )
        .then { $0.boundarySupplementaryItems = [headerSupplementaryItem] }
      }
    }
  }

  private func makeCollectionViewDataSource(_ collectionView: UICollectionView) -> UICollectionViewDiffableDataSource<Section, Item> {
    typealias CellRegistration = UICollectionView.CellRegistration
    let userCellRegistration = CellRegistration<ProfileCell, User> { cell, _, user in
      cell.profileView.user = user
    }
    let imageCellRegistration = CellRegistration<DetailImageCell, ImageAsset> { cell, _, image in
      cell.configure(image: image)
    }
    let infoCellRegistration = CellRegistration<UICollectionViewCell, ImageAssetDetail> { cell, _, detail in
      cell.contentConfiguration = UIHostingConfiguration {
        InfoView(detail: detail)
      }
      .margins(.all, .zero)
    }
    let tagCellRegistration = CellRegistration<UICollectionViewCell, ImageAssetDetail.Tag> { cell, _, tag in
      cell.contentConfiguration = UIHostingConfiguration {
        TagView(tag: tag)
      }
      .margins(.all, .zero)
    }
    let relatedImageCellRegistration = UICollectionView.CellRegistration<ImageCell, ImageAsset> { cell, _, image in
      cell.configure(image, size: .compact)
    }
    let dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { collectionView, indexPath, item in
      switch item {
      case .profile(let user):
        collectionView.dequeueConfiguredReusableCell(using: userCellRegistration, for: indexPath, item: user)
      case .image(let image):
        collectionView.dequeueConfiguredReusableCell(using: imageCellRegistration, for: indexPath, item: image)
      case .info(let detail):
        collectionView.dequeueConfiguredReusableCell(using: infoCellRegistration, for: indexPath, item: detail)
      case .tag(let tag):
        collectionView.dequeueConfiguredReusableCell(using: tagCellRegistration, for: indexPath, item: tag)
      case .relatedImage(let image):
        collectionView.dequeueConfiguredReusableCell(using: relatedImageCellRegistration, for: indexPath, item: image)
      }
    }

    typealias SupplementaryRegistration = UICollectionView.SupplementaryRegistration<SupplementaryTitleView>
    let supplementaryRegistration = SupplementaryRegistration(elementKind: UICollectionView.elementKindSectionHeader) { [weak self] view, _, indexPath in
      guard let section = self?.dataSource.sectionIdentifier(for: indexPath.section), section == .related else {
        return
      }
      view.title = .localized("Related Images")
    }
    dataSource.supplementaryViewProvider = { collectionView, _, indexPath in
      collectionView.dequeueConfiguredReusableSupplementary(using: supplementaryRegistration, for: indexPath)
    }
    return dataSource
  }
}

// MARK: - ImageDetailViewController.Section

extension ImageDetailViewController {
  enum Section {
    case detail
    case tags
    case related
  }
}

// MARK: - ImageDetailViewController.Item

extension ImageDetailViewController {
  enum Item: Hashable {
    case profile(User)
    case image(ImageAsset)
    case info(ImageAssetDetail)
    case tag(ImageAssetDetail.Tag)
    case relatedImage(ImageAsset)
  }
}

// MARK: - ImageDetailViewController.ProfileCell

extension ImageDetailViewController {
  private class ProfileCell: UICollectionViewCell {
    let profileView = ProfileView()

    override init(frame: CGRect) {
      super.init(frame: frame)
      contentView.addSubview(profileView)
      profileView.snp.makeConstraints {
        $0.directionalEdges.equalToSuperview()
      }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
  }
}

// MARK: - ImageDetailViewController.DetailImageCell

extension ImageDetailViewController {
  private class DetailImageCell: UICollectionViewCell {
    private let imageView = UIImageView().then {
      $0.backgroundColor = .app.imagePlaceholder
      $0.clipsToBounds = true
      $0.layer.cornerRadius = 4
    }

    private var imageSize: CGSize = .zero

    override init(frame: CGRect) {
      super.init(frame: frame)
      contentView.addSubview(imageView)
      imageView.snp.makeConstraints {
        $0.directionalEdges.equalToSuperview()
      }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }

    func configure(image: ImageAsset) {
      imageSize = CGSize(width: image.width, height: image.height)
      imageView.setImageURL(image.url.hd)
    }

    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
      let ratio = targetSize.width / imageSize.width
      return CGSize(width: targetSize.width, height: imageSize.height * ratio)
    }
  }
}

// MARK: - ImageDetailViewController.TagView

extension ImageDetailViewController {
  struct TagView: View {
    let tag: ImageAssetDetail.Tag

    var body: some View {
      Text(tag.title)
        .font(.subheadline)
        .fontWeight(.medium)
        .foregroundStyle(.app.secondary)
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(.app.gray5)
        .cornerRadius(4)
    }
  }
}

// MARK: - ImageDetailViewController.InfoView

extension ImageDetailViewController {
  struct InfoView: View {
    let detail: ImageAssetDetail

    var body: some View {
      VStack(alignment: .leading, spacing: 16) {
        if let description = detail.description {
          Text(description)
        }

        Grid(alignment: .topLeading, horizontalSpacing: 20) {
          GridRow {
            Text("Views")
            Text("Downloads")
            Text("Featured in")
          }
          .font(.footnote)
          .fontWeight(.medium)
          .foregroundStyle(.app.secondary)

          GridRow {
            Text(detail.views.formatted(.number))
            Text(detail.downloads.formatted(.number))
            HStack {
              Text(([detail.type.description] + detail.topics.map(\.title)).joined(separator: ", "))
              Spacer(minLength: 0)
            }
          }
          .font(.subheadline)
          .fontWeight(.semibold)
        }
        Divider()

        VStack(alignment: .leading, spacing: 8) {
          HStack(spacing: 4) {
            Image(systemName: "calendar")
            Text("Published on \(detail.createdAt.formatted(date: .abbreviated, time: .omitted))")
          }
          HStack(spacing: 4) {
            Image(systemName: "heart.fill")
            Text("\(detail.likes.formatted(.number)) likes")
          }
          if let location = detail.location {
            HStack(spacing: 4) {
              Image(systemName: "location")
              Text(location.name)
            }
          }
          if let exif = detail.exif?.name {
            HStack(spacing: 4) {
              Image(systemName: "camera")
              Text(exif)
            }
          }
        }
        .font(.footnote)
        .fontWeight(.medium)
        .foregroundStyle(.app.secondary)
      }
    }
  }
}

// MARK: - ImageDetailViewController Preview

#if DEBUG

#Preview {
  UINavigationController(
    rootViewController: ImageDetailViewController(reactor: ImageDetailViewReactor(image: .preview))
  )
}

#endif
