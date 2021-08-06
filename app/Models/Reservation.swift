//
//  Reservation.swift
//  ProtoTypeApp
//
//  Created by 高木一弘 on 2021/06/11.
//

import Foundation
import RealmSwift


class Reservation : Object,Identifiable {
    @objc dynamic var id            : String = NSUUID().uuidString
    @objc dynamic var shiftId       : String = ""
    @objc dynamic var customerId    : String = ""
    @objc dynamic var startTime     : Date = NSDate() as Date
    @objc dynamic var updateDate    : Date = NSDate() as Date
    @objc dynamic var createDate    : Date = NSDate() as Date
    @objc dynamic var deleteFlg     : Int    = 0
    
    override static func primaryKey() -> String? {
        return "id"
      }
}
