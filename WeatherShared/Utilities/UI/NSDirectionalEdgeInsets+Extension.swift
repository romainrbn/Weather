//
//  NSDirectionalEdgeInsets+Extension.swift
//  Weather
//
//  Created by Romain Rabouan on 7/26/25.
//

import UIKit

extension NSDirectionalEdgeInsets {
    init(allEdges value: CGFloat) {
        self.init(top: value, leading: value, bottom: value, trailing: value)
    }

    init(vertical value: CGFloat) {
        self.init(top: value, leading: 0, bottom: value, trailing: 0)
    }

    init(horizontal value: CGFloat) {
        self.init(top: 0, leading: value, bottom: 0, trailing: value)
    }
}
