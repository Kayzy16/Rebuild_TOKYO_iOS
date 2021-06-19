//
//  EventFrameView.swift
//  ProtoTypeApp
//
//  Created by 高木一弘 on 2021/06/11.
//

import SwiftUI

struct EventFrameView: View {
    
    @EnvironmentObject var viewRouter: ViewRouter
    
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
                .foregroundColor(getSpotColorByState())
                .onTapGesture {
                    if getSpotState() != .disabled {
                        reservationAlert.toggle()
                    }
                }
                .background(getSpotColorByState())
                .frame(width: CGFloat(event_frame_width), height: CGFloat(event_frame_height))
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
                self.shift = StaffShiftDao.get(staffId: viewRouter.selectedStaffId, date: self.date, startTime: self.startTime)
                if(nil != self.shift){
                    self.reservation = ReservationDao.get(by: self.shift!.id)
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
                        Spacer()
                    }
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
        if viewRouter.loginCustomerId == ReservationDao.get(by: reservation.shiftId)?.customerId{
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
        
        if let shift = StaffShiftDao.get(staffId: viewRouter.selectedStaffId, date: self.date, startTime: self.startTime){
            if isShiftValid(shift: shift){
                
                if isBookedAnotherSpot(checking: shift){
                    return .disabled
                }
                
                if let reservation = ReservationDao.get(by: shift.id){
                    if isReserved(reserVation: reservation){
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
        let shifts = StaffShiftDao.get(date: self.date, startTime: self.startTime)
        var counter = 0
        
        shifts.forEach(){(shift :StaffShift) in
            if checking.id != shift.id{
                if let reserve = ReservationDao.get(by: shift.id){
                    if isMyReserve(reservation: reserve){
                        counter = counter + 1
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
    
    private func getAlertByState() -> Alert {
        if !CustomerTicketDao.isTicketLeft(){
            return showNoTicketAlert()
        }
        switch getSpotState() {
            case .disabled : return deleteReservationAleart()
            case .enabled  : return showReservationAleart()
            case .reserved : return deleteReservationAleart()
        }
//        if isShiftValid(){ // シフト提出ずみ
//            if isReserved(){ // 予約済み
//                return deleteReservationAleart()
//            }
//            else{ // 未予約
//                return showReservationAleart()
//            }
//        }
//        else{ // シフト未提出
//            return showErrorAlert()
//        }
    }
    
    private func getSpotColorByState() -> Color {
        switch getSpotState() {
            case .disabled : return ColorManager.darkGray
            case .enabled  : return ColorManager.lightGray
            case .reserved : return ColorManager.secondaryOrange
        }
//        if isShiftValid(){ // シフト提出ずみ
//            if isReserved(){ // 予約済み
//                return ColorManager.secondaryOrange
//            }
//            else{ // 未予約
//                return ColorManager.lightGray
//            }
//        }
//        else{ // シフト未提出
//            return ColorManager.darkGray
//        }
    }
    
    private func showNoTicketAlert() -> Alert{
        return Alert(
            title: Text("チケットが残っていません"),
            message: Text("今月のご利用上限に達しました"),
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
        
        let ticketBefore = CustomerTicketDao.getTicketNum()
        let ticketAfter = ticketBefore - 1
        let ticketMessage = String(ticketBefore) + " → " + String(ticketAfter)
        let dateMessage = getFormatedDate(from: self.date)
        let timeMessage = startTimeLabel + " - " + endTimeLabel
        let instructorName = StaffDao.get(by: viewRouter.selectedStaffId)?.name ?? ""
        
        switch alertType {
            case .confirm :
                return Alert(
                    title: Text("レッスンを予約しますか？"),
                    message: Text(reserveMessageBuilder(date: dateMessage, time: timeMessage, instructor: instructorName, ticket:ticketMessage)),
                    primaryButton: .cancel(Text("キャンセル")),
                    secondaryButton:
                        .default (
                            Text("OK"),
                            action: {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
                                    self.alertType = .complete
                                    self.reservationAlert.toggle()
                                    // TODO シフトを保存するロジックをここに記載
                                    
                                }
                            }
                        )
                    )
            case .complete :
                return Alert(
                    title: Text("レッスンを予約しました"),
                    message:nil,
                    dismissButton:.default(Text("OK"),action: {
                        self.alertType = .confirm
                        self.spotState = .reserved
                        
                        makeReserVation()
                        CustomerTicketDao.consume()
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
    
    private func makeReserVation(){
        if nil == self.reservation {
            self.reservation = Reservation()
            self.reservation!.shiftId = self.shift!.id
            self.reservation!.customerId = viewRouter.loginCustomerId
            
            ReservationDao.save(reserv:self.reservation!)
        }
        else { // すでに
            ReservationDao.update(reserv:self.reservation!)
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
    
    
    private func deleteReservationAleart() -> Alert {
        switch alertType {
            case .confirm :
                return Alert(
                    title: Text("レッスンを取消しますか？"),
                    message: nil,
                    primaryButton: .cancel(Text("キャンセル")),
                    secondaryButton:
                        .destructive (
                            Text("OK"),
                            action: {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
                                    self.alertType = .complete
                                    self.reservationAlert.toggle()
                                    
                                }
                            }
                        )
                    )
            case .complete :
                return Alert(
                    title: Text("レッスンを取消しました"),
                    message:nil,
                    dismissButton:.default(Text("OK"),action: {
                        self.alertType = .confirm
                        self.spotState = .enabled
                        
                        ReservationDao.delete(reserve: self.reservation!)
                        self.reservation = nil
                        CustomerTicketDao.restore()
                    })
                )
        case .failed :
            return Alert(
                title: Text("レッスンの取消に失敗しました"),
                message: Text("通信環境をお確かめの上、時間を置いて再度実施してください"),
                dismissButton:.default(Text("OK"),action: {self.alertType = .confirm})
            )
        }
    }
}
