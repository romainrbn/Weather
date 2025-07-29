//
//  CitySearchErrorView.swift
//  Weather
//
//  Created by Romain Rabouan on 7/26/25.
//

import UIKit

private enum Constants {
    static let errorImageSize: CGFloat = 40
}

/// Using a UIKit view here to avoid unnecessary architectural complexity.
/// Reacting to error state changes via SwiftUI would require a bridging mechanism,
/// such as a reference type view model with a `@Published` property, to communicate with UIKit.
/// For this case, directly exposing a `setError(_:)` method is simpler and sufficient.
final class CitySearchErrorView: UIView {

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .systemOrange
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false

        return imageView
    }()

    private let errorLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .label
        label.font = UIFont.preferredFont(forTextStyle: .title2, compatibleWith: UITraitCollection(legibilityWeight: .bold))

        return label
    }()

    private lazy var retryButton: UIButton = createRetryButton()
    private lazy var stackView: UIStackView = createStackView()

    private let onRetry: () -> Void

    private var currentError: WeatherLocalCitySearchServiceError? {
        didSet {
            updateUI(for: currentError)
        }
    }

    init(onRetry: @escaping () -> Void) {
        self.onRetry = onRetry
        super.init(frame: .zero)
        setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init?(coder:) has not been implemented")
    }

    func setError(_ error: WeatherLocalCitySearchServiceError?) {
        currentError = error
    }

    // MARK: - Setup

    private func setupView() {
        backgroundColor = .systemBackground

        addSubview(stackView)
        stackView.center(within: self)
        stackView.fitHorizontallyWithinParent(self, offset: .spacing400)

        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: Constants.errorImageSize),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor)
        ])
    }

    private func updateUI(for error: WeatherLocalCitySearchServiceError?) {
        switch error {
        case .networkError:
            imageView.image = UIImage(systemName: "network")
        case .mapKitError:
            imageView.image = UIImage(systemName: "map")
        case .none:
            imageView.image = nil
        }

        errorLabel.text = "\(error?.errorDescription ?? "Unknown error")"
        imageView.isHidden = error == nil
        errorLabel.isHidden = error == nil
    }

    private func createStackView() -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: [imageView, errorLabel, retryButton])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = .spacing300

        return stackView
    }

    private func createRetryButton() -> UIButton {
        let button = UIButton(configuration: .filled())
        button.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        button.setTitle("Retry", for: .normal)

        return button
    }

    @objc
    private func retryButtonTapped() {
        onRetry()
    }
}
