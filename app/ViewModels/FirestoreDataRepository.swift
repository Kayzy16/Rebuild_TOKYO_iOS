//
//  FirestoreDataRepository.swift
//  ProtoTypeApp
//
//  Created by 高木一弘 on 2021/07/17.
//

import Foundation
import Firebase

class FirestoreDataRepository: ObservableObject {
    @Published var staff = StaffViewModel()
    @Published var staffShift = StaffShiftViewModel()
    @Published var reservation = ReservationViewModel()
    @Published var ticket = CustomerTicketViewModel() // must be fetched after login completion
    @Published var customer = CustomerViewModel()
    @Published var programs = ProgramsViewModel()
    @Published var authLevel = AuthLevelViewModel()
    
    init(){
        fetchData()
    }
    
    func fetchData(){
        staff.fetchData()
        staffShift.fetchData()
        reservation.fetchData()
        customer.fetchData()
        programs.fetchData()
        authLevel.fetchData()
    }
}
