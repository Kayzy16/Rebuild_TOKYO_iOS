//
//  StaffShiftDao.swift
//  ProtoTypeApp
//
//  Created by 高木一弘 on 2021/06/11.
//

import Foundation
import RealmSwift

struct StaffShiftDao {
    
    private static var realm = try!Realm()
    
    public static func getAll() -> Results<StaffShift>{
        realm.objects(StaffShift.self).filter("deleteFlg == 0")
    }
    
    public static func delete(shift:StaffShift){
        try!realm.write{
                shift.deleteFlg = 1
            shift.updateDate = Date()
                realm.add(shift,update:.modified)
        }
    }
    
    public static func update(on:StaffShift,by:StaffShift){
        try!realm.write{
            on.staffId = by.staffId
            on.startDate = by.startDate
            on.endDate = by.endDate
            on.startTime = by.startTime
            on.seq = by.seq
            on.deleteFlg = by.deleteFlg
            realm.add(on,update:.modified)
        }
    }
    
    public static func assign(day:Date,time:Date,sequence:Int,to:String){
        try!realm.write{
            let shift = StaffShift()
            shift.staffId = to
            shift.startDate = day
            shift.endDate = day
            shift.startTime = time
            shift.seq = sequence
            realm.add(shift)
        }
    }
    
    public static func assign(shift:StaffShift,to:String){
        try!realm.write{
            shift.staffId = to
            realm.add(shift,update: .modified)
        }
    }
    
    public static func get(date:Date,startTime:Date) -> Results<StaffShift> {
        let predicate = NSPredicate(format: "startDate ==  %@ AND startTime == %@",date as NSDate,startTime as NSDate)
        return realm.objects(StaffShift.self).filter(predicate).filter("deleteFlg == 0")
    }
    
    public static func get(staffId:String,date:Date,startTime:Date) -> Results<StaffShift> {
        let predicate = NSPredicate(format: "startDate ==  %@ AND startTime == %@",date as NSDate,startTime as NSDate)
        return realm.objects(StaffShift.self).filter("staffId == '\(staffId)'").filter(predicate).filter("deleteFlg == 0")
    }
    
    public static func get(staffId:String,date:Date,startTime:Date) -> StaffShift? {
        let predicate = NSPredicate(format: "startDate ==  %@ AND startTime == %@",date as NSDate,startTime as NSDate)
        return realm.objects(StaffShift.self).filter("staffId == '\(staffId)'").filter(predicate).filter("deleteFlg == 0").first
    }
    
    public static func get(date:Date,startTime:Date,seq:Int) -> StaffShift? {
        let predicate = NSPredicate(format: "startDate ==  %@ AND startTime == %@",date as NSDate,startTime as NSDate)
        return realm.objects(StaffShift.self).filter(predicate).filter("seq == \(seq)").filter("deleteFlg == 0").first
    }
    
    public static func getStaffName(date:Date,startTime:Date,seq:Int) -> String? {
        let predicate = NSPredicate(format: "startDate ==  %@ AND startTime == %@",date as NSDate,startTime as NSDate)
        let staffId = realm.objects(StaffShift.self).filter(predicate).filter("seq == \(seq)").filter("deleteFlg == 0").first?.staffId ?? ""
        let staffName = StaffDao.get(by: staffId)?.name ?? ""
        return staffName
    }
    
    
    public static func save(with:StaffShift){
        try!realm.write{
            realm.add(with)
        }
    }
}
