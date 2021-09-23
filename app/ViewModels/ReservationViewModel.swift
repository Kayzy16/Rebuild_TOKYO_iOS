//
//  ReservationViewModel.swift
//  ProtoTypeApp
//
//  Created by 高木一弘 on 2021/07/17.
//

import Foundation
import FirebaseFirestore

class ReservationViewModel : ObservableObject {
    private var db = Firestore.firestore()
    @Published var entities : [Reservation] = []
    
    init(){
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = false
        db.settings = settings
    }
    
    func fetchData(){
        DispatchQueue.global().async {
            
            self.db.collection("50_RESERVATION")
                .whereField("30_START_TIME", isGreaterThanOrEqualTo: Timestamp(date: Date()))
                .addSnapshotListener{ (QuerySnapshot, error) in
                guard let documents = QuerySnapshot?.documents else {
//                    print("can_not get reserva data from firestore")
                    return
                }
                
                self.entities = documents.map { QueryDocumentSnapshot -> Reservation in
                    let reservation = Reservation()
                    let data = QueryDocumentSnapshot.data()
                    
                    reservation.id           = QueryDocumentSnapshot.documentID
                    reservation.shiftId      = data["10_SHIFT_ID"] as? String ?? ""
                    reservation.customerId   = data["20_CUSTOMER_ID"] as? String ?? ""
                    reservation.startTime    = (data["30_START_TIME"] as? Timestamp)!.dateValue()
                    reservation.createDate   = (data["70_CREATE_DATE"] as? Timestamp)!.dateValue()
                    reservation.updateDate   = (data["80_UPDATE_DATE"] as? Timestamp)!.dateValue()
                    reservation.deleteFlg    = data["99_DELETE_FLG"] as? Int ?? 0
                    
//                    print("reservation data : \(reservation)")
                    
                    return reservation
                }
            }
        }
    }
    
    func get(byShiftId:String) -> Reservation?{
        if self.entities.count > 0 {
            for rsrv in self.entities {
                if rsrv.shiftId == byShiftId && rsrv.deleteFlg == 0{
                    return rsrv
                }
            }
        }
        
        return nil
    }
}
