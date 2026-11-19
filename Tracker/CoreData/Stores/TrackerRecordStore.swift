//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Eduard Ptushko on 13.11.2026.
//

import CoreData

protocol TrackerRecordStoreDelegate: AnyObject {
    func trackerRecordStoreDidUpdate()
}

final class TrackerRecordStore: NSObject {
    weak var delegate: TrackerRecordStoreDelegate?

    private let calendar = Calendar.current
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    convenience override init() {
        self.init(context: CoreDataStack.shared.viewContext)
    }

    func fetchRecords() -> [TrackerRecord] {
        let request = TrackerRecordEntity.fetchRequest()
        guard let records = try? context.fetch(request) else { return [] }

        return records.compactMap { TrackerRecord(from: $0) }
    }

    func addRecord(_ record: TrackerRecord, for trackerEntity: TrackerEntity)
        throws
    {
        let normalisedDate = calendar.startOfDay(for: record.date)

        if fetchRecordEntity(id: record.id, normalisedDate: normalisedDate)
            != nil
        {
            throw StoreError.duplicateRecord
        }

        let recordEntity = TrackerRecordEntity(context: context)
        recordEntity.date = normalisedDate
        recordEntity.trackerId = record.id
        recordEntity.tracker = trackerEntity

        delegate?.trackerRecordStoreDidUpdate()
    }

    func deleteRecord(_ record: TrackerRecord) throws {
        let normalisedDate = calendar.startOfDay(for: record.date)
        guard
            let fetchedRecord = fetchRecordEntity(
                id: record.id,
                normalisedDate: normalisedDate
            )
        else {
            throw StoreError.entityNotFound
        }
        context.delete(fetchedRecord)
 
        delegate?.trackerRecordStoreDidUpdate()
    }

    func fetchRecordEntity(id: UUID, normalisedDate: Date)
        -> TrackerRecordEntity?
    {
        guard
            let nextDay = calendar.date(
                byAdding: .day,
                value: 1,
                to: normalisedDate
            )
        else {
            return nil
        }
        let request = TrackerRecordEntity.fetchRequest()
        request.predicate = NSPredicate(
            format: "%K == %@ AND %K >= %@ AND %K < %@",
            #keyPath(TrackerRecordEntity.trackerId),
            id as CVarArg,
            #keyPath(TrackerRecordEntity.date),
            normalisedDate as NSDate,
            #keyPath(TrackerRecordEntity.date),
            nextDay as NSDate
        )
        request.fetchLimit = 1
        return try? context.fetch(request).first
    }

    func completedDaysCount(for trackerId: UUID) -> Int {
        let request = TrackerRecordEntity.fetchRequest()
        request.predicate = NSPredicate(
            format: "%K == %@",
            #keyPath(TrackerRecordEntity.trackerId),
            trackerId as CVarArg
        )

        do {
            return try context.count(for: request)
        } catch {
            assertionFailure(
                "Failed to count records for tracker \(trackerId): \(error)"
            )
            return 0
        }
    }

}
