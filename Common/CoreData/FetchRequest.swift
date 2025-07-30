//
//  FetchRequest.swift
//  Weather
//
//  Created by Romain Rabouan on 7/26/25.
//

import CoreData

protocol DTOConverter {
    associatedtype Entity: NSManagedObject
    associatedtype DTO

    func convert(_ object: Entity) throws -> DTO
}

class FetchRequest<Converter: DTOConverter> {
    typealias Entity = Converter.Entity
    typealias DTO = Converter.DTO

    private var predicate: NSPredicate?
    private var sortDescriptors: [NSSortDescriptor] = []
    private var fetchLimit: Int?

    private let context: NSManagedObjectContext
    private let converter: Converter

    init(context: NSManagedObjectContext, converter: Converter) {
        self.context = context
        self.converter = converter
    }

    func appendPredicate(_ newPredicate: NSPredicate) -> Self {
        if let existing = predicate {
            predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [existing, newPredicate])
        } else {
            predicate = newPredicate
        }
        return self
    }

    func setFetchLimit(_ limit: Int) -> Self {
        fetchLimit = limit

        return self
    }

    func setSortDescriptor(_ descriptor: NSSortDescriptor) -> Self {
        self.sortDescriptors.append(descriptor)
        return self
    }

    func setSortDescriptors(_ descriptors: [NSSortDescriptor]) -> Self {
        self.sortDescriptors = descriptors
        return self
    }

    func execute() async throws -> [DTO] {
        try await context.perform { [weak self] in
            guard
                let self,
                let name = Entity.entity().name
            else {
                return []
            }
            let request = NSFetchRequest<Entity>(entityName: name)
            request.predicate = predicate
            request.sortDescriptors = sortDescriptors
            if let fetchLimit {
                request.fetchLimit = fetchLimit
            }
            let results = try context.fetch(request)
            return try results.map(self.converter.convert)
        }
    }

    func execute(transaction: @escaping (inout Entity) throws -> Void) async throws -> [DTO] {
        try await context.perform { [weak self] in
            guard let self, let name = Entity.entity().name else { return [] }
            let request = NSFetchRequest<Entity>(entityName: name)
            request.predicate = predicate
            request.sortDescriptors = sortDescriptors
            if let fetchLimit {
                request.fetchLimit = fetchLimit
            }
            var results = try context.fetch(request)

            for index in results.indices {
                try transaction(&results[index])
            }

            if context.hasChanges {
                try context.save()
            }

            return try results.map(self.converter.convert)
        }
    }
}
