//
//  ProtoTypeAppApp.swift
//  ProtoTypeApp
//
//  Created by 高木一弘 on 2021/06/08.
//

import SwiftUI

@main
struct ProtoTypeAppApp: App {
    
    @StateObject var viewRouter = ViewRouter()
    
    init(){
        StaffDao.createDefaultData()
        CustomerDao.createDefaultData()
        CustomerTicketDao.createDefaultData()
//        let aaa = StaffShiftDao.getAll()
//        print(aaa)
    }
    
    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(viewRouter)
        }
    }
}
