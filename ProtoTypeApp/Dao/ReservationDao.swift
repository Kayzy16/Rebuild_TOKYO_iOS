//
//  ReservationDao.swift
//  ProtoTypeApp
//
//  Created by 高木一弘 on 2021/06/11.
//

import Foundation
import RealmSwift

struct ReservationDao {
    
    private static var realm = try!Realm()
    
    public static func getAll() -> Results<Reservation>{
        realm.objects(Reservation.self).filter("deleteFlg == 0")
    }
    
    public static func get(by:String) -> Reservation? {
        realm.objects(Reservation.self).filter("shiftId == '\(by)'").filter("deleteFlg == 0").first
    }
    
    public static func getCustomerName(by:String) -> String? {
        let customerId = realm.objects(Reservation.self).filter("shiftId == '\(by)'").filter("deleteFlg == 0").first?.customerId ?? ""
        return CustomerDao.get(by: customerId)?.name ?? ""
    }
    
    public static func save(reserv:Reservation){
        try!realm.write{
            realm.add(reserv)
        }
    }
    
    public static func save(shiftId:String,customerId:String){
        try!realm.write{
            let res = Reservation()
            res.customerId = customerId
            res.shiftId = shiftId
            
            realm.add(res)
        }
    }
    public static func update(reserv:Reservation){
        try!realm.write{
            reserv.deleteFlg = 0
            realm.add(reserv,update: .modified)
        }
    }
    
    
    public static func delete(reserve:Reservation){
        try!realm.write{
            reserve.deleteFlg = 1
            realm.add(reserve,update:.modified)
        }
    }
    
    
    public static func save(with:Reservation){
        try!realm.write{
            realm.add(with)
        }
    }
}
