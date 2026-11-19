//
//  TrackerRecord+CoreData.swift
//  Tracker
//
//  Created by Eduard Ptushko on 17.11.2026.
//

import UIKit

extension TrackerRecord {
    init?(
        from entity: TrackerRecordEntity
    ) {
        guard
            let trackerId = entity.trackerId,
            let date = entity.date
        else {
            return nil
        }
        self.id = trackerId
        self.date = date
    }
}
