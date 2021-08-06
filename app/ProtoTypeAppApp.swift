//
//  ProtoTypeAppApp.swift
//  ProtoTypeApp
//
//  Created by 高木一弘 on 2021/06/08.
//

import SwiftUI
import FirebaseAuth
import Firebase


@main
struct ProtoTypeAppApp: App {
    
    @StateObject var viewRouter = ViewRouter()
    @StateObject var firestoreData = FirestoreDataRepository()
    
    @Environment(\.scenePhase) private var scenePhase
    
    init(){
        // initial configuration of Firebase
        FirebaseApp.configure()
        
//        StaffDao.createDefaultData()
//        CustomerDao.createDefaultData()
//        CustomerTicketDao.createDefaultData()
//        let aaa = StaffShiftDao.getAll()
//        print(aaa)
    }
    
    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(viewRouter).environmentObject(firestoreData)
        }
        .onChange(of:scenePhase) { phase in
            if phase == .background {
//                print("バックグラウンド！")
            }
            if phase == .active {
                print("フォアグラウンド！")
                firestoreData.fetchData()
            }
            if phase == .inactive {
//                print("バックグラウンドorフォアグラウンド直前")
            }
        }
    }
}
