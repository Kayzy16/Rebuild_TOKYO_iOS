//
//  BasicConfigs.swift
//  app
//
//  Created by 高木一弘 on 2021/11/21.
//

import Foundation
import RealmSwift

class BasicConfigs : Object,Identifiable {
    
    @objc dynamic var id            : String = NSUUID().uuidString
    @objc dynamic var rememberPW    : Int = 0
    @objc dynamic var mail          : String = ""
    @objc dynamic var password      : String = ""
    @objc dynamic var defaultTraner : String = ""
    
    @objc dynamic var updateDate     : Date = NSDate() as Date
    @objc dynamic var createDate     : Date = NSDate() as Date
    @objc dynamic var deleteFlg     : Int    = 0
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
