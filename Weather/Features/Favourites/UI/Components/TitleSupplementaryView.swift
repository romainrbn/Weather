//
//  TitleSupplementaryView.swift
//  Weather
//
//  Created by Romain Rabouan on 7/25/25.
//

import UIKit

private enum Constants {
    static let titleFontSize: CGFloat = 23
}

final class TitleSupplementaryView: UICollectionReusableView {
    static let reuseIdentifier = NSStringFromClass(TitleSupplementaryView.self)

    var content: Content = .empty {
        didSet {
            guard content != oldValue else { return }
            setContent(content)
        }
    }

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = .spacing100
        return stackView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = .systemFont(ofSize: Constants.titleFontSize, weight: .semibold)
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = .preferredFont(forTextStyle: .headline)
        label.textColor = .secondaryLabel
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
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
        addSubview(stackView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)
    }

    private func setConstraints() {
        stackView.constrainEdges(to: self)
    }
}

extension TitleSupplementaryView {
    struct Content: Equatable {
        let title: String
        let subtitle: String

        static let empty = Content(title: "", subtitle: "")
    }

    func setContent(_ content: Content) {
        titleLabel.text = content.title
        subtitleLabel.text = content.subtitle
    }
}
