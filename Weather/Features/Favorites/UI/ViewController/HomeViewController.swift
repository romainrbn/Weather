//
//  HomeViewController.swift
//  Weather
//
//  Created by Romain Rabouan on 7/25/25.
//

import UIKit
import MapKit

final class HomeViewController: UIViewController, HomeViewContract {

    // MARK: - Properties

    private lazy var collectionView: UICollectionView = createCollectionView()
    private lazy var collectionViewLayout: UICollectionViewCompositionalLayout = createCollectionViewLayout()
    private lazy var dataSource: HomeViewDataSource = HomeViewDataSource(collectionView: collectionView, presenter: presenter)
    private lazy var searchResultsController: CitySearchResultsController = createSearchResultsController()
    private lazy var searchController: UISearchController = createSearchController()
    private lazy var emptyStateView = createEmptyView()

    weak var presenter: HomePresenter?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        presenter?.loadData()
    }

    // MARK: - HomeViewContract conformance

    func display(_ content: FavouritesViewContent) {
        dataSource.content = content

        let hasData = !content.items.isEmpty
        emptyStateView.isHidden = hasData

        if #available(iOS 17.4, *) {
            collectionView.bouncesVertically = hasData
        }
    }

    func performCitySearch(_ query: String) {
        presenter?.searchCity(query) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let cities):
                    self?.searchResultsController.results = cities
                case .failure(let error):
                    self?.searchResultsController.error = error
                }
            }
        }
    }

    // MARK: - Setup

    private func setup() {
        setupNavigation()
        buildViewHierarchy()
        setConstraints()
        setupEmptyBackgroundView()
    }

    private func setupNavigation() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.largeTitleDisplayMode = .always
        title = "Weather"
        navigationItem.leftBarButtonItem = createSettingsBarButtonItem()

        definesPresentationContext = true

        view.backgroundColor = .systemBackground
    }

    private func buildViewHierarchy() {
        view.addSubview(collectionView)
    }

    private func setConstraints() {
        collectionView.fitWithinParent(view)
    }

    // MARK: Content creation

    private func createCollectionViewLayout() -> UICollectionViewCompositionalLayout {
        let sectionProvider = { (_: Int, environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            return HomeViewLayoutBuilder.favoritesLayoutSection(layoutEnvironment: environment)
        }

        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    }

    private func createCollectionView() -> UICollectionView {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: collectionViewLayout
        )
        collectionView.delegate = self
        collectionView.backgroundColor = .clear

        return collectionView
    }

    private func createSearchResultsController() -> CitySearchResultsController {
        let searchController = CitySearchResultsController()
        searchController.delegate = self
        return searchController
    }

    private func createSearchController() -> UISearchController {
        let controller = UISearchController(searchResultsController: searchResultsController)
        controller.searchResultsUpdater = self
        controller.delegate = self
        controller.obscuresBackgroundDuringPresentation = true
        controller.searchBar.placeholder = "Search for a city"
        return controller
    }

    private func createEmptyView() -> HostingView<HomeEmptyView> {
        HostingView(
            rootView: HomeEmptyView(onUseCurrentLocationTapped: { [weak self] in
                self?.presenter?.didTapUseCurrentLocationButton()
            })
        )
    }

    private func setupEmptyBackgroundView() {
        view.addSubview(emptyStateView)
        emptyStateView.fitHorizontallyWithinParent(view)
        emptyStateView.center(within: view)
    }

    private func createSettingsBarButtonItem() -> UIBarButtonItem {
        let buttonItem = UIBarButtonItem(
            image: UIImage(systemName: "gear"),
            style: .plain,
            target: self,
            action: #selector(didTapSettingsButton)
        )
        buttonItem.accessibilityLabel = "Open Settings"

        return buttonItem
    }

    // MARK: - Selectors

    @objc
    private func didTapSettingsButton() {
        presenter?.didTapSettingsButton()
    }
}

// MARK: - UICollectionViewDelegate

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = dataSource.content.items[indexPath.item]

        presenter?.didSelectItem(item)
    }
}

// MARK: - UISearchResultsUpdating

extension HomeViewController: UISearchResultsUpdating, UISearchControllerDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        let query = searchController.searchBar.text ?? ""
        performCitySearch(query)
    }
}

// MARK: - CitySearchResultsControllerDelegate

extension HomeViewController: CitySearchResultsControllerDelegate {
    func didSelectCity(_ city: MKMapItem) {
        searchController.searchBar.text = ""
        presenter?.state.searchQuery = ""
        searchResultsController.dismiss(animated: true)
    }

    func retryQuery() {
        guard let searchQuery = presenter?.state.searchQuery else { return }
        performCitySearch(searchQuery)
    }
}
