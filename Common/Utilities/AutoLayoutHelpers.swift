//
//  AutoLayoutHelpers.swift
//  Weather
//
//  Created by Romain Rabouan on 7/25/25.
//

import UIKit

/// A small helper extension to build NSLayoutConstraints faster and avoid massive view controllers...
extension UIView {
    func fitWithinParent(_ parent: UIView, verticalOffset: CGFloat = 0, horizontalOffset: CGFloat = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: parent.topAnchor, constant: verticalOffset),
            bottomAnchor.constraint(equalTo: parent.bottomAnchor, constant: -verticalOffset),
            trailingAnchor.constraint(equalTo: parent.trailingAnchor, constant: -horizontalOffset),
            leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: horizontalOffset),
        ])
    }

    func fitHorizontallyWithinParent(_ parent: UIView, offset: CGFloat = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            trailingAnchor.constraint(equalTo: parent.trailingAnchor, constant: -offset),
            leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: offset),
        ])
    }

    func center(within parent: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            centerXAnchor.constraint(equalTo: parent.centerXAnchor),
            centerYAnchor.constraint(equalTo: parent.centerYAnchor),
        ])
    }
}
