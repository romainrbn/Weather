//
//  HomeViewController.swift
//  Weather
//
//  Created by Romain Rabouan on 7/25/25.
//

import UIKit

final class HomeViewController: UIViewController, HomeViewContract {

    // MARK: - Properties

    private lazy var collectionView: UICollectionView = createCollectionView()
    private lazy var collectionViewLayout: UICollectionViewCompositionalLayout = createCollectionViewLayout()
    private lazy var dataSource: HomeViewDataSource = HomeViewDataSource(collectionView: collectionView)

    var presenter: HomePresenter?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        presenter?.loadData()
    }

    // MARK: - HomeViewContract conformance

    func display(_ content: HomeContent) {
        dataSource.content = content
    }

    // MARK: - Setup

    private func setup() {
        view.backgroundColor = .systemBackground
        buildViewHierarchy()
        setConstraints()
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
}
