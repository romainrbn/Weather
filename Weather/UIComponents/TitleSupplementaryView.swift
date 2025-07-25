//
//  TitleSupplementaryView.swift
//  Weather
//
//  Created by Romain Rabouan on 7/25/25.
//

import UIKit

private enum Constants {
    static let titleFontSize: CGFloat = 32
}

final class TitleSupplementaryView: UICollectionReusableView {
    static let reuseIdentifier = NSStringFromClass(TitleSupplementaryView.self)

    var content: Content = .empty {
        didSet {
            guard content != oldValue else { return }
            setContent(content)
        }
    }

    private lazy var titleLabel = createTitleLabel()

    init() {
        super.init(frame: .zero)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setup() {
        buildViewHierarchy()
        setConstraints()
    }

    private func buildViewHierarchy() {
        addSubview(titleLabel)
    }

    private func setConstraints() {
        titleLabel.fitWithinParent(self)
    }

    // MARK: - Subviews

    private func createTitleLabel() -> UILabel {
        let label = UILabel(frame: .zero)
        label.font = .systemFont(ofSize: Constants.titleFontSize, weight: .bold)
        return label
    }
}

extension TitleSupplementaryView {
    struct Content: Equatable {
        let title: String

        static let empty = Content(title: "")
    }

    func setContent(_ content: Content) {
        titleLabel.text = content.title
    }
}
