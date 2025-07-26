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
    private lazy var dataSource: HomeViewDataSource = HomeViewDataSource(collectionView: collectionView)
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

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.backgroundView = emptyStateView
    }

    // MARK: - HomeViewContract conformance

    func display(_ content: HomeContent) {
        dataSource.content = content
        collectionView.backgroundView?.isHidden = !content.sections.isEmpty
    }

    // MARK: - Setup

    private func setup() {
        setupNavigation()
        buildViewHierarchy()
        setConstraints()
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
        let sectionProvider = { [weak self] (sectionIndex: Int, environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            guard let self else { return nil }

            let section = dataSource.content.sections[sectionIndex]

            // Create the layout depending of the current section.
            switch section {
            case .favourites:
                return HomeViewLayoutFactory.favoritesLayoutSection(layoutEnvironment: environment)
            case .recentlyVisited:
                return HomeViewLayoutFactory.favoritesLayoutSection(layoutEnvironment: environment)
            }
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

// MARK: - UISearchResultsUpdating

extension HomeViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let query = searchController.searchBar.text ?? ""
        presenter?.searchCity(query) { [weak self] cities in
            DispatchQueue.main.async {
                self?.searchResultsController.results = cities
            }
        }
    }
}

// MARK: - CitySearchResultsControllerDelegate

extension HomeViewController: CitySearchResultsControllerDelegate {
    func didSelectCity(_ city: MKMapItem) {
        searchController.searchBar.text = ""
        searchResultsController.dismiss(animated: true)
    }
}
