//
//  HomeContent.swift
//  Weather
//
//  Created by Romain Rabouan on 7/26/25.
//

import Foundation

struct HomeContent: Equatable {
    let sections: [HomeSection]

    static let empty = HomeContent(sections: [])
}
