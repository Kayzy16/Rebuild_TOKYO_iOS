//
//  EventFrameView.swift
//  ProtoTypeApp
//
//  Created by 高木一弘 on 2021/06/11.
//

import SwiftUI
import FirebaseFirestore
import GradientCircularProgress

struct EventFrameView: View {
    
    @EnvironmentObject var viewRouter: ViewRouter
    @EnvironmentObject var firestoreData : FirestoreDataRepository
    var gcp = GradientCircularProgress()
    
    var date : Date
    var startTime : Date
    var startTimeLabel : String
    var endTimeLabel : String
    
    @State var shift       : StaffShift?
    @State var staff       : Staff?
    @State var reservation : Reservation?
    
    enum SpotState {
        case disabled
        case enabled
        case reserved
        case conflicted
    }
    @State private var spotState : SpotState = .disabled
    
    enum AlertType {
        case confirm
        case complete
        case failed
    }
    @State private var alertType : AlertType = .confirm
    
    @State var reservationAlert = false
    
    var body: some View {
        
        if viewRouter.loginUserType == .customer { // ユーザ
            ZStack(alignment:.center){
                
                Rectangle()
//                    .strokeBorder(getStrokeColor(),lineWidth: event_frame_stroke)
                    .foregroundColor(getSpotColorByState())
                    .background(getSpotColorByState())
                    .frame(width: CGFloat(event_frame_width), height: CGFloat(event_frame_height))
                    .onTapGesture {
                        if spotState != .disabled {
                            reservationAlert.toggle()
                        }
                        
                        print(self.spotState)
                        
                    }
                    .alert(isPresented:$reservationAlert){
                        getAlertByState()
                    }
                
                VStack{
                    Spacer()
                    Text(startTimeLabel)
                        .font(.caption2)
                    Text("|")
                        .font(.caption2)
                        .padding(.top)
                        .padding(.bottom)
                    Text(endTimeLabel)
                        .font(.caption2)
                    Spacer()
                }
            }
            .onAppear{
                self.spotState = getSpotState()
                print(viewRouter.selectedStaffId)
                if(viewRouter.selectedStaffId.isEmpty){
                    if firestoreData.staff.entities.count>0{
                        viewRouter.selectedStaffId = firestoreData.staff.entities[0].id
                    }
                }
                self.shift = firestoreData.staffShift.getData(staffId: viewRouter.selectedStaffId, date: self.date, startTime: self.startTime)
                if self.shift != nil {
                    self.reservation = firestoreData.reservation.get(byShiftId: self.shift!.id)
                }
            }
        }
        else{ // スタッフ
            ZStack{
                Rectangle()
                .foregroundColor(getSpotColorByState())
                .background(getSpotColorByState())
                .frame(width: CGFloat(event_frame_width), height: CGFloat(event_frame_height))
                
                
                
                VStack {
                    HStack{
                        Spacer()
                        Text(startTimeLabel)
                            .font(.caption2)
                        Text("-")
                            .font(.caption2)
                            .padding(.top)
                            .padding(.bottom)
                        Text(endTimeLabel)
                            .font(.caption2)
                        Spacer()
                    }
                    .frame(height:CGFloat(event_frame_height*0.2))
                    ForEach(0..<max_reservable_spot){ i in
                        EventRectView(date: self.date, startTime: self.startTime, seq: i)
                            .environmentObject(firestoreData)
                        Spacer()
                    }

                    // シフト枠1のキャプション
//                    HStack{
//                        Text(startTimeLabel)
//                            .font(.caption2)
//                        Text("-")
//                            .font(.caption2)
//                        Text(endTimeLabel)
//                            .font(.caption2)
//                    }
////                    .frame(height:CGFloat(event_frame_height*0.1))
//
//                    // シフト枠1
//                    EventRectView(date: self.date, startTime: self.startTime, seq: 0)
//                    .environmentObject(firestoreData)
//                    Spacer()
//
//
//                    // シフト枠2のキャプション
//                    HStack{
//                        Spacer()
//                        Text(startTimeLabel)
//                            .font(.caption2)
//                        Text("-")
//                            .font(.caption2)
//                            .padding(.top)
//                            .padding(.bottom)
//                        Text(endTimeLabel)
//                            .font(.caption2)
//                        Spacer()
//                    }
//                    .frame(height:CGFloat(event_frame_height*0.1))
//
//                    EventRectView(date: self.date, startTime: self.startTime, seq: 1)
//                    .environmentObject(firestoreData)
//                    Spacer()
//                    ForEach(0..<max_reservable_spot){ i in
//                        EventRectView(date: self.date, startTime: self.startTime, seq: i)
//                            .environmentObject(firestoreData)
//                        Spacer()
//                    }
                }
                .frame(width: CGFloat(event_frame_width), height: CGFloat(event_frame_height))
            }
        }
    }
    
    
    private func isShiftValid(shift:StaffShift) -> Bool {
        if(!shift.staffId.isEmpty){ // シフトのデータが有効（スタッフIDが入力ずみ）
            return true
        }
        else{ // シフトのデータが無効(シフトデータは存在するのに、スタッフIDが空)
            return false
        }
    }
    
