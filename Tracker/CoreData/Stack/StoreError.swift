//
//  StoreError.swift
//  Tracker
//
//  Created by Eduard Ptushko on 17.11.2026.
//

import Foundation

enum StoreError: Error {
    case entityNotFound
    case invalidData
    case duplicateRecord
    case duplicateCategory
}
