//
//  HomeContentMapper.swift
//  Weather
//
//  Created by Romain Rabouan on 7/26/25.
//

import Foundation

/// Creates the content to display on the home view, from the current state of the presenter.
struct HomeContentMapper {
    static func map(_ state: HomePresenter.State) -> HomeContent {
        let items = state.locationItems.map {
            HomeItem.location($0)
        }
        return HomeContent(sections: [])
    }
}
