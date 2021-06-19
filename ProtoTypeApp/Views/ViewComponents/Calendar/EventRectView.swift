//
//  EventRectView.swift
//  ProtoTypeApp
//
//  Created by 高木一弘 on 2021/06/11.
//

import SwiftUI

struct EventRectView: View {
    
    @State var reservationAlert = false
    
    @State var shift : StaffShift?
    @State var reservation : Reservation?
    @State var customer:Customer?
    
    var date : Date
    var startTime : Date
    var seq : Int
    
    @EnvironmentObject var viewRouter: ViewRouter
    
    @State private var alertType : AlertType = .confirm
    enum AlertType {
        case confirm
        case complete
        case failed
    }
    
    @State private var spotState : SpotState = .disabled
    enum SpotState {
        case initial
        case disabled
        case enabled
        case occupied
        case reserved
    }
    
    init(date:Date,startTime:Date,seq:Int){
        self._shift = State(initialValue: StaffShiftDao.get(date: date, startTime: startTime, seq: seq))
        self.date  = date
        self.startTime = startTime
        self.seq = seq
    }
    
    var body: some View {        
        VStack {
            Spacer()
            
            if getSpotState() == .reserved {
                Text(StaffShiftDao.getStaffName(date: date, startTime: startTime, seq: seq) ?? "エラー")
                    .font(.caption)
                Text(ReservationDao.getCustomerName(by: self.shift!.id) ?? "エラー" + " 様")
                    .font(.caption)
            }
            else if getSpotState() == .enabled {
                Text(StaffShiftDao.getStaffName(date: date, startTime: startTime, seq: seq) ?? "エラー")
                    .font(.caption)
                Text("予約なし")
                    .font(.caption)
            }
            else{
                if getSpotState() == .occupied{
                    Text(StaffShiftDao.getStaffName(date: date, startTime: startTime, seq: seq) ?? "エラー")
                        .font(.caption)
                    Text("予約なし")
                        .font(.caption)
                }
                else if getSpotState() == .initial{
                    Text("シフト未提出")
                        .font(.caption)
                }
                else {
                    Text("シフト未提出")
                        .font(.caption)
                }
            }
            
            
            
//            if !isShiftValid() {
//                Text("シフト未提出")
//                    .font(.caption)
//            }
//            else if !isReserved() {
//                Text(StaffShiftDao.getStaffName(date: date, startTime: startTime, seq: seq) ?? "エラー")
//                    .font(.caption)
//                Text("予約なし")
//                    .font(.caption)
//            }
//            else {
//                Text(StaffShiftDao.getStaffName(date: date, startTime: startTime, seq: seq) ?? "エラー")
//                    .font(.caption)
//                Text(ReservationDao.getCustomerName(by: self.shift!.id) ?? "エラー" + " 様")
//                    .font(.caption)
//            }
            Spacer()
        }
        .frame(width: CGFloat(event_rect_width), height: CGFloat(event_rect_height))
        .background(getSpotColorByState())
        .shadow(color: .gray, radius: 3, x: 2, y: 2)
        .onTapGesture {
            if getSpotState() == .initial || getSpotState() == .enabled {
                reservationAlert.toggle()
            }
        }
        .alert(isPresented:$reservationAlert){
            getAlertByState()
        }
        .onAppear{
            self.shift = StaffShiftDao.get(date: date, startTime: startTime, seq: seq)
//            handleSpotState()
        }
    }
    
    
    
//    private func isShiftValid() -> Bool {
//        if let shift = StaffShiftDao.get(date: date, startTime: startTime, seq: seq){
//            if(!shift.staffId.isEmpty){ // シフトのデータが有効（スタッフIDが入力ずみ）
//                return true
//            }
//            else{ // シフトのデータが無効(シフトデータは存在するのに、スタッフIDが空)
//                return false
//            }
//        }
//        else{ // シフト未作成
////            spotState = .disabled
//            return false
//        }
//    }
    
    private func getSpotState() -> SpotState{
        
        if isLessonPassed(startTime: self.startTime){
            return .disabled
        }
        
        // シフトと予約を取得
        let shift = StaffShiftDao.get(date: date, startTime: startTime, seq: seq)
        
        if nil != shift { // シフト提出ずみ
            if isReserved(shift: shift!){
                return .reserved
            }
            
            if isMyShift(shift: shift!){
                return .enabled
            }
            else {
                return .occupied
            }
        }
        else {
            if isBookedAnotherSpot(){
                return .disabled
            }
            else {
                return .initial
            }
        }
        
    }
    
    private func isReserved(shift:StaffShift) -> Bool {
        let reservation = ReservationDao.get(by: shift.id)
        if nil != reservation {
            return true
        }
        else {
            return false
        }
    }
    
    private func isMyShift(shift:StaffShift) ->Bool{
        if viewRouter.loginStaffId == shift.staffId {
            return true
        }
        else {
            return false
        }
    }
    private func isBookedAnotherSpot() -> Bool {
        let count = StaffShiftDao.get(staffId: viewRouter.loginStaffId, date: date, startTime: startTime).count
        if count > 0{
            return true
        }
        else {
            return false
        }
    }
    
