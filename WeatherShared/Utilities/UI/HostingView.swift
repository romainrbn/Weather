//
//  HostingView.swift
//  Weather
//
//  Created by Romain Rabouan on 7/26/25.
//

import UIKit
import SwiftUI

/// A UIView wrapper that hosts SwiftUI views using `UIHostingController` internally
/// This allows embedding SwiftUI views directly as `UIView`s without exposing `UIHostingController` at the call site
final class HostingView<RootView: View>: UIView {

    private let hostingController: UIHostingController<RootView>

    var rootView: RootView {
        get { hostingController.rootView }
        set { hostingController.rootView = newValue }
    }

    init(rootView: RootView) {
        self.hostingController = UIHostingController(rootView: rootView)
        super.init(frame: .zero)
        setupHostingController()
    }

    convenience init(@ViewBuilder content: () -> RootView) {
        self.init(rootView: content())
    }

    @available(*, unavailable)
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupHostingController() {
        hostingController.view.backgroundColor = .clear
        addSubview(hostingController.view)
        hostingController.view.fitWithinParent(self)
    }

    // MARK: - Lifecycle

    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)

        if let viewController = findViewController() {
            viewController.addChild(hostingController)
            hostingController.didMove(toParent: viewController)
        }
    }

    override func removeFromSuperview() {
        hostingController.willMove(toParent: nil)
        hostingController.removeFromParent()
        super.removeFromSuperview()
    }

    override func systemLayoutSizeFitting(_ targetSize: CGSize) -> CGSize {
        return hostingController.sizeThatFits(in: targetSize)
    }

    override func systemLayoutSizeFitting(
        _ targetSize: CGSize,
        withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
        verticalFittingPriority: UILayoutPriority
    ) -> CGSize {
        return hostingController.sizeThatFits(in: targetSize)
    }

    override var intrinsicContentSize: CGSize {
        return hostingController.sizeThatFits(in: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
    }
}

private extension UIView {
    func findViewController() -> UIViewController? {
        if let nextResponder = next as? UIViewController {
            return nextResponder
        } else if let nextResponder = next as? UIView {
            return nextResponder.findViewController()
        } else {
            return nil
        }
    }
}
