//
//  Customer.swift
//  ProtoTypeApp
//
//  Created by 高木一弘 on 2021/06/09.
//

import Foundation
import RealmSwift

class Customer : Object,Identifiable {

    @objc dynamic var id            : String = NSUUID().uuidString
    @objc dynamic var name          : String = ""
    @objc dynamic var mail          : String = ""
    @objc dynamic var password      : String = ""
    @objc dynamic var program       : String = ""
    @objc dynamic var deleteFlg     : Int = 0
    
    override static func primaryKey() -> String? {
        return "id"
      }
}
