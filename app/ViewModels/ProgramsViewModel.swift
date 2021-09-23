//
//  ProgramsViewModel.swift
//  app
//
//  Created by 高木一弘 on 2021/08/02.
//

import Foundation
import FirebaseFirestore

class ProgramsViewModel : ObservableObject {
    private var db = Firestore.firestore()
    
    @Published var entities : [Program] = []
    
    init(){
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = false
        db.settings = settings
    }
    
    func fetchData(){
        DispatchQueue.global().async {
            
            self.db.collection("70_PROGRAMS")
                .order(by: "10_NAME")
//                .whereField("30_START_TIME", isGreaterThanOrEqualTo: Timestamp(date: getJSTDate(fromUTC: Date())))
                .addSnapshotListener{ (QuerySnapshot, error) in
                guard let documents = QuerySnapshot?.documents else {
//                    print("cannot get program data from firestore")
                    return
                }
                
                self.entities = documents.map { QueryDocumentSnapshot -> Program in
                    let prgrm = Program()
                    let data = QueryDocumentSnapshot.data()
                    prgrm.id   = QueryDocumentSnapshot.documentID
                    prgrm.name = data["10_NAME"] as? String ?? ""
                    prgrm.num = data["20_NUM"] as? Int ?? 0
                    prgrm.createDate = (data["70_CREATE_DATE"] as? Timestamp)!.dateValue()
                    prgrm.updateDate = (data["80_UPDATE_DATE"] as? Timestamp)!.dateValue()
                    prgrm.deleteFlg  = data["99_DELETE_FLG"] as? Int ?? 0
                    
//                    print("program data : \(data)")
                    
                    return prgrm
                }
            }
        }
    }
    
    func getProgramName(withID:String) -> String{
        for i in 0...self.entities.count {
            if self.entities[i].id == withID{
                return self.entities[i].name
            }
        }
        return ""
    }
}