    private func isReserved(reserVation:Reservation) -> Bool {
        if nil != reservation{
            return true
        }
        else {
            return false
        }
    }
    
    private func isMyReserve(reservation:Reservation) -> Bool{
//        self.reservation = firestoreData.reservation.get(byShiftId: self.shift!.id)
//        if viewRouter.loginCustomerId == ReservationDao.get(by: reservation.shiftId)?.customerId{
//            return true
//        }
        if viewRouter.loginCustomerId == reservation.customerId{
            return true
        }
        else{
            return false
        }
    }
    
    private func getSpotState() -> SpotState{
        
        if isLessonPassed(startTime: self.startTime){
            return .disabled
        }
        
//        if let shift = StaffShiftDao.get(staffId: viewRouter.selectedStaffId, date: self.date, startTime: self.startTime){
        if let shift = firestoreData.staffShift.getData(staffId: viewRouter.selectedStaffId, date: self.date, startTime: self.startTime){
            if isShiftValid(shift: shift){
                if isBookedAnotherSpot(checking: shift){
                    return .disabled
                }
                
                if let reservation = firestoreData.reservation.get(byShiftId: shift.id){
                    if isMyReserve(reservation: reservation){
                        return .reserved
                    }
                    else{
                        return .disabled
                    }
                }
                else{
                    return .enabled
                }
            }
            else {
                return.disabled
            }
        }
        else{
            return .disabled
        }
    }
    
    private func isBookedAnotherSpot(checking : StaffShift) -> Bool {
        var counter = 0
        if let shifts = firestoreData.staffShift.getData(date: self.date, startTime: self.startTime){
            if shifts.count > 0{
                shifts.forEach(){(shift :StaffShift) in
                    if checking.id != shift.id{
                        if let reserve = firestoreData.reservation.get(byShiftId: shift.id){
                            if isMyReserve(reservation: reserve){
                                counter = counter + 1
                            }
                        }
                    }
                }
            }
        }
        if counter > 0 {
            return true
        }
        else {
            return false
        }
    }
    
    private func getStrokeColor() -> Color {
        switch getSpotState() {
            case .disabled : return ColorManager.darkGray
            case .enabled  : return ColorManager.secondaryOrange
            case .reserved : return ColorManager.secondaryOrange
            case .conflicted : return ColorManager.darkGray
        }
    }
    private func getAlertByState() -> Alert {
//        if !firestoreData.ticket.isTicketLeft(){
//            return showNoTicketAlert()
//        }
        switch self.spotState {
            case .disabled : return deleteReservationAleart()
            case .enabled  : return showReservationAleart()
            case .reserved : return deleteReservationAleart()
            case .conflicted : return showConflictedAleart()
        }
    }
    
    private func getSpotColorByState() -> Color {
        switch getSpotState() {
            case .disabled : return ColorManager.darkGray
            case .enabled  : return ColorManager.lightGray
            case .reserved : return ColorManager.secondaryOrange
            case .conflicted : return ColorManager.darkGray
        }
    }
    
    private func showNoTicketAlert() -> Alert{
        return Alert(
            title: Text("予約チケットが残っていません"),
            message: Text("予約にはチケットが必要です。スタッフにご連絡ください。"),
            dismissButton:
                .default(
                    Text("OK")
                ))
    }
    
    private func showErrorAlert() -> Alert {
        return Alert(
            title: Text("不明なエラーが発生しました"),
            dismissButton:
                .default(
                    Text("OK")
                ))
    }
    
