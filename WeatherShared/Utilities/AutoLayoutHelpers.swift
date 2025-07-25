//
//  AutoLayoutHelpers.swift
//  Weather
//
//  Created by Romain Rabouan on 7/25/25.
//

import UIKit

/// A small helper extension to build NSLayoutConstraints faster...
extension UIView {
    func fitWithinParent(_ parent: UIView, offset: CGFloat = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: parent.topAnchor, constant: offset),
            bottomAnchor.constraint(equalTo: parent.bottomAnchor, constant: -offset),
            trailingAnchor.constraint(equalTo: parent.trailingAnchor, constant: -offset),
            leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: offset),
        ])
    }
}
