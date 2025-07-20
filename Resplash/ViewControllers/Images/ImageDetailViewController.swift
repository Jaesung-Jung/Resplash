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
import Kingfisher
import HostingView

final class ImageDetailViewController: BaseViewController<ImageDetailViewReactor> {
  typealias View = SwiftUI.View

  private let profileView = MiniProfileView()

  private let imageView = UIImageView().then {
    $0.backgroundColor = .systemGray5
    $0.clipsToBounds = true
    $0.layer.cornerRadius = 4
  }

  private let detailView: StatefulHostingView<ImageAssetDetail?>

  private let imageRatio: CGFloat

  override init(reactor: ImageDetailViewReactor? = nil) {
    self.imageRatio = reactor.map(\.initialState.imageAsset).map { CGFloat($0.height) / CGFloat($0.width) } ?? 0
    self.detailView = StatefulHostingView(state: nil) { detail in
      if let detail {
        DetailView(detail: detail)
      }
    }
    super.init(reactor: reactor)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.largeTitleDisplayMode = .never

    let scrollView = UIScrollView()
    view.addSubview(scrollView)
    scrollView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }

    let contentView = UIView()
    scrollView.addSubview(contentView)
    contentView.snp.makeConstraints {
      $0.top.bottom.equalTo(scrollView.contentLayoutGuide).inset(20)
      $0.leading.trailing.equalTo(scrollView.frameLayoutGuide).inset(20)
      $0.width.equalTo(scrollView.contentLayoutGuide)
    }

    contentView.addSubview(profileView)
    profileView.snp.makeConstraints {
      $0.top.leading.trailing.equalToSuperview()
    }

    contentView.addSubview(imageView)
    imageView.snp.makeConstraints {
      $0.top.equalTo(profileView.snp.bottom).offset(8)
      $0.leading.trailing.equalToSuperview()
      $0.height.equalTo(imageView.snp.width).multipliedBy(imageRatio)
    }

    contentView.addSubview(detailView)
    detailView.snp.makeConstraints {
      $0.top.equalTo(imageView.snp.bottom).offset(16)
      $0.leading.trailing.bottom.equalToSuperview()
    }
  }

  override func bind(reactor: ImageDetailViewReactor) {
    reactor.state
      .map(\.imageAsset.description)
      .take(1)
      .bind(to: rx.title)
      .disposed(by: disposeBag)

    reactor.state
      .map(\.imageAsset.user)
      .take(1)
      .bind(to: profileView.rx.user)
      .disposed(by: disposeBag)

    reactor.state
      .map(\.imageAsset.imageResource.hd)
      .take(1)
      .bind(to: imageView.rx.imageURL)
      .disposed(by: disposeBag)

    reactor.state
      .compactMap(\.imageDetail)
      .take(1)
      .bind(to: detailView.rx.state)
      .disposed(by: disposeBag)

    Observable
      .just(.fetchImageDetail)
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
  }
}

// MARK: - ImageDetailViewController.DetailView

extension ImageDetailViewController {
  struct DetailView: View {
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
          .foregroundStyle(.secondary)

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
        .foregroundStyle(.secondary)
      }
    }
  }
}

// MARK: - ImageDetailViewController Preview

#if DEBUG

#Preview {
  UINavigationController(
    rootViewController: ImageDetailViewController(reactor: ImageDetailViewReactor(imageAsset: .preview))
  )
}

#endif
