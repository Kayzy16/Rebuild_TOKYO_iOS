//
//  StaffShiftViewModel.swift
//  ProtoTypeApp
//
//  Created by 高木一弘 on 2021/07/17.
//

import Foundation
import FirebaseFirestore

class StaffShiftViewModel : ObservableObject {
    private var db = Firestore.firestore()
    @Published var entities : [StaffShift] = []
    
    init(){
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = false
        db.settings = settings
    }
    
    func fetchData(){
        DispatchQueue.global().async {
            self.db.collection("40_STAFF_SHIFT")
                .whereField("40_START_TIME", isGreaterThanOrEqualTo: Timestamp(date: Date()))
                .addSnapshotListener{ (QuerySnapshot, error) in
                guard let documents = QuerySnapshot?.documents else {
//                    print("cannot get staff data from firestore")
                    return
                }
                
                self.entities = documents.map { QueryDocumentSnapshot -> StaffShift in
                    let staffShift = StaffShift()
                    let data = QueryDocumentSnapshot.data()
                    
                    staffShift.id           = QueryDocumentSnapshot.documentID
                    staffShift.staffId      = data["10_STAFF_ID"] as? String ?? ""
                    staffShift.startDate    = (data["20_START_DATE"] as? Timestamp)!.dateValue()
                    staffShift.endDate      = (data["30_END_DATE"] as? Timestamp)!.dateValue()
                    staffShift.startTime    = (data["40_START_TIME"] as? Timestamp)!.dateValue()
                    staffShift.seq          = data["50_SEQ"] as? Int ?? 0
                    staffShift.createDate   = (data["70_CREATE_DATE"] as? Timestamp)!.dateValue()
                    staffShift.updateDate   = (data["80_UPDATE_DATE"] as? Timestamp)!.dateValue()
                    
                    
//                    staffShift.startDate    = getJSTDate(fromUTC: (data["20_START_DATE"] as? Timestamp)!.dateValue())
//                    staffShift.endDate      = getJSTDate(fromUTC: (data["30_END_DATE"] as? Timestamp)!.dateValue())
//                    staffShift.startTime    = getJSTDate(fromUTC: (data["40_START_TIME"] as? Timestamp)!.dateValue())
//                    staffShift.seq          = data["50_SEQ"] as? Int ?? 0
//                    staffShift.createDate   = getJSTDate(fromUTC: (data["70_CREATE_DATE"] as? Timestamp)!.dateValue())
//                    staffShift.updateDate   = getJSTDate(fromUTC: (data["80_UPDATE_DATE"] as? Timestamp)!.dateValue())
                    staffShift.deleteFlg    = data["99_DELETE_FLG"] as? Int ?? 0
                    
//                    print("staff shift data : \(staffShift)")
                    
                    return staffShift
                }
            }
        }
    }
    
    
    
    func delete(with:StaffShift){
        let docRef = db.collection("40_STAFF_SHIFT").document(with.id)
        
        let newData = StaffShift()
        newData.staffId    = with.staffId
        newData.startDate  = with.startDate
        newData.endDate    = with.endDate
        newData.startTime  = with.startTime
        newData.seq        = with.seq
        newData.createDate = with.createDate
        newData.updateDate = with.updateDate
        newData.deleteFlg  = 1
        
        docRef.setData([
            "10_STAFF_ID"   : with.staffId,
            "20_START_DATE" : Timestamp(date:with.startDate),
            "30_END_DATE"   : Timestamp(date:with.endDate),
            "40_START_TIME" : Timestamp(date:with.startTime),
            "50_SEQ"        : with.seq,
            "70_CREATE_DATE": Timestamp(date:with.createDate),
            "80_UPDATE_DATE": Timestamp(date:with.updateDate),
            "99_DELETE_FLG" : 1
        ],merge: true){ error in
            if let error = error {
//                print("Error writing staff shift : \(error)")
            }
            else{
                for i in 0..<self.entities.count{
                    if with.id == self.entities[i].id{
                        self.entities.remove(at: i)
                        break
                    }
                }
            }
        }
    }
    
    func getData(date:Date,startTime:Date) -> [StaffShift]?{
        if entities.count > 0 {
            var result : [StaffShift] = []
            for shift in entities{
                if (shift.startDate == date && shift.startTime == startTime && shift.deleteFlg == 0){
                    result.append(shift)
                }
            }
            return result
        }
        return nil
    }
    
    func getData(date: Date, startTime: Date, seq: Int) -> StaffShift? {
        if entities.count > 0 {
            for shift in entities {
                if (shift.startDate == date && shift.startTime == startTime && shift.seq == seq && shift.deleteFlg == 0){
                    return shift
                }
            }
        }
        return nil
    }
    
    func getData(staffId:String,date:Date,startTime:Date) -> StaffShift? {
        if entities.count > 0 {
//            print(entities)
            for shift in entities {
                if (shift.startDate == date && shift.startTime == startTime && shift.staffId == staffId && shift.deleteFlg == 0){
                    return shift
                }
            }
        }
        return nil
    }
    
    func count(staffId: String, date: Date, startTime: Date) -> Int{
        var result = 0
        if entities.count > 0 {
            for shift in entities {
                if (shift.staffId == staffId && shift.startDate == date && shift.startTime == startTime && shift.deleteFlg == 0) {
                    result = result + 1
                }
            }
        }
        return result
    }
}
