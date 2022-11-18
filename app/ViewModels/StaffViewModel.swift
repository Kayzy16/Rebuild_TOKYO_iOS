//
//  StaffViewModel.swift
//  ProtoTypeApp
//
//  Created by 高木一弘 on 2021/06/09.
//

import Foundation
import RealmSwift
import FirebaseFirestore

class StaffViewModel:ObservableObject {
    
    private var token : NotificationToken?
    private var modelResults = StaffDao.getAll()
    
    private var db = Firestore.firestore()
    
    @Published var entities : [Staff] = []
    
    init(){
        token = modelResults.observe {[weak self] _ in
            self?.entities = self?.modelResults.map{$0} ?? []
        }
        
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = false
        db.settings = settings
    }
    
    deinit {
        token?.invalidate()
    }
    
    func fetchData(){
        DispatchQueue.global().async {
            self.db.collection("20_STAFF")
                .whereField("99_DELETE_FLG", isEqualTo: 0)
                .addSnapshotListener{ (QuerySnapshot, error) in
                guard let documents = QuerySnapshot?.documents else {
//                    print("cannot get staff data from firestore")
                    return
                }
                
                
                self.entities = documents.map { QueryDocumentSnapshot -> Staff in
                    let data = QueryDocumentSnapshot.data()
                    
                    
                    let id = QueryDocumentSnapshot.documentID
                    let name = data["10_NAME"] as? String ?? ""
                    let email = data["20_EMAIL"] as? String ?? ""
                    let auth = data["30_AUTH_LEVEL"] as? Int ?? -1
                    let createDate = (data["70_CREATE_DATE"] as? Timestamp)!.dateValue()
                    let updateDate = (data["80_UPDATE_DATE"] as? Timestamp)!.dateValue()
                    let deleteFlg  = data["99_DELETE_FLG"] as? Int ?? 0
                    
                    let staff = Staff()
                    staff.id = id
                    staff.name = name
                    staff.mail = email
                    staff.authLevel = auth
                    staff.createDate = createDate
                    staff.updateDate = updateDate
                    staff.deleteFlg = deleteFlg
                    
                    return staff
                }
            }
        }
    }
    
    func getStaff(byStaffId:String) -> Staff? {
        if entities.count > 0 {
            for staff in entities {
                if staff.id == byStaffId{
                    return staff
                }
            }
        }
        return nil
    }
    func save(with:Staff){
        
    }
}
