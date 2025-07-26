//
//  DBFavouriteConverter.swift
//  Weather
//
//  Created by Romain Rabouan on 7/26/25.
//

import Foundation

enum DBConverterError: Error {
    case missingMandatoryData
}

struct DBFavouriteConverter: DTOConverter {
    func convert(_ object: DBFavorite) throws -> FavouriteItemDTO {
        guard
            let id = object.id,
            let timezoneIdentifier = object.timezoneIdentifier,
            let timezone = TimeZone(identifier: timezoneIdentifier)
        else {
            throw DBConverterError.missingMandatoryData
        }

        return FavouriteItemDTO(
            identifier: id,
            latitude: object.latitude,
            longitude: object.longitude,
            timezone: timezone
        )
    }
}
