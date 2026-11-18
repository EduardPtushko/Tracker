//
//  CoreDataStack.swift
//  Tracker
//
//  Created by Eduard Ptushko on 12.11.2026.
//

import CoreData

final class CoreDataStack {

    static let shared = CoreDataStack()
    let persistentContainer: NSPersistentContainer

    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    init(modelName: String = "Tracker", inMemory: Bool = false) {
        WeekDaysValueTransformer.register()

        persistentContainer = NSPersistentContainer(name: modelName)

        if inMemory {
            persistentContainer.persistentStoreDescriptions.first?.url = URL(
                fileURLWithPath: "/dev/null"
            )
        }

        persistentContainer.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                assertionFailure(
                    "Unresolved Core Data error: \(error), \(error.userInfo)"
                )
            }
        }

        persistentContainer.viewContext.automaticallyMergesChangesFromParent =
            true
        persistentContainer.viewContext.mergePolicy =
            NSMergeByPropertyObjectTrumpMergePolicy
    }

    func saveContext() {
        let context = viewContext
        guard context.hasChanges else { return }

        do {
            try context.save()
        } catch {
            context.rollback()

            let nsError = error as NSError
            assertionFailure(
                "Failed to save Core Data context: \(nsError), \(nsError.userInfo)"
            )

        }
    }
}
