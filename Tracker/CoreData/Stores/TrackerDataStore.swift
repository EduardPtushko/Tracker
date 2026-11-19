//
//  TrackerDataStore.swift
//  Tracker
//
//  Created by Eduard Ptushko on 18.11.2026.
//

import CoreData
import Foundation

protocol TrackerDataStoreDelegate: AnyObject {
    func trackerDataStoreDidUpdate()
}

protocol TrackerDataStoreProtocol: AnyObject {
    var delegate: TrackerDataStoreDelegate? { get set }

    func fetchCategories() -> [TrackerCategory]
    func addCategory(title: String) throws
    func deleteCategory(title: String) throws

    func fetchTrackers() -> [Tracker]
    func addTracker(
        _ tracker: Tracker,
        toCategoryWithTitle categoryTitle: String
    ) throws
    func deleteTracker(id: UUID) throws

    func fetchRecords() -> [TrackerRecord]
    func toggleRecord(for trackerId: UUID, on date: Date) throws
    func isTrackerCompleted(id: UUID, on date: Date) -> Bool
    func completedDaysCount(for trackerId: UUID) -> Int
}

final class TrackerDataStore: TrackerDataStoreProtocol {

    var delegate: (any TrackerDataStoreDelegate)?

    private let context: NSManagedObjectContext
    private let categoryStore: TrackerCategoryStore
    private let trackerStore: TrackerStore
    private let recordStore: TrackerRecordStore

    init(context: NSManagedObjectContext = CoreDataStack.shared.viewContext) {

        self.context = context
        self.categoryStore = TrackerCategoryStore(context: context)
        self.trackerStore = TrackerStore(context: context)
        self.recordStore = TrackerRecordStore(context: context)

        self.categoryStore.delegate = self
        self.trackerStore.delegate = self
        self.recordStore.delegate = self
    }

    func fetchCategories() -> [TrackerCategory] {
        categoryStore.fetchCategories()
    }

    func addCategory(title: String) throws {
        try performWithRollback {
            try categoryStore.addCategory(title: title)
        }
    }

    func deleteCategory(title: String) throws {
        try performWithRollback {
            try categoryStore.deleteCategory(title: title)
        }
    }

    func fetchTrackers() -> [Tracker] {
        trackerStore.fetchTrackers()
    }

    func addTracker(
        _ tracker: Tracker,
        toCategoryWithTitle categoryTitle: String
    ) throws {
        try performWithRollback {
            let categoryEntity: TrackerCategoryEntity
            if let existing = try? categoryStore.fetchCategoryEntity(
                title: categoryTitle
            ) {
                categoryEntity = existing
            } else {
                try categoryStore.addCategory(title: categoryTitle)
                categoryEntity = try categoryStore.fetchCategoryEntity(
                    title: categoryTitle
                )
            }

            try trackerStore.addTracker(tracker, category: categoryEntity)
        }
    }

    func deleteTracker(id: UUID) throws {
        try performWithRollback {
            try trackerStore.deleteTracker(id: id)
        }
    }

    func fetchRecords() -> [TrackerRecord] {
        recordStore.fetchRecords()
    }

    func toggleRecord(for trackerId: UUID, on date: Date) throws {
        try performWithRollback {
            let record = TrackerRecord(id: trackerId, date: date)

            if isTrackerCompleted(id: trackerId, on: date) {
                try recordStore.deleteRecord(record)
            } else {
                let trackerEntity = try trackerStore.fetchTrackerEntity(
                    id: trackerId
                )
                try recordStore.addRecord(record, for: trackerEntity)
            }
        }
    }

    func isTrackerCompleted(id: UUID, on date: Date) -> Bool {
        let normalisedDate = Calendar.current.startOfDay(for: date)
        return recordStore.fetchRecordEntity(
            id: id,
            normalisedDate: normalisedDate
        ) != nil
    }

    private func performWithRollback(_ operation: () throws -> Void) throws {
        do {
            try operation()
            if context.hasChanges {
                try context.save()
            }
        } catch {
            context.rollback()
            throw error
        }
    }

    func completedDaysCount(for trackerId: UUID) -> Int {
        recordStore.completedDaysCount(for: trackerId)
    }
}

extension TrackerDataStore: TrackerCategoryStoreDelegate {
    func trackerCategoryStoreDidUpdate() {
        delegate?.trackerDataStoreDidUpdate()
    }
}

extension TrackerDataStore: TrackerStoreDelegate {
    func trackersStoreDidUpdate() {
        delegate?.trackerDataStoreDidUpdate()
    }
}

extension TrackerDataStore: TrackerRecordStoreDelegate {
    func trackerRecordStoreDidUpdate() {
        delegate?.trackerDataStoreDidUpdate()
    }
}

#if DEBUG
    extension TrackerDataStore {
        func seedMockDataIfNeeded() {
            guard fetchCategories().isEmpty else { return }

            do {
                for category in MockTrackerData.categories {
                    try addCategory(title: category.title)
                    for tracker in category.trackers {
                        try addTracker(
                            tracker,
                            toCategoryWithTitle: category.title
                        )
                    }
                }

                for record in MockTrackerData.completedTrackers {
                    if !isTrackerCompleted(id: record.id, on: record.date) {
                        try toggleRecord(for: record.id, on: record.date)
                    }
                }
            } catch {
                assertionFailure("Failed to seed mock data: \(error)")
            }
        }
    }
#endif
