//
//  AutoLayoutHelpers.swift
//  Weather
//
//  Created by Romain Rabouan on 7/25/25.
//

import UIKit

/// A small helper extension to build NSLayoutConstraints faster and avoid massive view controllers...
extension UIView {
    /// Pins all edges of the view to its parent with optional offsets
    func constrainEdges(to parent: UIView, verticalOffset: CGFloat = 0, horizontalOffset: CGFloat = 0) {
        prepareForConstraints()
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: parent.topAnchor, constant: verticalOffset),
            bottomAnchor.constraint(equalTo: parent.bottomAnchor, constant: -verticalOffset),
            leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: horizontalOffset),
            trailingAnchor.constraint(equalTo: parent.trailingAnchor, constant: -horizontalOffset)
        ])
    }

    /// Pins the horizontal edges to the parent
    func constrainHorizontally(to parent: UIView, offset: CGFloat = 0) {
        prepareForConstraints()
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: offset),
            trailingAnchor.constraint(equalTo: parent.trailingAnchor, constant: -offset)
        ])
    }

    /// Centers the view inside a parent view
    func center(in parent: UIView) {
        prepareForConstraints()
        NSLayoutConstraint.activate([
            centerXAnchor.constraint(equalTo: parent.centerXAnchor),
            centerYAnchor.constraint(equalTo: parent.centerYAnchor)
        ])
    }

    func constrainHeight(_ height: CGFloat) {
        prepareForConstraints()

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: height)
        ])
    }

    private func prepareForConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
    }
}
