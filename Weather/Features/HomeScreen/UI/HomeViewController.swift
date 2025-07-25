//
//  HomeViewController.swift
//  Weather
//
//  Created by Romain Rabouan on 7/25/25.
//

import UIKit

final class HomeViewController: UIViewController {

    // MARK: - Properties

    private lazy var collectionView: UICollectionView = createCollectionView()
    private lazy var collectionViewLayout: UICollectionViewCompositionalLayout = createCollectionViewLayout()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
    }

    // MARK: Content creation

    private func createCollectionViewLayout() -> UICollectionViewCompositionalLayout {
        let sectionProvider = { [weak self] (sectionIndex: Int, environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            guard let self else { return nil }
            
        }
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
