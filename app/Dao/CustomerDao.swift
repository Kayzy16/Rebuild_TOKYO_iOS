//
//  CustomerDao.swift
//  ProtoTypeApp
//
//  Created by 高木一弘 on 2021/06/09.
//

import Foundation
import RealmSwift

struct CustomerDao {
    
    private static var realm = try!Realm()
    
    public static func getAll() -> Results<Customer>{
        realm.objects(Customer.self)
    }
    
    public static func getFirst() -> Customer {
        realm.objects(Customer.self).first ?? getDefaultData()
    }
    
    public static func get(by:String) -> Customer?{
        realm.objects(Customer.self).filter("id == '\(by)'").first
    }
    
    public static func save(with:Customer){
        try!realm.write{
            realm.add(with)
        }
    }
    
    public static func createDefaultData(){
        let dataSet = getAll()
        if(dataSet.count == 0){
            let cus = Customer()
            cus.name = "顧客太郎"
            cus.mail = "testCustomer@gmail.com"
            cus.password = "password"
            
            let cus2 = Customer()
            cus2.name = "顧客二郎"
            cus2.mail = "testCustomer2@gmail.com"
            cus2.password = "password"
            
            save(with: cus)
            save(with: cus2)
        }
    }
    
    public static func getDefaultData() -> Customer {
        let cus = Customer()
        cus.name = "顧客太郎"
        cus.mail = "testCustomer@gmail.com"
        cus.password = "password"
        return cus
    }
}
