//
//  FavouriteDeleteRequest.swift
//  Weather
//
//  Created by Romain Rabouan on 7/27/25.
//

import Foundation

final class FavouriteDeleteRequest: DeleteRequest<DBFavourite> {
    private let manager: WeatherManager

    init(manager: WeatherManager = .shared) {
        self.manager = manager
        super.init(context: manager.backgroundContext)
    }

    @discardableResult
    func setFavouriteIdentifier(_ identifier: String) -> Self {
        let keyPath = #keyPath(DBFavourite.localIdentifier)
        let predicate = NSPredicate(format: "%K == %@", keyPath, identifier as CVarArg)

        return appendPredicate(predicate)
    }
}