    private func showReservationAleart() -> Alert {
        switch alertType {
            case .confirm :
                
                let ticketBefore = firestoreData.ticket.getTicketNum()
                let ticketAfter = ticketBefore - 1
                let ticketMessage = String(ticketBefore) + " → " + String(ticketAfter)
                let dateMessage = getFormatedDate(from: self.date)
                let timeMessage = startTimeLabel + " - " + endTimeLabel
                let instructorName = firestoreData.staff.getStaff(byStaffId: viewRouter.selectedStaffId)?.name ?? ""
                
                if ticketBefore < 1{
                    return showNoTicketAlert()
                }
                else{
                    return Alert(
                        title: Text("トレーニングを予約しますか？"),
                        message: Text(reserveMessageBuilder(date: dateMessage, time: timeMessage, instructor: instructorName, ticket:ticketMessage)),
                        primaryButton: .cancel(Text("キャンセル")),
                        secondaryButton:
                            .default (
                                Text("OK"),
                                action: {
                                    checkSimutaneousReservation()
                                }
                            )
                        )
                }
                
            case .complete :
                return Alert(
                    title: Text("トレーニングを予約しました"),
                    message:nil,
                    dismissButton:.default(Text("OK"),action: {
                        self.alertType = .confirm
                        self.spotState = .reserved
                    })
                )
        case .failed :
            return Alert(
                title: Text("予約に失敗しました"),
                message: Text("通信環境をお確かめの上、時間を置いて再度実施してください"),
                dismissButton:.default(Text("OK"),action: {self.alertType = .confirm})
            )
        }
    }
    
    private func deleteReservationAleart() -> Alert {
        switch alertType {
            case .confirm :
                return Alert(
                    title: Text("予約を取消しますか？"),
                    message: nil,
                    primaryButton: .cancel(Text("キャンセル")),
                    secondaryButton:
                        .destructive (
                            Text("OK"),
                            action: {
                                deleteReservationData(with: self.reservation!)
                            }
                        )
                    )
            case .complete :
                return Alert(
                    title: Text("予約を取消しました"),
                    message:nil,
                    dismissButton:.default(Text("OK"),action: {
                        self.alertType = .confirm
                        self.spotState = .enabled
                    })
                )
        case .failed :
            return Alert(
                title: Text("予約の取消に失敗しました"),
                message: Text("通信環境をお確かめの上、時間を置いて再度実施してください"),
                dismissButton:.default(Text("OK"),action: {self.alertType = .confirm})
            )
        }
    }
    private func showConflictedAleart() -> Alert {
        return Alert(
            title: Text("トレーニングの予約に失敗しました"),
            message: Text("このトレーニングは他のお客様に予約されました"),
            dismissButton:.default(Text("OK"),action: {self.alertType = .confirm})
        )
    }
    
    private func makeReserVation(){
        if nil == self.reservation {
            self.reservation = Reservation()
            self.reservation!.shiftId = self.shift!.id
            self.reservation!.customerId = viewRouter.loginCustomerId
            
            print("saving reservation : \(self.reservation!)")
//            ReservationDao.save(reserv:self.reservation!)
            saveReservationData(with: self.reservation!)
        }
        else { // すでに
//            ReservationDao.update(reserv:self.reservation!)
            saveReservationData(with: self.reservation!)
        }
    }
    
