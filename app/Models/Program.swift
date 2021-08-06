//
//  Programs.swift
//  app
//
//  Created by 高木一弘 on 2021/08/01.
//

import Foundation

class Program : Identifiable {
    var id             : String = NSUUID().uuidString
    var name           : String = ""
    var num            : Int = 0
    var updateDate     : Date = NSDate() as Date
    var createDate     : Date = NSDate() as Date
    var deleteFlg      : Int = 0
}
