//
//  TitleSupplementaryView.swift
//  Weather
//
//  Created by Romain Rabouan on 7/25/25.
//

import UIKit

private enum Constants {
    static let titleFontSize: CGFloat = 23
    static let locationButtonHeight: CGFloat = 60
}

final class TitleSupplementaryView: UICollectionReusableView {
    static let reuseIdentifier = NSStringFromClass(TitleSupplementaryView.self)

    var content: Content = .empty {
        didSet {
            guard content != oldValue else { return }
            setContent(content)
        }
    }

    var behaviours: Behaviours = .empty

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

    private lazy var locationButton: UIButton = {
        let button = UIButton(configuration: .borderedTinted())
        button.isHidden = true
        button.setTitle("Show Weather for my current location", for: .normal)
        button.setImage(UIImage(systemName: "location"), for: .normal)
        button.addTarget(self, action: #selector(didTapLocationButton), for: .touchUpInside)
        return button
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
        stackView.addArrangedSubview(locationButton)
    }

    private func setConstraints() {
        stackView.constrainEdges(to: self)
        locationButton.constrainHeight(Constants.locationButtonHeight)
    }

    // MARK: - Actiosn

    @objc
    private func didTapLocationButton() {
        behaviours.didTapLocationButton()
    }
}

extension TitleSupplementaryView {
    struct Content: Equatable {
        let title: String
        let subtitle: String
        let shouldDisplayLocationButton: Bool
        let locationButtonImage: UIImage?
        let locationButtonTitle: String?

        static let empty = Content(
            title: "",
            subtitle: "",
            shouldDisplayLocationButton: false,
            locationButtonImage: nil,
            locationButtonTitle: nil
        )
    }

    func setContent(_ content: Content) {
        titleLabel.text = content.title
        subtitleLabel.text = content.subtitle
        locationButton.isHidden = !content.shouldDisplayLocationButton
        locationButton.setTitle(content.locationButtonTitle, for: .normal)
    }
}

extension TitleSupplementaryView {
    struct Behaviours {
        let didTapLocationButton: () -> Void

        static let empty = Behaviours(didTapLocationButton: {})
    }
}
