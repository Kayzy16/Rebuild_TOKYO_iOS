//
//  AuthLevel.swift
//  app
//
//  Created by 高木一弘 on 2022/02/26.
//

import Foundation

class AuthLevel : Identifiable {
    var id             : String = NSUUID().uuidString
    var authLevel      : Int    = 0
    var name           : String = ""
    
    var updateDate     : Date = NSDate() as Date
    var createDate     : Date = NSDate() as Date
    var deleteFlg      : Int    = 0
}
