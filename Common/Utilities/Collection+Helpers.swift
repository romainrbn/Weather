//
//  Collection+Helpers.swift
//  Weather
//
//  Created by Romain Rabouan on 7/30/25.
//

import Foundation

extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
