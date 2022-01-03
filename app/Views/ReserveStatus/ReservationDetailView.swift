//
//  ReservationDetailView.swift
//  app
//
//  Created by 高木一弘 on 2021/11/23.
//

import SwiftUI

struct ReservationDetailView: View {
    
    var reserve : Reservation
    @State var staffName : String = ""
    @EnvironmentObject var firestoreData : FirestoreDataRepository
    
    private var year      : String
    private var month     : String
    private var day       : String
    private var startTime : String
    private var endTime   : String
    
    
    init(_ res : Reservation){
        self.reserve = res
        
        self.year  = String(getYearInt(from: res.startTime))
        self.month = String(getMonthInt(from: res.startTime))
        self.day   = String(getDayInt(from: res.startTime))
        
        self.startTime = getFormatedTime(from: res.startTime)
        self.endTime   = getFormatedTime(from: addMin(to: res.startTime, by: lesson_length))
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("予約日：")
                    .padding(.top)
                Spacer()
                Text(year + " / " + month + " / " + day)
                    .padding(.top)
            }
            .padding(.leading)
            .padding(.trailing)
            
            Divider()
            HStack {
                Text("予約時間：")
                Spacer()
                Text(startTime + " - " + endTime)
            }
            .padding(.leading)
            .padding(.trailing)
            Divider()
            HStack {
                Text("トレーナー：")
                    .padding(.bottom)
                Spacer()
                Text(staffName)
                    .padding(.bottom)
            }
            .padding(.leading)
            .padding(.trailing)
            
        }
        .background(Color(UIColor.systemBackground))
        .onAppear{
            let shiftId = self.reserve.shiftId
            if let staffId = firestoreData.staffShift.getStaffId(shiftId: shiftId){
                staffName = firestoreData.staff.getStaff(byStaffId: staffId)?.name ?? ""
            }
        }
    }
}

struct ReservationDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ReservationDetailView(Reservation())
    }
}