    private func checkSimutaneousReservation(){
        gcp.show(message: "Loading...", style: ProgressCircleStyle())
        if nil != self.shift{
            let db = Firestore.firestore()
            let settings = FirestoreSettings()
            settings.isPersistenceEnabled = false
            db.settings = settings
            
            db.collection("50_RESERVATION")
                .whereField("10_SHIFT_ID", isEqualTo: self.shift!.id)
                .whereField("99_DELETE_FLG",isEqualTo: 0)
                .getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        gcp.dismiss()
                        self.alertType = .failed
                        self.spotState = .disabled
                        print(err)
                    } else {
                        print("reserving :  \(self.shift!.id)")
                        if (querySnapshot!.documents.count > 0){
                            gcp.dismiss()
                            self.alertType = .failed
                            self.spotState = .conflicted
                            self.reservationAlert.toggle()
                            print("競合が発生したため、書き込みを終了")
                        }
                        else{
                            makeReserVation()
                        }
                    }
            }
        }
        else{
            self.spotState = .disabled
            self.alertType = .failed
            self.reservationAlert.toggle()
        }
    }
    
    private func saveReservationData(with:Reservation){
        let db = Firestore.firestore()
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = false
        db.settings = settings
        
        let batch = db.batch()
        
        
        let rsrv = db.collection("50_RESERVATION").document(with.id)
        batch.setData([
            "10_SHIFT_ID"    : with.shiftId,
            "20_CUSTOMER_ID" : with.customerId,
            "30_START_TIME"  : with.startTime,
            "70_CREATE_DATE" : Timestamp(date:with.createDate),
            "80_UPDATE_DATE" : Timestamp(date:with.updateDate),
            "99_DELETE_FLG"  : with.deleteFlg
        ],forDocument: rsrv)
        
        let tickt = db.collection("60_CUSTOMER_TICKET").document(viewRouter.loginCustomerId)
        batch.setData([
            "10_NUM_LEFT"    :firestoreData.ticket.entity.ticketLeft-1,
            "70_CREATE_DATE" :firestoreData.ticket.entity.createDate,
            "80_UPDATE_DATE" :Timestamp(date:Date()),
            "99_DELETE_FLG"  :firestoreData.ticket.entity.deleteFlg
        ],forDocument: tickt)
        
        batch.commit(){ err in
            if let err = err {
                gcp.dismiss()
                print("Error writing reservation :  \(err)")
                self.alertType = .failed
                self.reservationAlert.toggle()
            }
            else{
                gcp.dismiss()
                let newData = Reservation()
        
                newData.id         = with.id
                newData.shiftId    = with.shiftId
                newData.customerId = with.customerId
                newData.startTime  = with.startTime
                newData.updateDate = with.updateDate
                newData.createDate = with.createDate
                newData.deleteFlg  = with.deleteFlg
                firestoreData.reservation.entities.append(newData);
                firestoreData.ticket.entity.ticketLeft = firestoreData.ticket.entity.ticketLeft - 1
                self.alertType = .complete
                self.spotState = .enabled
                self.reservationAlert.toggle()
            }
        }
    }
    
    private func deleteReservationData(with:Reservation){
        gcp.show(message: "Loading...", style: ProgressCircleStyle())
        let db = Firestore.firestore()
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = false
        db.settings = settings
        
        let batch = db.batch()
        
        
        let rsrv = db.collection("50_RESERVATION").document(with.id)
        batch.setData([
            "10_SHIFT_ID"    : with.shiftId,
            "20_CUSTOMER_ID" : with.customerId,
            "30_START_TIME"  : with.startTime,
            "70_CREATE_DATE" : Timestamp(date:with.createDate),
            "80_UPDATE_DATE" : Timestamp(date:Date()),
            "99_DELETE_FLG"  : 1
        ],forDocument: rsrv)
        
        let tickt = db.collection("60_CUSTOMER_TICKET").document(viewRouter.loginCustomerId)
        batch.setData([
            "10_NUM_LEFT"    :firestoreData.ticket.entity.ticketLeft+1,
            "70_CREATE_DATE" :firestoreData.ticket.entity.createDate,
            "80_UPDATE_DATE" :Timestamp(date:Date()),
            "99_DELETE_FLG"  :firestoreData.ticket.entity.deleteFlg
        ],forDocument: tickt)
        
        batch.commit(){ err in
            if let err = err {
                print("Error writing reservation :  \(err)")
                gcp.dismiss()
                self.spotState = .reserved
                self.alertType = .failed
                self.reservationAlert.toggle()
            }
            else{
                gcp.dismiss()
                let newData = Reservation()
        
                newData.id         = with.id
                newData.shiftId    = with.shiftId
                newData.customerId = with.customerId
                newData.startTime  = with.startTime
                newData.updateDate = with.updateDate
                newData.createDate = with.createDate
                newData.deleteFlg  = with.deleteFlg
                
                firestoreData.ticket.entity.ticketLeft = firestoreData.ticket.entity.ticketLeft + 1
                self.spotState = .reserved
                self.alertType = .complete
                self.reservationAlert.toggle()
                
                for i in 0..<firestoreData.reservation.entities.count{
                    if with.id == firestoreData.reservation.entities[i].id{
                        firestoreData.reservation.entities.remove(at: i)
                        break
                    }
                }
                
                self.reservation = nil
            }
        }
    }
    
    private func reserveMessageBuilder(date:String,time:String,instructor:String,ticket:String) -> String {
        var str = ""
        
        let date_str = "Date  :  " + date + "\n"
        let time_str = "Time  :  " + time + "\n"
        let inst_str = "Instructor  :  " + instructor + "\n"
        let ticket_str = "Your Ticket : " + ticket + "\n"
        
        str = date_str + time_str + inst_str + ticket_str
        return str
    }
}
