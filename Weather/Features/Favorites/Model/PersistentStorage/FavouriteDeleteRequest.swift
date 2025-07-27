//
//  FavouriteDeleteRequest.swift
//  Weather
//
//  Created by Romain Rabouan on 7/27/25.
//

import Foundation

final class FavouriteDeleteRequest: DeleteRequest<DBFavorite> {
    private let manager: WeatherManager

    init(manager: WeatherManager = .shared) {
        self.manager = manager
        super.init(context: manager.backgroundContext)
    }

    @discardableResult
    func setFavouriteIdentifier(_ identifier: UUID) -> Self {
        let keyPath = #keyPath(DBFavorite.localIdentifier)
        let predicate = NSPredicate(format: "%K == %@", keyPath, identifier as CVarArg)

        return appendPredicate(predicate)
    }
}
