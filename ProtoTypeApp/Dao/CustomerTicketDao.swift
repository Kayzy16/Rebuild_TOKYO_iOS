//
//  CustomerTicketDao.swift
//  ProtoTypeApp
//
//  Created by 高木一弘 on 2021/06/18.
//

import Foundation
import RealmSwift

struct CustomerTicketDao {
    private static var realm = try!Realm()
    
    
    public static func get() -> CustomerTicket? {
        realm.objects(CustomerTicket.self).first
    }
    
    public static func save(ticket:CustomerTicket){
        try!realm.write{
            realm.add(ticket)
        }
    }
    
    public static func isTicketLeft() -> Bool {
        let ticket = get()
        if (ticket!.ticketLeft>0) {
            return true
        }
        else {
            return false
        }
    }
    public static func consume(){
        let ticket = get()
        try!realm.write{
            if isTicketLeft(){
                ticket!.ticketLeft = ticket!.ticketLeft - 1
                ticket!.updateDate = Date()
                realm.add(ticket!,update: .modified)
            }
        }
    }
    public static func restore(){
        let ticket = get()
        try!realm.write{
            ticket!.ticketLeft = ticket!.ticketLeft + 1
            ticket!.updateDate = Date()
            realm.add(ticket!,update: .modified)
        }
    }
    
    public static func initialize(){
        let issuedMonth = getMonthInt(from: get()!.updateDate)
        let thisMonth = getMonthInt(from: Date())
        
        if issuedMonth != thisMonth{
            try!realm.write{
                let ticket = get()
                ticket!.ticketLeft = default_ticket_Num
                ticket!.updateDate = Date()
                realm.add(ticket!,update: .modified)
            }
        }
    }
    
    public static func createDefaultData(){
        let dataSet = get()
        if(dataSet == nil){
            let ticket = CustomerTicket()
            
            save(ticket: ticket)
        }
    }
    public static func getTicketNum() -> Int{
        return get()?.ticketLeft ?? -99
    }
    
    public static func getDefaultData() -> CustomerTicket {
        return CustomerTicket()
    }
}
