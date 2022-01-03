//
//  BasicConfigDao.swift
//  app
//
//  Created by 高木一弘 on 2021/11/21.
//

import Foundation
import RealmSwift

struct BasicConfigDao {
    private static var realm = try!Realm()
    
    public static func get() -> BasicConfigs {
        if let result = realm.objects(BasicConfigs.self).first {
            return result
        }
        else {
            createDefaultData()
            return realm.objects(BasicConfigs.self).first!
        }
    }
    private static func createDefaultData(){
        let data = BasicConfigs()
        try! realm.write(){
            realm.add(data)
        }
    }

    public static func update(with:BasicConfigs){
        if let data = realm.objects(BasicConfigs.self).first {
            try! realm.write(){
                data.rememberPW    = with.rememberPW
                data.mail          = with.mail
                data.password      = with.password
                data.defaultTraner = with.defaultTraner
                realm.add(data)
            }
        }
    }
}
