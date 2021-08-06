//
//  StaffDao.swift
//  ProtoTypeApp
//
//  Created by 高木一弘 on 2021/06/09.
//

import Foundation
import RealmSwift

struct StaffDao {
    private static var realm = try!Realm()
    
    public static func getAll() -> Results<Staff> {
        realm.objects(Staff.self)
    }
    
    public static func getFirst() -> Staff {
        realm.objects(Staff.self).first ?? getDefaultData()
    }
    
    public static func get(by:String) -> Staff? {
        realm.objects(Staff.self).filter("id == '\(by)'").first
    }
    
    public static func save(with:Staff){
        try!realm.write{
            realm.add(with)
        }
    }
    
    
    
    public static func update(with:Staff){
        try!realm.write{
            realm.add(with,update: .modified)
        }
    }
    
    public static func update(target:Staff,with:Staff){
        try!realm.write{
            target.name = with.name
            target.mail = with.mail
            target.password = with.password
            realm.add(target,update: .modified)
        }
    }
    
    public static func createDefaultData(){
        let dataSet = getAll()
        if(dataSet.count == 0){
            let staff = Staff()
            staff.name = "スタッフ太郎"
            staff.mail = "testStaff@gmail.com"
            staff.password = "password"
            save(with: staff)
            
            let staff2 = Staff()
            staff2.name = "スタッフ二郎"
            staff2.mail = "testStaff2@gmail.com"
            staff2.password = "password"
            save(with: staff2)
        }
    }
    
    public static func getDefaultData() -> Staff {
        let staff = Staff()
        staff.name = "スタッフ太郎"
        staff.mail = "testStaff@gmail.com"
        staff.password = "password"
        return staff
    }
}
