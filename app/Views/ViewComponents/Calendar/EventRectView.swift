//
//  EventRectView.swift
//  ProtoTypeApp
//
//  Created by 高木一弘 on 2021/06/11.
//

import SwiftUI
import FirebaseFirestore
import GradientCircularProgress

struct EventRectView: View {
    
    @State var reservationAlert = false
    
    @State var shift : StaffShift?
    @State var reservation : Reservation?
//    @State var customer:Customer?
    
    var date : Date
    var startTime : Date
    var seq : Int
    
    @EnvironmentObject var viewRouter: ViewRouter
    @EnvironmentObject var firestoreData : FirestoreDataRepository
    var gcp = GradientCircularProgress()
    
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
    
    
    
    var body: some View {        
        VStack {
            Spacer()
            
            if getSpotState() == .reserved {
                Text(getStaffName(date: date, startTime: startTime, seq: seq) ?? "")
                    .font(.caption)
//                Text(ReservationDao.getCustomerName(by: self.shift!.id) ?? "エラー" + " 様")
//                    .font(.caption)
                if nil != self.reservation{
                    Text(firestoreData.customer.getName(byCustomerId: self.reservation!.customerId) ?? "エラー" + " 様")
                        .font(.caption)
                }
            }
            else if getSpotState() == .enabled {
                Text(getStaffName(date: date, startTime: startTime, seq: seq) ?? "")
                    .font(.caption)
                Text("予約なし")
                    .font(.caption)
            }
            else{
                if getSpotState() == .occupied{
                    Text(getStaffName(date: date, startTime: startTime, seq: seq) ?? "")
                        .font(.caption)
                    Text("予約なし")
                        .font(.caption)
                }
                else if getSpotState() == .initial{
                    Text("シフト未提出")
                        .font(.caption)
                }
                else {
                    Text("")
                        .font(.caption)
                }
            }
            
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
//            self.shift = StaffShiftDao.get(date: date, startTime: startTime, seq: seq)
            self.shift = firestoreData.staffShift.getData(date: date, startTime: startTime, seq: seq)
            if nil != self.shift {
            self.reservation = firestoreData.reservation.get(byShiftId: self.shift!.id)
            }
            self.spotState = .initial
            self.spotState = getSpotState()
        }
    }
    
