//
//  SearchSuggestionViewController.swift
//  Resplash
//
//  Created by 정재성 on 7/30/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class SearchSuggestionViewController: BaseViewController<NoReactor> {
  fileprivate lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeCollectionViewLayout())
  fileprivate lazy var dataSource = makeCollectionViewDataSource(collectionView)

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .app.background

    view.addSubview(collectionView)
    collectionView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
  }

  func updateSuggestions(_ suggestions: [String], query: String) {
    var snapshot = NSDiffableDataSourceSnapshot<Int, Suggestion>()
    snapshot.appendSections([0])
    snapshot.appendItems(suggestions.map { Suggestion(title: $0.capitalized, query: query) }, toSection: 0)
    dataSource.apply(snapshot)
  }
}

// MARK: - SearchSuggestionViewController (Private)

extension SearchSuggestionViewController {
  private func makeCollectionViewLayout() -> UICollectionViewLayout {
    var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
    configuration.showsSeparators = false
    return UICollectionViewCompositionalLayout { _, environment in
      NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: environment).then {
        $0.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
      }
    }
  }

  private func makeCollectionViewDataSource(_ collectionView: UICollectionView) -> UICollectionViewDiffableDataSource<Int, Suggestion> {
    let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Suggestion> { cell, _, suggestion in
      let attributedText = NSMutableAttributedString(
        string: suggestion.title,
        attributes: [
          .foregroundColor: UIColor.app.secondary,
          .font: UIFont.preferredFont(forTextStyle: .title3).withWeight(.bold)
        ]
      )
      let characterSet = Set(suggestion.query.lowercased())
      let attributes: [NSAttributedString.Key: Any] = [
        .foregroundColor: UIColor.app.primary
      ]
      for (index, character) in attributedText.string.enumerated() where characterSet.contains(character.lowercased()) {
        attributedText.addAttributes(attributes, range: NSRange(location: index, length: 1))
      }

      var configuration = cell.defaultContentConfiguration()
      configuration.attributedText = attributedText
      cell.contentConfiguration = configuration
      cell.selectedBackgroundView = UIView().then {
        $0.backgroundColor = .app.gray5
        $0.cornerRadius = 8
      }
    }
    return UICollectionViewDiffableDataSource(collectionView: collectionView) {
      $0.dequeueConfiguredReusableCell(using: cellRegistration, for: $1, item: $2)
    }
  }
}

// MARK: - SearchSuggestionViewController.Suggestion

extension SearchSuggestionViewController {
  struct Suggestion: Hashable {
    let title: String
    let query: String
  }
}

// MARK: - SearchSuggestionViewController (Reactive)

extension Reactive where Base: SearchSuggestionViewController {
  var itemSelected: ControlEvent<String> {
    let source = base.collectionView.rx.itemSelected
      .withUnretained(base.dataSource)
      .compactMap { $0.itemIdentifier(for: $1)?.title }
    return ControlEvent(events: source)
  }
}

// MARK: - SearchSuggestionViewController Preview

#Preview {
  SearchSuggestionViewController().then {
    $0.updateSuggestions(["abstract", "abstract building", "abstract design", "car accident"], query: "abc")
  }
}
