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
    
    @Binding var date : Date
    @Binding var startTime : Date
    @Binding var seq : Int
    
    @EnvironmentObject var viewRouter: ViewRouter
    @EnvironmentObject var firestoreData : FirestoreDataRepository
    var gcp = GradientCircularProgress()
    
    @State private var alertType : AlertType = .confirm
    enum AlertType {
        case confirm
        case complete
        case failed
    }
    
    @State private var spotState : SpotState = .initial
    enum SpotState {
        case initial
        case disabled
        case enabled
        case occupied
        case reserved
        case passed
    }
    
    var body: some View {        
        VStack {
            Spacer()
            
            if getSpotState() == .reserved {
                Text(getStaffName(date: date, startTime: startTime, seq: seq) ?? "")
                    .font(.caption)
                    .foregroundColor(Color(.black))
                Text(getCustomerName()  + " 様")
                    .font(.caption)
                    .foregroundColor(Color(.black))
            }
            if getSpotState() == .enabled {
                Text(getStaffName(date: date, startTime: startTime, seq: seq) ?? "")
                    .font(.caption)
                    .foregroundColor(Color(.black))
                Text("予約なし")
                    .font(.caption)
                    .foregroundColor(Color(.black))
            }
            if getSpotState() == .occupied{
                Text(getStaffName(date: date, startTime: startTime, seq: seq) ?? "")
                    .font(.caption)
                    .foregroundColor(Color(.black))
                Text("予約なし")
                    .font(.caption)
                    .foregroundColor(Color(.black))
            }
            if getSpotState() == .initial{
                Text("シフト未提出")
                    .font(.caption)
                    .foregroundColor(Color(.black))
            }
            if getSpotState() == .disabled{
                Text("")
                    .font(.caption)
            }
            if getSpotState() == .passed{
                Text("")
                    .font(.caption)
            }
            
            Spacer()
        }
        .frame(width: CGFloat(event_rect_width), height: CGFloat(event_rect_height))
        .background(getSpotColorByState())
        .shadow(color: .gray, radius: 3, x: 2, y: 2)
        .onTapGesture {
            print("date : \(date)")
            print("startTime : \(startTime)")
            self.shift = firestoreData.staffShift.getData(date: date, startTime: startTime, seq: seq)
            if getSpotState() == .initial || getSpotState() == .enabled || getSpotState() == .occupied{
                reservationAlert.toggle()
            }
        }
        .alert(isPresented:$reservationAlert){
            getAlertByState()
        }
        .onAppear{
            self.shift = nil
            self.shift = firestoreData.staffShift.getData(date: date, startTime: startTime, seq: seq)
            if nil != self.shift {
                self.reservation = firestoreData.reservation.get(byShiftId: self.shift!.id)
            }
//            self.spotState = .initial
            self.spotState = getSpotState()
        }
    }
    
    private func getCustomerName() -> String {
        if getSpotState() == .reserved{
            let shift = firestoreData.staffShift.getData(date: date, startTime: startTime, seq: seq)
            if nil != shift {
                let reservation = firestoreData.reservation.get(byShiftId: shift!.id)
                let name = firestoreData.customer.getName(byCustomerId: reservation!.customerId) ?? ""
                
                return name
            }
        }
        else {
            return ""
        }
        return ""
    }
    
    private func getSpotState() -> SpotState {
        if isLessonPassed(startTime: self.startTime){
            return .passed
        }
        
//        if isNotAssignable(){
//            return .disabled
//        }
        
        
        // シフトと予約を取得
        let shiftfromFirestore = firestoreData.staffShift.getData(date: date, startTime: startTime, seq: seq)
        
        // デバッグ用
//        print("date : \(date)")
//        print("startTime : \(startTime)")
//        print("seq : \(seq)")
//        print("shiftfromFirestore : \(shiftfromFirestore)")
        // デバッグ用
//        let year = getYearInt(from: shiftfromFirestore?.startTime ?? Date())
//        let month = getMonthInt(from: shiftfromFirestore?.startTime ?? Date())
//        let day = getDayInt(from: shiftfromFirestore?.startTime ?? Date())
//
//        if(year == 2021){
//            if(month == 11){
//                if(day == 25){
//
//                    print(shiftfromFirestore)
//
//                }
//            }
//        }
        
        
        
        // シフトデータあり
        if nil != shiftfromFirestore {
            
            
            
            // 顧客による予約データあり
            if isReserved(shift: shiftfromFirestore!){
                return .reserved
            }
            
            // 自分のシフト
            if isMyShift(shift: shiftfromFirestore!){
                return .enabled
            }
            // 他人のシフト
            else {
                return .occupied
            }
        }
        // シフトデータなし
        else {
            // 同時間帯の他スポットでシフト提出ずみ
            if isNotAssignable(){
                return .disabled
            }
            // シフト未提出
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
    
    private func isNotAssignable() -> Bool {
        let before = firestoreData.staffShift.count(staffId: viewRouter.loginStaffId, date: date, startTime: addMin(to: startTime, by: -30))
        let after = firestoreData.staffShift.count(staffId: viewRouter.loginStaffId, date: date, startTime: addMin(to: startTime, by: 30))
        if (before + after) > 0{
            return true
        }
        else {
            return false
        }
    }
    
    private func getAlertByState() -> Alert{
        switch getSpotState() {
            case .passed   : return showErrorAlert()
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
            case .passed : return ColorManager.darkGray
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
            title: Text("他のトレーナがシフト提出済みです"),
            message: Text("他の時間を選択してください。"),
            dismissButton:
                .default(
                    Text("OK")
                ))
    }
    
    func checkSimutaneousAssign(with:StaffShift){
        gcp.show(message: "Loading...", style: ProgressCircleStyle())
        let db = Firestore.firestore()
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = false
        db.settings = settings

        db.collection("40_STAFF_SHIFT")
            .whereField("40_START_TIME",isGreaterThanOrEqualTo: Timestamp(date: getJSTDate(fromUTC: self.startTime)))
            .getDocuments{(querySnapshot, err) in
                if let err = err {
//                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        let data = document.data()
                        let startTimeByFS = (data["40_START_TIME"] as? Timestamp)!.dateValue()
//                        print(self.startTime)
                        if startTimeByFS == self.startTime{
                            // コンフリクトエラー
                            gcp.dismiss()
                            self.alertType = .confirm
                            self.reservationAlert.toggle()
                            break;
                        }
                    }
                    saveData(with: with)
                }
            }
    }
    
    func saveData(with:StaffShift){
//        gcp.show(message: "Loading...", style: ProgressCircleStyle())
        let db = Firestore.firestore()
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = false
        db.settings = settings
        let docRef = db.collection("40_STAFF_SHIFT").document(with.id)
        
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
//                print("Error writing staff shift : \(error)")
//                self.spotState = .initial
                self.alertType = .failed
                self.reservationAlert.toggle()
            }
            else{
                gcp.dismiss()
                let newData = StaffShift()
                newData.staffId    = with.staffId
                newData.startDate  = with.startDate
                newData.endDate    = with.endDate
                newData.startTime  = with.startTime
                newData.seq        = with.seq
                newData.createDate = with.createDate
                newData.updateDate = with.updateDate
                newData.deleteFlg  = with.deleteFlg
                
                firestoreData.staffShift.entities.append(newData);
//                self.spotState = .initial
                self.alertType = .complete
                self.reservationAlert.toggle()
            }
        }
    }
    
    func delete(with:StaffShift){
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
            "80_UPDATE_DATE": Timestamp(date:Date()),
            "99_DELETE_FLG" : 1
        ],merge: true){ error in
            if let error = error {
                gcp.dismiss()
                self.alertType = .failed
                self.reservationAlert.toggle()
            }
            else{
                for i in 0..<firestoreData.staffShift.entities.count{
                    if with.id == firestoreData.staffShift.entities[i].id{
                        firestoreData.staffShift.entities[i].deleteFlg = 1
                        break
                    }
                }
                self.shift = nil
                gcp.dismiss()
                self.alertType = .complete
                self.reservationAlert.toggle()
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
//            saveData(with: self.shift!)
            checkSimutaneousAssign(with: self.shift!)
        }
        
        // 修正中
        else {
            print(shift!)
            self.shift!.staffId = viewRouter.loginStaffId
            self.shift!.startDate = date
            self.shift!.endDate = date
            self.shift!.startTime = startTime
            self.shift!.seq = seq
//            StaffShiftDao.update(on: self.shift!, by: newShift)
//            saveData(with: newShift)
            checkSimutaneousAssign(with: self.shift!)
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
                    title: Text("シフトを取り下げました"),
                    message:nil,
                    dismissButton:.default(Text("OK"),action: {
                        self.alertType = .confirm
//                        spotState = .initial
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
                                else{
                                    self.shift = firestoreData.staffShift.getData(date: date, startTime: startTime, seq: seq)
                                    if(nil != self.shift){
                                        delete(with: self.shift!)
                                    }
                                    else{
                                        self.alertType = .failed
                                        self.reservationAlert.toggle()
                                    }
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

//struct EventRectView_Previews: PreviewProvider {
//    static var previews: some View {
//        EventRectView(date: Date(), startTime: Date(), seq: 0).environmentObject(ViewRouter())
//    }
//}
