//
//  StaffShift.swift
//  ProtoTypeApp
//
//  Created by 高木一弘 on 2021/06/11.
//

import Foundation
import RealmSwift


class StaffShift : Object,Identifiable {
    @objc dynamic var id            : String = NSUUID().uuidString
    @objc dynamic var staffId       : String = ""
    @objc dynamic var startDate     : Date = NSDate() as Date
    @objc dynamic var endDate       : Date = NSDate() as Date
    @objc dynamic var startTime     : Date = NSDate() as Date
//    @objc dynamic var endTime       : Date   = Date()
    @objc dynamic var seq           : Int    = 0 //同一日複数シフトの場合の判別
    @objc dynamic var deleteFlg     : Int    = 0
    
    override static func primaryKey() -> String? {
        return "id"
      }
}
