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
    @State private var reloadFlag = true
    
    @Environment(\.scenePhase) private var scenePhase
    
    
    init(){
        // initial configuration of Firebase
        FirebaseApp.configure()
        
        // realm swift settings
        RealmMigrator.setDefaultConfiguration()
    }
    
    
    var body: some Scene {
        WindowGroup {
            if reloadFlag {
                ContentView().environmentObject(viewRouter).environmentObject(firestoreData)
                    .onAppear{
//                        print("リロード　A")
                        viewRouter.selectedStaffId = ""
                    }
            }
            else{
                ContentView().environmentObject(viewRouter).environmentObject(firestoreData)
                    .onAppear{
//                        print("リロード　B")
                        viewRouter.selectedStaffId = ""
                    }
            }
        }
        .onChange(of:scenePhase) { phase in
            if phase == .background {
//                print("バックグラウンド！")
            }
            if phase == .active {
//                print("データをフェッチ")
                renewData()
            }
            if phase == .inactive {
//                print("バックグラウンドorフォアグラウンド直前")
            }
        }
    }
    
    
    
    private func renewData(){
        let user = Auth.auth().currentUser
        if let user = user{
            let db = Firestore.firestore()
            let settings = FirestoreSettings()
            settings.isPersistenceEnabled = false
            db.settings = settings
            // カスタマだったらデータrenew
            let cusDocRef = db.collection("30_CUSTOMER").document(user.uid)
            cusDocRef.getDocument { (document, error) in
                if nil != error {
                    withAnimation{viewRouter.currentPage = .auth}
                    return
                }
                
                if let document = document, document.exists {
                    let data = document.data()
                    let deleteFlg = data?["99_DELETE_FLG"] as? Int ?? 0
                    if deleteFlg > 0{
                        withAnimation{viewRouter.currentPage = .auth}
                    }
                    else{
                        firestoreData.fetchData()
                        checkTicket()
                    }
                }
            }
            // スタッフだったらデータをrenew
            let stffDocRef = db.collection("20_STAFF").document(user.uid)
            stffDocRef.getDocument { (document, error) in
                if nil != error {
                    withAnimation{viewRouter.currentPage = .auth}
                    return
                }
                
                if let document = document, document.exists {
                    let data = document.data()
                    let deleteFlg = data?["99_DELETE_FLG"] as? Int ?? 0
                    if deleteFlg > 0{
                        withAnimation{viewRouter.currentPage = .auth}
                    }
                    else{
                        firestoreData.fetchData()
                        checkTicket()
                    }
                }
            }
            
        }
        else{
            withAnimation{viewRouter.currentPage = .auth}
        }
    }
    
    private func checkTicket(){
        let user = Auth.auth().currentUser
        if let user = user{
            let db = Firestore.firestore()
            let settings = FirestoreSettings()
            settings.isPersistenceEnabled = false
            db.settings = settings
            let docRef = db.collection("60_CUSTOMER_TICKET").document(user.uid)

            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    firestoreData.ticket.fetchData(customerId: user.uid)
                }
                reloadFlag.toggle()
            }
        }
    }
}
