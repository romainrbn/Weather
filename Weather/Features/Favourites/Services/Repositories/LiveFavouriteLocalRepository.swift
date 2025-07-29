//
//  LiveFavouriteLocalRepository.swift
//  Weather
//
//  Created by Romain Rabouan on 7/27/25.
//

import Foundation
import CoreData

protocol FavouriteLocalRepository {
    func createDBFavourite(
        identifier: String,
        locationName: String,
        latitude: Double,
        longitude: Double,
        latestTemperature: Int,
        maxTemperature: Int,
        minTemperature: Int,
        conditionRawValue: Int,
        conditionName: String,
        timeZone: TimeZone
    ) async throws

    func deleteDBFavourite(
        identifier: String
    ) async throws

    func fetchFavourites() async throws -> [FavouriteItemDTO]

    func persistFavouriteOrder(identifiersInOrder: [String]) async throws
}

enum FavouriteLocalRepositoryError: Error {
    case invalidCoreDataModel
}

struct LiveFavouriteLocalRepository: FavouriteLocalRepository {

    private let manager: WeatherManager

    init(manager: WeatherManager = .shared) {
        self.manager = manager
    }

    func createDBFavourite(
        identifier: String,
        locationName: String,
        latitude: Double,
        longitude: Double,
        latestTemperature: Int,
        maxTemperature: Int,
        minTemperature: Int,
        conditionRawValue: Int,
        conditionName: String,
        timeZone: TimeZone
    ) async throws {
        let context = manager.backgroundContext
        try await context.perform {
            let favourite = DBFavourite(context: context)
            guard let entityName = favourite.entity.name else {
                throw FavouriteLocalRepositoryError.invalidCoreDataModel
            }

            favourite.localIdentifier = identifier
            favourite.latitude = latitude
            favourite.longitude = longitude
            favourite.timezoneIdentifier = timeZone.identifier
            favourite.locationName = locationName
            favourite.latestUpdate = .now
            favourite.temperature = Int16(latestTemperature)
            favourite.temperatureMin = Int16(minTemperature)
            favourite.temperatureMax = Int16(maxTemperature)
            favourite.condition = Int16(conditionRawValue)
            favourite.conditionName = conditionName

            let request = NSFetchRequest<NSDictionary>(entityName: entityName)
            request.resultType = .dictionaryResultType
            request.propertiesToFetch = [#keyPath(DBFavourite.sortOrder)]
            request.sortDescriptors = [NSSortDescriptor(key: #keyPath(DBFavourite.sortOrder), ascending: false)]
            request.fetchLimit = 1

            if let result = try context.fetch(request).first,
               let maxIndex = result[#keyPath(DBFavourite.sortOrder)] as? Int16 {
                favourite.sortOrder = maxIndex + 1
            } else {
                favourite.sortOrder = 0
            }

            try context.save()
        }
    }

    func deleteDBFavourite(identifier: String) async throws {
        try await FavouriteDeleteRequest()
            .setFavouriteIdentifier(identifier)
            .setFetchLimit(1)
            .execute()
    }

    func fetchFavourites() async throws -> [FavouriteItemDTO] {
        let fetchRequest = FetchRequest(
            context: WeatherManager.shared.backgroundContext,
            converter: DBFavouriteConverter()
        )
        .setSortDescriptor(NSSortDescriptor(key: #keyPath(DBFavourite.sortOrder), ascending: true))

        let results = try await fetchRequest.execute()

        return results
    }

    func persistFavouriteOrder(identifiersInOrder: [String]) async throws {
        let context = WeatherManager.shared.backgroundContext

        for (index, identifier) in identifiersInOrder.enumerated() {
           _ = try await FetchRequest(context: context, converter: DBFavouriteConverter())
                .appendPredicate(NSPredicate(format: "%K == %@", #keyPath(DBFavourite.localIdentifier), identifier))
                .setFetchLimit(1)
                .execute { dbObject in
                    dbObject.sortOrder = Int16(index)
                }
        }

        if context.hasChanges {
            try context.save()
        }
    }
}