    private func getSpotState() -> SpotState {
//        print(self.date)
        if isLessonPassed(startTime: self.startTime){
            return .disabled
        }
        
        // シフトと予約を取得
//        let shift = StaffShiftDao.get(date: date, startTime: startTime, seq: seq)
        let shiftfromFirestore = firestoreData.staffShift.getData(date: date, startTime: startTime, seq: seq)
//        print(shiftfromFirestore ?? "no shift found")
        
        if nil != shiftfromFirestore { // シフト提出ずみ
            if isReserved(shift: shiftfromFirestore!){
                return .reserved
            }
            
            if isMyShift(shift: shiftfromFirestore!){
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
    
    private func getStaffName(date: Date, startTime: Date, seq: Int) -> String? {
        if let shift = firestoreData.staffShift.getData(date: date, startTime: startTime, seq: seq){
            if let staff = firestoreData.staff.getStaff(byStaffId: shift.staffId){
                return staff.name
            }
        }
        return nil
    }
    
    private func isReserved() -> Bool {
        if let shift = firestoreData.staffShift.getData(date: date, startTime: startTime, seq: seq){
            if isReserved(shift: shift){
                return true
            }
            else{
                return false
            }
        }
        else {
            return false
        }
    }
    
    private func isReserved(shift:StaffShift) -> Bool {
        if nil != firestoreData.reservation.get(byShiftId: shift.id) {
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
//        let count = StaffShiftDao.get(staffId: viewRouter.loginStaffId, date: date, startTime: startTime).count
        let count = firestoreData.staffShift.count(staffId: viewRouter.loginStaffId, date: date, startTime: startTime)
        if count > 0{
            return true
        }
        else {
            return false
        }
    }
    
    private func getAlertByState() -> Alert{
        switch self.spotState {
            case .initial  : return showCreateShiftAlert()
            case .disabled : return showErrorAlert()
            case .enabled  : return showDeleteShiftAlert()
            case .occupied : return showOccupiedAlert()
            case .reserved :
                if let shift = firestoreData.staffShift.getData(date: date, startTime: startTime, seq: seq){
                    if isReserved(shift: shift){
                        return showErrorAlert()
                    }
                    else{
                        return showDeleteShiftAlert()
                        
                    }
                }
                else{
                    return showErrorAlert()
                }
        }
    }
    
    private func getSpotColorByState() -> Color{
        switch getSpotState() {
            case .initial  : return ColorManager.darkGray
            case .disabled : return ColorManager.darkGray
            case .enabled  : return Color.white
            case .occupied : return Color.white
            case .reserved : return ColorManager.secondaryOrange
        }
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
    private func showOccupiedAlert() -> Alert {
        return Alert(
            title: Text("シフト変更不可"),
            message: Text("他のインストラクターのシフトは変更できません"),
            dismissButton:
                .default(
                    Text("OK")
                ))
    }
    
    func saveData(with:StaffShift){
        gcp.show(message: "Loading...", style: ProgressCircleStyle())
        let db = Firestore.firestore()
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = false
        db.settings = settings
        let docRef = db.collection("40_STAFF_SHIFT").document(with.id)
        
        let newData = StaffShift()
        newData.staffId    = with.staffId
        newData.startDate  = with.startDate
        newData.endDate    = with.endDate
        newData.startTime  = with.startTime
        newData.seq        = with.seq
        newData.createDate = with.createDate
        newData.updateDate = with.updateDate
        newData.deleteFlg  = with.deleteFlg
        
        docRef.setData([
            "10_STAFF_ID"   : with.staffId,
            "20_START_DATE" : Timestamp(date:with.startDate),
            "30_END_DATE"   : Timestamp(date:with.endDate),
            "40_START_TIME" : Timestamp(date:with.startTime),
            "50_SEQ"        : with.seq,
            "70_CREATE_DATE": Timestamp(date:with.createDate),
            "80_UPDATE_DATE": Timestamp(date:with.updateDate),
            "99_DELETE_FLG" : with.deleteFlg
        ],merge: true){ error in
            if let error = error {
                gcp.dismiss()
                print("Error writing staff shift : \(error)")
                self.spotState = .initial
                self.alertType = .failed
                self.reservationAlert.toggle()
            }
            else{
                gcp.dismiss()
                firestoreData.staffShift.entities.append(newData);
                self.spotState = .initial
                self.alertType = .complete
                self.reservationAlert.toggle()
            }
        }
    }
    
    func delete(with:StaffShift){
        gcp.show(message: "Loading...", style: ProgressCircleStyle())
        let db = Firestore.firestore()
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = false
        db.settings = settings
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
                gcp.dismiss()
                print("Error writing staff shift : \(error)")
                self.spotState = .enabled
                self.alertType = .failed
                self.reservationAlert.toggle()
            }
            else{
                gcp.dismiss()
                self.spotState = .enabled
                self.alertType = .complete
                self.reservationAlert.toggle()
                
                for i in 0..<firestoreData.staffShift.entities.count{
                    if with.id == firestoreData.staffShift.entities[i].id{
                        firestoreData.staffShift.entities.remove(at: i)
                        break
                    }
                }
            }
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
//            StaffShiftDao.save(with: self.shift!)
            saveData(with: self.shift!)
        }
        else {
            let newShift = StaffShift()
            newShift.staffId = viewRouter.loginStaffId
            newShift.startDate = date
            newShift.endDate = date
            newShift.startTime = startTime
            newShift.seq = seq
//            StaffShiftDao.update(on: self.shift!, by: newShift)
            saveData(with: newShift)
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
                                assignShift()
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
                                if(nil != self.shift){
                                    delete(with: self.shift!)
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
}

struct EventRectView_Previews: PreviewProvider {
    static var previews: some View {
        EventRectView(date: Date(), startTime: Date(), seq: 0).environmentObject(ViewRouter())
    }
}
