//
//  CustomerTicketViewModel.swift
//  ProtoTypeApp
//
//  Created by 高木一弘 on 2021/07/18.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class CustomerTicketViewModel:ObservableObject {
    private var db = Firestore.firestore()
    
    @Published var entity = CustomerTicket()
    
    init(){
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = false
        db.settings = settings
    }
    
    func fetchData(customerId:String){
        DispatchQueue.global().async {
            
            let docRef = self.db.collection("60_CUSTOMER_TICKET").document(customerId)
            
            docRef.getDocument{(document,error)in
                if let document = document, document.exists{
                    let data               = document.data()
                    self.entity.id         = document.documentID
                    self.entity.ticketLeft = data?["10_NUM_LEFT"] as? Int ?? 0
                    self.entity.createDate = (data?["70_CREATE_DATE"] as? Timestamp)!.dateValue()
                    self.entity.updateDate = (data?["80_UPDATE_DATE"] as? Timestamp)!.dateValue()
                    self.entity.deleteFlg  = data?["99_DELETE_FLG"] as? Int ?? 0
                    
                    if isMonthChanged(from: self.entity.updateDate){
                        self.renewTicket()
                    }
                }
                else{
                    print("failed to get Customer Ticket for : \(customerId)")
                }
            }
        }
    }
    
    func renewTicket(){
        let user = Auth.auth().currentUser
        
        if let user = user{
            let docRef = self.db.collection("30_CUSTOMER").document(user.uid)
            docRef.getDocument { (document, error) in
                if let csDocument = document, csDocument.exists {
                    let csData = csDocument.data()
                    let programId = csData?["30_PROGRAM"] as? String ?? ""
                    
                    if !programId.isEmpty{
                        self.db.collection("70_PROGRAMS").document(programId).getDocument{(doc, error) in
                            if let prgrmDocument = doc,prgrmDocument.exists {
                                let prgrmData = prgrmDocument.data()
                                let initialTicketNum = prgrmData?["20_NUM"] as? Int ?? 0
                                let now = Timestamp(date:Date())
                                self.db.collection("60_CUSTOMER_TICKET").document(user.uid).updateData([
                                    "10_NUM_LEFT" : initialTicketNum,
                                    "80_UPDATE_DATE" : now
                                ]) { err in
                                    if let err = err {
                                        print("Error initializing document: \(err)")
                                    } else {
                                        self.entity.ticketLeft = initialTicketNum
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func isTicketLeft() -> Bool {
        if entity.ticketLeft > 0{
            return true
        }
        else{
            return false
        }
    }
    
    func getTicketNum() -> Int {
        return entity.ticketLeft
    }
    
}