    private func isReserved() -> Bool {
        if let shift = StaffShiftDao.get(date: date, startTime: startTime, seq: seq){
            let reservation = ReservationDao.get(by: shift.id)
            
            if nil != reservation {
                return true
            }
            else {
                return false
            }
        }
        else {
            return false
        }
    }
    
    private func getAlertByState() -> Alert{
        switch getSpotState(){
            case .initial  : return showCreateShiftAlert()
            case .disabled : return showErrorAlert()
            case .enabled  : return showDeleteShiftAlert()
            case .occupied : return showErrorAlert()
            case .reserved : return showErrorAlert()
        }
        
//        if !isShiftValid(){ // シフト未提出
//            return showCreateShiftAlert()
//        }
//        else if !isReserved(){ // 予約なし
//            return showDeleteShiftAlert()
//        }
//        else{ // 予約あり
//            return showErrorAlert()
//        }
//
    }
    
    private func getSpotColorByState() -> Color{
        
        switch getSpotState(){
            case .initial  : return ColorManager.darkGray
            case .disabled : return ColorManager.darkGray
            case .enabled  : return Color.white
            case .occupied : return Color.white
            case .reserved : return ColorManager.secondaryOrange
        }
        
        
//        if !isShiftValid(){// シフト未提出
//            return ColorManager.darkGray
//        }
//        else if !isReserved(){// 予約なし
//            return Color.white
//        }
//        else{// 予約あり
//            return ColorManager.secondaryOrange
//        }
    }
    
    private func showErrorAlert() -> Alert {
        return Alert(
            title: Text("シフト取り下げ不可"),
            message: Text("予約済みの枠はシフト取消できません。お客様にご連絡のうえ、予約取消後にシフト取り下げをしてください"),
            dismissButton:
                .default(
                    Text("OK")
                ))
    }
    
    private func showDeleteShiftAlert() -> Alert {
        switch alertType {
            case .confirm :
                return Alert(
                    title: Text("シフトを取り下げますか？"),
                    message: nil,
                    primaryButton: .cancel(Text("キャンセル")),
                    secondaryButton:
                        .destructive (
                            Text("OK"),
                            action: {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
                                    self.alertType = .complete
                                    self.reservationAlert.toggle()
//                                    self.deleteShiftAlert.toggle()
                                    
                                }
                            }
                        )
                    )
            case .complete :
                return Alert(
                    title: Text("シフトを取り下げました"),
                    message:nil,
                    dismissButton:.default(Text("OK"),action: {
                        self.alertType = .confirm
                        spotState = .initial
                        // TODO シフトを削除するロジックをここに記載
                        StaffShiftDao.delete(shift: self.shift!)
                        self.shift = nil
                    })
                )
        case .failed :
            return Alert(
                title: Text("シフトの取り下げに失敗しました"),
                message: Text("通信環境をお確かめの上、時間を置いて再度実施してください"),
                dismissButton:.default(Text("OK"),action: {self.alertType = .confirm})
            )
        }
    }
    
    private func assignShift(){
        if nil == self.shift{
            self.shift = StaffShift()
            self.shift!.staffId = viewRouter.loginStaffId
            self.shift!.startDate = date
            self.shift!.endDate = date
            self.shift!.startTime = startTime
            self.shift!.seq = seq
            StaffShiftDao.save(with: self.shift!)
        }
        else {
            let newShift = StaffShift()
            newShift.staffId = viewRouter.loginStaffId
            newShift.startDate = date
            newShift.endDate = date
            newShift.startTime = startTime
            newShift.seq = seq
            StaffShiftDao.update(on: self.shift!, by: newShift)
        }
    }
    
    private func showCreateShiftAlert() -> Alert {
        switch alertType {
            case .confirm :
                return Alert(
                    title: Text("シフトを提出しますか？"),
                    message: nil,
                    primaryButton: .cancel(Text("キャンセル")),
                    secondaryButton:
                        .default (
                            Text("OK"),
                            action: {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
                                    self.alertType = .complete
                                    self.reservationAlert.toggle()
//                                    self.createShiftAlert.toggle()
                                    
                                }
                            }
                        )
                    )
            case .complete :
                return Alert(
                    title: Text("シフトを提出しました"),
                    message:nil,
                    dismissButton:.default(Text("OK"),action: {
                        self.alertType = .confirm
                        spotState = .enabled
                        // TODO シフトを保存するロジックをここに記載
                        
                        assignShift()
                    })
                )
        case .failed :
            return Alert(
                title: Text("シフトの作成に失敗しました"),
                message: Text("通信環境をお確かめの上、時間を置いて再度実施してください"),
                dismissButton:.default(Text("OK"),action: {self.alertType = .confirm})
            )
        }
    }
}

struct EventRectView_Previews: PreviewProvider {
    static var previews: some View {
        EventRectView(date: Date(), startTime: Date(), seq: 0).environmentObject(ViewRouter())
    }
}
