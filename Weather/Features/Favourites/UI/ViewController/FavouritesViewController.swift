//
//  FavouritesViewController.swift
//  Weather
//
//  Created by Romain Rabouan on 7/25/25.
//

import UIKit
import MapKit

final class FavouritesViewController: UICollectionViewController, FavouritesViewContract {

    // MARK: - Properties

    private(set) lazy var dataSource: FavouritesViewDataSource = FavouritesViewDataSource(
        collectionView: collectionView,
        presenter: presenter
    )
    private lazy var citySearchResultsController: CitySearchResultsController = createSearchResultsController()
    private lazy var searchController: UISearchController = createSearchController()
    private lazy var emptyStateView = createEmptyView()
    private let loadingIndicator = UIActivityIndicatorView(style: .large)

    private var isInitialLoadInProgress = false

    weak var presenter: FavouritesPresenter?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView = createCollectionView()
        collectionView.dragInteractionEnabled = true
        collectionView.dragDelegate = self
        collectionView.dropDelegate = self
        collectionView.setCollectionViewLayout(createCollectionViewLayout(), animated: false)
        setup()

        loadingIndicator.startAnimating()

        presenter?.loadData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        #if DEBUG
        if Secret.apiKey == Secret.noApiKeyValue {
            displayError(errorMessage:
                """
                🔑 Missing API Key! Please configure it in the OPENWEATHERMAP_APIKEY User-Defined build setting.
                For setup instructions, see the README.md file in the project root.
                """
            )
        }
        #endif
    }

    // MARK: - FavouritesViewContract conformance

    func display(_ content: FavouritesViewContent) {
        if isInitialLoadInProgress {
            isInitialLoadInProgress = false
            loadingIndicator.stopAnimating()
        }

        dataSource.content = content

        let hasData = !content.items.isEmpty
        emptyStateView.isHidden = hasData
        loadingIndicator.isHidden = true

        if #available(iOS 17.4, *) {
            collectionView.bouncesVertically = hasData
        }

        collectionView.refreshControl?.endRefreshing()
    }

    func displayError(errorMessage: String) {
        let alertController = UIAlertController(
            title: "Error",
            message: errorMessage,
            preferredStyle: .alert
        )
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel))

        present(alertController, animated: true)
    }

    func performCitySearch(_ query: String) {
        presenter?.searchCity(query) { [weak self] result in
            switch result {
            case .success(let cities):
                self?.citySearchResultsController.results = cities
            case .failure(let error):
                self?.citySearchResultsController.error = error
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
        navigationItem.rightBarButtonItem = createEditBarButtonItem()

        definesPresentationContext = true

        view.backgroundColor = .systemBackground
    }

    private func buildViewHierarchy() {
        view.addSubview(loadingIndicator)
        view.addSubview(collectionView)
    }

    private func setConstraints() {
        collectionView.constrainEdges(to: view)
        loadingIndicator.center(in: view)
    }

    // MARK: Content creation

    private func createCollectionViewLayout() -> UICollectionViewCompositionalLayout {
        let sectionProvider = { (_: Int, environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            return FavouritesViewLayoutBuilder.favouritesLayoutSection(layoutEnvironment: environment)
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

        let refreshControl = UIRefreshControl(frame: .zero)
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl

        return collectionView
    }

    private func createSearchResultsController() -> CitySearchResultsController {
        let searchController = CitySearchResultsController()
        searchController.delegate = self
        return searchController
    }

    private func createSearchController() -> UISearchController {
        let controller = UISearchController(searchResultsController: citySearchResultsController)
        controller.searchResultsUpdater = self
        controller.delegate = self
        controller.obscuresBackgroundDuringPresentation = true
        controller.searchBar.placeholder = "Search for a city"
        return controller
    }

    private func createEmptyView() -> HostingView<FavouritesEmptyView> {
        let view = HostingView(
            rootView: FavouritesEmptyView(onUseCurrentLocationTapped: { [weak self] in
                self?.presenter?.didTapUseCurrentLocationButton()
            })
        )
        view.isHidden = true
        return view
    }

    private func setupEmptyBackgroundView() {
        view.addSubview(emptyStateView)
        emptyStateView.constrainEdges(to: view)
        emptyStateView.center(in: view)
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

    private func createEditBarButtonItem() -> UIBarButtonItem {
        let buttonItem = UIBarButtonItem(
            barButtonSystemItem: .edit,
            target: self,
            action: #selector(didTapToggleEditButton)
        )
        buttonItem.accessibilityLabel = "Enter edit mode"

        return buttonItem
    }

    private func createConfirmChangesBarButtonItem() -> UIBarButtonItem {
        let buttonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(didTapToggleEditButton)
        )
        buttonItem.accessibilityLabel = "Confirm changes"

        return buttonItem
    }

    // MARK: - Selectors

    @objc
    private func didTapSettingsButton() {
        presenter?.didTapSettingsButton()
    }

    @objc
    private func didTapToggleEditButton() {
        setEditing(!isEditing, animated: true)
        navigationItem.rightBarButtonItem = isEditing ? createConfirmChangesBarButtonItem() : createEditBarButtonItem()
    }

    @objc
    private func didPullToRefresh() {
        presenter?.didPullToRefresh()
    }
}

// MARK: - UICollectionViewDelegate

extension FavouritesViewController {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = dataSource.content.items[indexPath.item]

        presenter?.didSelectItem(item)
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

// MARK: - UISearchResultsUpdating

extension FavouritesViewController: UISearchResultsUpdating, UISearchControllerDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        let query = searchController.searchBar.text ?? ""
        performCitySearch(query)
    }
}

// MARK: - CitySearchResultsControllerDelegate

extension FavouritesViewController: CitySearchResultsControllerDelegate {
    func didSelectCity(_ city: MKMapItem) {
        searchController.searchBar.text = ""
        presenter?.state.searchQuery = ""
        citySearchResultsController.dismiss(animated: true)
        presenter?.showPlacemark(city.placemark, timeZone: city.timeZone)
    }

    func retryQuery() {
        guard let searchQuery = presenter?.state.searchQuery else { return }
        performCitySearch(searchQuery)
    }
}
