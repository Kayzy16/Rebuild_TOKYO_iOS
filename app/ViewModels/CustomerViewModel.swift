//
//  CustomerViewModel.swift
//  ProtoTypeApp
//
//  Created by 高木一弘 on 2021/07/18.
//

import Foundation
import FirebaseFirestore

class CustomerViewModel : ObservableObject {
    private var db = Firestore.firestore()
    
    @Published var entities : [Customer] = []
    
    init(){
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = false
        db.settings = settings
    }
    
    func fetchData(){
        DispatchQueue.global().async {
            
            self.db.collection("30_CUSTOMER")
                .whereField("99_DELETE_FLG", isEqualTo: 0)
                .addSnapshotListener{ (QuerySnapshot, error) in
                guard let documents = QuerySnapshot?.documents else {
                    print("cannot get reserva data from firestore")
                    return
                }
                
                self.entities = documents.map { QueryDocumentSnapshot -> Customer in
                    let cus = Customer()
                    let data = QueryDocumentSnapshot.data()
                    cus.id   = QueryDocumentSnapshot.documentID
                    cus.name = data["10_NAME"] as? String ?? ""
                    cus.mail = data["20_EMAIL"] as? String ?? ""
                    cus.program = data["30_PROGRAM"] as? String ?? ""
                    cus.deleteFlg = data["99_DELETE_FLG"] as? Int ?? 0
                    
                    print("customer data : \(cus)")
                    
                    return cus
                }
            }
        }
    }
    
    func getName(byCustomerId : String) -> String? {
        if self.entities.count > 0{
            for cus in self.entities {
                if cus.id == byCustomerId {
                    return cus.name
                }
            }
        }
        return nil
    }
    
}
