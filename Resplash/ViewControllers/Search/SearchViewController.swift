//
//  SearchViewController.swift
//  Resplash
//
//  Created by 정재성 on 7/9/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit

final class TestController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemGreen
  }
}

final class SearchViewController: BaseViewController<SearchViewReactor> {
  private let searchController: UISearchController
  private let searchSuggestionViewController: SearchSuggestionViewController

  private lazy var collectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: makeCollectionViewLayout()
  ).then {
    $0.keyboardDismissMode = .onDrag
    $0.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
  }

  private lazy var dataSource = makeCollectionViewDataSource(collectionView)

  override init(reactor: SearchViewReactor? = nil) {
    searchSuggestionViewController = SearchSuggestionViewController()
    searchController = UISearchController(searchResultsController: searchSuggestionViewController)
    super.init(reactor: reactor)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    title = .localized("Search")
    navigationItem.searchController = searchController

    view.addSubview(collectionView)
    collectionView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    let collectionView = searchSuggestionViewController.collectionView
    guard let selectedIndexPaths = collectionView.indexPathsForSelectedItems, let transitionCoordinator else {
      return
    }
    transitionCoordinator.animate { _ in
      for indexPath in selectedIndexPaths {
        collectionView.deselectItem(at: indexPath, animated: true)
      }
    } completion: { context in
      if context.isCancelled {
        for indexPath in selectedIndexPaths {
          collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
        }
      }
    }
  }

  override func bind(reactor: SearchViewReactor) {
    reactor
      .pulse(\.$trends)
      .bind { [dataSource] trends in
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        for trend in trends {
          snapshot.appendSections([.trend(trend)])
          snapshot.appendItems(trend.keywords.map(Item.trendKeyword), toSection: .trend(trend))
        }
        dataSource.apply(snapshot)
      }
      .disposed(by: disposeBag)

    let suggestions = reactor.state
      .map { $0.searchSuggestion?.suggestions ?? [] }
      .distinctUntilChanged()
      .share()

    Observable
      .combineLatest(suggestions, searchController.searchBar.rx.text.orEmpty)
      .bind { [searchSuggestionViewController] suggestions, query in
        searchSuggestionViewController.updateSuggestions(suggestions, query: query)
      }
      .disposed(by: disposeBag)

    suggestions
      .map { !$0.isEmpty }
      .distinctUntilChanged()
      .bind(to: searchController.rx.showsSearchResultsController)
      .disposed(by: disposeBag)

    searchController.searchBar.rx.text.orEmpty
      .throttle(.milliseconds(100), scheduler: MainScheduler.instance)
      .map { .fetchSuggestion($0) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)

    searchController.searchBar.searchTextField.rx
      .controlEvent(.editingDidEndOnExit)
      .withLatestFrom(searchController.searchBar.rx.text.orEmpty)
      .map { AppStep.search($0) }
      .bind(to: steps)
      .disposed(by: disposeBag)

    searchSuggestionViewController.rx.itemSelected
      .map { AppStep.search($0) }
      .bind(to: steps)
      .disposed(by: disposeBag)

    collectionView.rx.itemSelected
      .withUnretained(dataSource)
      .compactMap { $0.itemIdentifier(for: $1) }
      .compactMap {
        if case .trendKeyword(let keyword) = $0 {
          return AppStep.search(keyword.title)
        }
        return nil
      }
      .bind(to: steps)
      .disposed(by: disposeBag)

    rx.viewDidLoad
      .map { .fetchTrends }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
  }
}

// MARK: - SearchViewController (Private)

extension SearchViewController {
  private func makeCollectionViewLayout() -> UICollectionViewLayout {
    var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
    configuration.showsSeparators = false
    return UICollectionViewCompositionalLayout { _, environment in
      let headerSupplementaryItem = NSCollectionLayoutBoundarySupplementaryItem(
        layoutSize: NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1),
          heightDimension: .estimated(50)
        ),
        elementKind: UICollectionView.elementKindSectionHeader,
        alignment: .top
      ).then {
        $0.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
      }
      return NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: environment).then {
        $0.boundarySupplementaryItems = [headerSupplementaryItem]
        $0.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 20, trailing: 20)
      }
    }
  }

  private func makeCollectionViewDataSource(_ collectionView: UICollectionView) -> UICollectionViewDiffableDataSource<Section, Item> {
    let trendCellRegistration = UICollectionView.CellRegistration<TrendCell, Trend.Keyword> { cell, _, keyword in
      cell.configure(keyword)
    }
    let dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { collectionView, indexPath, item in
      switch item {
      case .trendKeyword(let keyword):
        collectionView.dequeueConfiguredReusableCell(using: trendCellRegistration, for: indexPath, item: keyword)
      }
    }

    typealias SupplementaryRegistration = UICollectionView.SupplementaryRegistration<SearchSupplementaryTitleView>
    let supplementaryRegistration = SupplementaryRegistration(elementKind: UICollectionView.elementKindSectionHeader) { [weak self] view, _, indexPath in
      guard let section = self?.dataSource.sectionIdentifier(for: indexPath.section) else {
        return
      }
      view.title = section.title(for: indexPath.section)
    }
    dataSource.supplementaryViewProvider = { collectionView, _, indexPath in
      collectionView.dequeueConfiguredReusableSupplementary(using: supplementaryRegistration, for: indexPath)
    }
    return dataSource
  }
}

// MARK: - SearchViewController.Section

extension SearchViewController {
  enum Section: Hashable {
    case trend(Trend)

    func title(for section: Int) -> String {
      switch self {
      case .trend(let trend):
        return "#\(section + 1). \(trend.title)"
      }
    }
  }
}

// MARK: - SearchViewController.Item

extension SearchViewController {
  enum Item: Hashable {
    case trendKeyword(Trend.Keyword)
  }
}

// MARK: - SearchViewController.SearchSupplementaryTitleView

extension SearchViewController {
  final class SearchSupplementaryTitleView: UICollectionReusableView {
    private let titleLabel = UILabel().then {
      $0.font = .preferredFont(forTextStyle: .body).withWeight(.bold)
      $0.textColor = .app.secondary
    }

    @inlinable var title: String? {
      get { titleLabel.text }
      set {
        titleLabel.text = newValue
        invalidateIntrinsicContentSize()
      }
    }

    override init(frame: CGRect) {
      super.init(frame: frame)
      addSubview(titleLabel)
      titleLabel.snp.makeConstraints {
        $0.directionalEdges.equalToSuperview()
      }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
  }
}

// MARK: - SearchViewController Preview

#Preview {
  UINavigationController(rootViewController: SearchViewController(reactor: SearchViewReactor()))
}
