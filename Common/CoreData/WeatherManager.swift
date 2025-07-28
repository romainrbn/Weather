//
//  WeatherManager.swift
//  Weather
//
//  Created by Romain Rabouan on 7/26/25.
//

import Foundation
import CoreData

private enum Constants {
    static let containerName: String = "Weather"
}

final class WeatherManager {
    static let shared = WeatherManager()

    let persistentContainer: NSPersistentContainer

    private(set) lazy var backgroundContext: NSManagedObjectContext = {
        let context = persistentContainer.newBackgroundContext()
        context.name = "WeatherFetchContext"
        context.automaticallyMergesChangesFromParent = true
        return context
    }()

    private init() {
        persistentContainer = NSPersistentContainer(name: Constants.containerName)
        persistentContainer.loadPersistentStores { _, error in
            if let error {
                preconditionFailure("Failed to load store: \(error)")
            }
        }
    }
}
