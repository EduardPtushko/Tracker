//
//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Eduard Ptushko on 13.11.2026.
//

import CoreData

protocol TrackerCategoryStoreDelegate: AnyObject {
    func trackerCategoryStoreDidUpdate()
}

final class TrackerCategoryStore: NSObject {
    weak var delegate: TrackerCategoryStoreDelegate?

    private let context: NSManagedObjectContext

    private lazy var fetchedResultsController: NSFetchedResultsController = {
        let request = TrackerCategoryEntity.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: "title", ascending: true)
        ]

        let controller = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )

        controller.delegate = self
        do {
            try controller.performFetch()
        } catch {
            assertionFailure(
                "Failed to perform initial fetch for TrackerCategoryEntity: \(error)"
            )
        }

        return controller
    }()

    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        _ = fetchedResultsController
    }

    convenience override init() {
        self.init(context: CoreDataStack.shared.viewContext)
    }

    func fetchCategories() -> [TrackerCategory] {
        let entities = fetchedResultsController.fetchedObjects ?? []

        return entities.compactMap { entity -> TrackerCategory? in
            guard let title = entity.title else { return nil }
            let trackerEntities = (entity.trackers as? Set<TrackerEntity>) ?? []
            let trackers = trackerEntities.compactMap { Tracker(from: $0) }
                .sorted { $0.name < $1.name }

            return TrackerCategory(title: title, trackers: trackers)
        }
    }

    func addCategory(title: String) throws {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else {
            throw StoreError.invalidData
        }
        let request = TrackerCategoryEntity.fetchRequest()
        request.predicate = NSPredicate(
            format: "$K == [c] %@",
            #keyPath(TrackerCategoryEntity.title),
            trimmedTitle
        )
        if try context.count(for: request) > 0 {
            throw StoreError.duplicateRecord
        }
        let entityCategory = TrackerCategoryEntity(context: context)
        entityCategory.title = trimmedTitle
    }

    func deleteCategory(title: String) throws {
        let request = TrackerCategoryEntity.fetchRequest()
        request.predicate = NSPredicate(
            format: "%K == %@",
            #keyPath(TrackerCategoryEntity.title),
            title
        )
        request.fetchLimit = 1

        guard let entity = try context.fetch(request).first else {
            throw StoreError.entityNotFound
        }

        context.delete(entity)
    }

    func fetchCategoryEntity(title: String) throws -> TrackerCategoryEntity {
        let request = TrackerCategoryEntity.fetchRequest()
        request.predicate = NSPredicate(
            format: "%K == %@",
            #keyPath(TrackerCategoryEntity.title),
            title
        )
        request.fetchLimit = 1
        guard let entity = try context.fetch(request).first else {
            throw StoreError.entityNotFound
        }
        return entity
    }
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(
        _ controller: NSFetchedResultsController<any NSFetchRequestResult>
    ) {
        delegate?.trackerCategoryStoreDidUpdate()
    }
}
