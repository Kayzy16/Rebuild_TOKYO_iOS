//
//  AuthLevelViewModel.swift
//  app
//
//  Created by 高木一弘 on 2022/02/26.
//

import Foundation
import FirebaseFirestore

class AuthLevelViewModel : ObservableObject {
    private var db = Firestore.firestore()
    
    @Published var entities : [AuthLevel] = []
    
    init(){
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = false
        db.settings = settings
    }
    
    func fetchData(){
        DispatchQueue.global().async {
            
            self.db.collection("80_AUTH_LEVEL")
                .order(by: "10_LEVEL")
                .addSnapshotListener{ (QuerySnapshot, error) in
                guard let documents = QuerySnapshot?.documents else {
                    return
                }
                
                self.entities = documents.map { QueryDocumentSnapshot -> AuthLevel in
                    let authLevel = AuthLevel()
                    let data = QueryDocumentSnapshot.data()
                    
                    authLevel.authLevel = data["10_LEVEL"] as? Int ?? 0
                    authLevel.name = data["20_NAME"] as? String ?? ""
                    authLevel.createDate = (data["70_CREATE_DATE"] as? Timestamp)!.dateValue()
                    authLevel.updateDate = (data["80_UPDATE_DATE"] as? Timestamp)!.dateValue()
                    authLevel.deleteFlg  = data["99_DELETE_FLG"] as? Int ?? 0
                    
                    print("authLevel data : \(data)")
                    
                    return authLevel
                }
            }
        }
    }
    
    func getAuthLevel(withLevel:Int) -> AuthLevel?{
        for i in 0..<self.entities.count {
            if self.entities[i].authLevel == withLevel{
                return self.entities[i]
            }
        }
        return nil
    }
}

