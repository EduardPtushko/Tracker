//
//  TrackerStore.swift
//  Tracker
//
//  Created by Eduard Ptushko on 13.11.2026.
//

import CoreData

protocol TrackerStoreDelegate: AnyObject {
    func trackersStoreDidUpdate()
}

final class TrackerStore: NSObject {
    weak var delegate: TrackerStoreDelegate?

    private let context: NSManagedObjectContext
    private let uiColorMarshalling = UIColorMarshalling()

    private lazy var fetchedResultsController: NSFetchedResultsController = {
        let request = TrackerEntity.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: "name", ascending: true)
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

    func fetchTrackers() -> [Tracker] {
        let entities = fetchedResultsController.fetchedObjects ?? []
        return entities.compactMap { Tracker(from: $0) }
    }

    func fetchTrackerEntity(id: UUID) throws -> TrackerEntity {
        let request = TrackerEntity.fetchRequest()
        request.predicate = NSPredicate(
            format: "%K == %@",
            #keyPath(TrackerEntity.trackerId),
            id as CVarArg
        )
        request.fetchLimit = 1
        guard let entity = try context.fetch(request).first else {
            throw StoreError.entityNotFound
        }
        return entity
    }

    func addTracker(_ tracker: Tracker, category: TrackerCategoryEntity)
        throws
    {
        let trimmedName = tracker.name.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        guard !trimmedName.isEmpty, !tracker.emoji.isEmpty else {
            throw StoreError.invalidData
        }
        let trackerEntity = TrackerEntity(context: context)
        trackerEntity.trackerId = tracker.id
        trackerEntity.name = trimmedName
        trackerEntity.emoji = tracker.emoji
        trackerEntity.colorHex = uiColorMarshalling.hexString(
            from: tracker.color
        )
        trackerEntity.schedule = tracker.schedule as NSObject?
        trackerEntity.category = category
    }

    func deleteTracker(id: UUID) throws {
        let entity = try fetchTrackerEntity(id: id)
        context.delete(entity)
    }
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(
        _ controller: NSFetchedResultsController<any NSFetchRequestResult>
    ) {
        delegate?.trackersStoreDidUpdate()
    }
}
