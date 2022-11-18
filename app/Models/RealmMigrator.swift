//
//  RealmMigrator.swift
//  app
//
//  Created by 高木一弘 on 2021/11/21.
//

import Foundation
import RealmSwift

enum RealmMigrator {
    static private func migrationBlock(
        migration: Migration,
        oldSchemaVersion: UInt64
    ) {
        // version 1
        if oldSchemaVersion < 1 {
        }
    }

    static func setDefaultConfiguration() {
        let config = Realm.Configuration(
            schemaVersion: 2,
            migrationBlock: migrationBlock)
            Realm.Configuration.defaultConfiguration = config
    }
}
