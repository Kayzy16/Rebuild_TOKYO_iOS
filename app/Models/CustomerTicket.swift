//
//  CustomerTicket.swift
//  ProtoTypeApp
//
//  Created by 高木一弘 on 2021/06/16.
//

import Foundation
//import RealmSwift
//class CustomerTicket : Object,Identifiable {
//    @objc dynamic var id            : String = NSUUID().uuidString
//    @objc dynamic var updateDate     : Date = NSDate() as Date
//    @objc dynamic var createDate     : Date = NSDate() as Date
//    @objc dynamic var ticketLeft    : Int    = default_ticket_Num
//    @objc dynamic var deleteFlg     : Int    = 0
//
//    override static func primaryKey() -> String? {
//        return "id"
//      }
//}

class CustomerTicket : Identifiable {
    var id             : String = NSUUID().uuidString
    var updateDate     : Date = NSDate() as Date
    var createDate     : Date = NSDate() as Date
    var ticketLeft     : Int    = default_ticket_Num
    var deleteFlg      : Int    = 0
}

