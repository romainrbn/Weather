//
//  DeleteRequest.swift
//  Weather
//
//  Created by Romain Rabouan on 7/27/25.
//

import CoreData

class DeleteRequest<T: NSManagedObject> {
    private let context: NSManagedObjectContext
    private var predicate: NSPredicate?
    private var fetchLimit: Int?

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func appendPredicate(_ newPredicate: NSPredicate) -> Self {
        if let existing = predicate {
            predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [existing, newPredicate])
        } else {
            predicate = newPredicate
        }
        return self
    }

    func setPredicate(_ predicate: NSPredicate) -> Self {
        self.predicate = predicate
        return self
    }

    func setFetchLimit(_ limit: Int) -> Self {
        self.fetchLimit = limit
        return self
    }

    func execute(shouldSave: Bool = true) async throws {
        try await context.perform { [weak self] in
            guard let self, let name = T.entity().name else { return }
            let fetchRequest = NSFetchRequest<T>(entityName: name)
            fetchRequest.predicate = predicate

            if let fetchLimit {
                fetchRequest.fetchLimit = fetchLimit
            }

            let objectsToDelete = try context.fetch(fetchRequest)
            for object in objectsToDelete {
                context.delete(object)
            }

            if shouldSave && context.hasChanges {
                try context.save()
            }
        }
    }
}
