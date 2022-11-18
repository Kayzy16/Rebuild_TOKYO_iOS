//
//  DayRectView.swift
//  ProtoTypeApp
//
//  Created by 高木一弘 on 2021/06/12.
//

import SwiftUI
import FirebaseFirestore
import GradientCircularProgress

struct DayRectView: View {
    
    @EnvironmentObject var viewRouter: ViewRouter
    @EnvironmentObject var firestoreData : FirestoreDataRepository
    
    @State private var showingActionSheet : Bool = false
    @State private var showinfAlert : Bool = false
    @State private var isShiftSecureFailed : Bool = false
    @State private var showingAlert : Bool = false
    
    enum AlertType {
        case initial
        case unexpectedError
        case shiftExist // 本人のシフトが存在
        case blocked    // 自分以外のシフトが存在
        case successed
    }
    @State private var alertType : AlertType = .initial
    
    var gcp = GradientCircularProgress()
    
    var year    : Int
    var month   : Int
    var day     : Int
    var weekDay : Int
    
    init(day:Date){
        self.year  = getYearInt(from: day)
        self.month = getMonthInt(from: day)
        self.day   = getDayInt(from: day)
        self.weekDay = getWeekDayInt(from: day)
    }
    
    var body: some View {
        HStack {
            Text(String(month) + "/" + String(day))
                .foregroundColor(.white)
            Text(getWeekDaylabel(weekDay: self.weekDay))
                .foregroundColor(.white)
        }
        .frame(width:day_rect_width,height: day_rect_height)
        .background(isToday() ? ColorManager.accentOrage : ColorManager.accentNavy)
        .onTapGesture(){
            if (viewRouter.loginUserType == .trainer) {
                showingActionSheet.toggle()
            }
        }
        .actionSheet(isPresented: $showingActionSheet) {
            /// ④アクションシートの定義
            ActionSheet(
                title: Text("シフトをまとめて入力"),
                message: nil,
                buttons:
                    [
                        .default(Text("00分開始枠を全て確保")) {
                            print(firestoreData.staffShift.entities)
                            secureWholeDayShift(startMin: 0)
                        },
                        .default(Text("30分開始枠を全て確保")) {
                            secureWholeDayShift(startMin: 30)
                        },
                        .cancel()
                    ]
            )
        }
        .alert(isPresented:$showinfAlert){
            showAlert()
        }
    }
    
    public func isToday() -> Bool {
        let today = Date()
        let calendar = Calendar(identifier: .gregorian)
        let thisYear = calendar.component(.year, from: today)
        
        let labeledDate = calendar.date(from: DateComponents(year: thisYear, month: self.month, day: self.day))!
        
        return calendar.isDateInToday(labeledDate)
    }
    
    private func getWeekDaylabel(weekDay : Int) -> String {
        switch weekDay {
        case WeekDay.sunday.rawValue : return "日"
        case WeekDay.monday.rawValue : return "月"
        case WeekDay.tuesday.rawValue : return "火"
        case WeekDay.wednesday.rawValue : return "水"
        case WeekDay.thursday.rawValue : return "木"
        case WeekDay.friday.rawValue : return "金"
        case WeekDay.saturday.rawValue : return "土"
        
        default:
            return "err"
        }
    }
    
    private func showAlert() -> Alert {
        var title : String = ""
        var msg   : String = ""
        
        switch(alertType){
        case .initial :
            title = "不明なエラーが発生"
            msg   = "不正な遷移が発生しました。開発者に連絡してください"
            break
        case .successed :
            title = "シフトをまとめて提出しました"
            break
        case .unexpectedError :
            title = "不明なエラーが発生しました"
            msg   = "ネットワーク状況をご確認のうえ、時間をおいて再度実施してください"
            break
        case .blocked :
            title = "シフトの提出に失敗しました"
            msg   = "他のトレーナーのシフトと重複するため、シフトをまとめて提出できません。\n当該日のシフトを取り消ししてもらい、その後に再度実施してください"
            break
        case .shiftExist :
            title = "シフトの提出に失敗しました"
            msg   = "ご自身のシフトが存在します。\n\n当該日の提出済みシフトを取り消し後、再度実施してください。"
            break
        }
        
        return Alert(
            title: Text(title),
            message: Text(msg),
            dismissButton:
                .default(
                    Text("OK"),
                    action:{alertType = .initial}
                ))
    }
    
    private func secureWholeDayShift(startMin:Int){
        //  プログレスサークルを表示
        gcp.show(message: "Loading...", style: ProgressCircleStyle())
        
        // firestoreの接続設定を指定
        let db = Firestore.firestore()
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = false
        db.settings = settings
        
        // 検索する日付を作成
        let day = getNormalizedDate(from: getDate(y: self.year, m: self.month, d: self.day))
        
        // 同一日のシフトを検索・読み込み
        db.collection("40_STAFF_SHIFT")
            .whereField("20_START_DATE",isEqualTo:Timestamp(date: day))
            .getDocuments{(querySnapshot, err) in
                if let err = err {
                    // 失敗ダイアログを出力
                    self.alertType = .unexpectedError
                    gcp.dismiss()
                    self.showinfAlert = true
                }
                else{
                    
                    var tempArray : [StaffShift] = []
                    let batch = db.batch()
                    var startTime : Date
                    
                    for i in 0..<maxLessonNum() {
                        
                        if(alertType == .shiftExist || alertType == .blocked){
                            break
                        }
                        
                        startTime = lessonStartTime(d: day, index: i)
                        startTime = addMin(to: startTime, by: startMin)
                        let shift = StaffShift()
                        shift.staffId   = viewRouter.loginStaffId
                        shift.startDate = getNormalizedDate(from: getDate(y: self.year, m: self.month, d: self.day))
                        shift.endDate   = getNormalizedDate(from: getDate(y: self.year, m: self.month, d: self.day))
                        shift.startTime = startTime
                        
                        let docRef = db .collection("40_STAFF_SHIFT").document(shift.id)
                        
                        if(querySnapshot!.documents.isEmpty){
                            tempArray.append(shift)
                            
                            batch.setData([
                                "10_STAFF_ID"   : shift.staffId,
                                "20_START_DATE" : Timestamp(date:shift.startDate),
                                "30_END_DATE"   : Timestamp(date:shift.endDate),
                                "40_START_TIME" : Timestamp(date:startTime),
                                "50_SEQ"        : shift.seq,
                                "70_CREATE_DATE": Timestamp(date:shift.createDate),
                                "80_UPDATE_DATE": Timestamp(date:shift.updateDate),
                                "99_DELETE_FLG" : shift.deleteFlg
                            ],forDocument: docRef)
                        }
                        else{
                            for document in querySnapshot!.documents {
                                let data = document.data()
                                let startTimeByFS = (data["40_START_TIME"] as? Timestamp)!.dateValue()
                                let staffId       = data["10_STAFF_ID"] as? String ?? ""
                                let deleteFlg     = data["99_DELETE_FLG"] as? Int ?? 0
                                
                                if(viewRouter.loginStaffId == staffId && deleteFlg == 0){
                                    alertType = .shiftExist
                                    break
                                }
                                
                                if(viewRouter.loginStaffId != staffId && !viewRouter.loginStaffId.isEmpty){
                                    if(startTimeByFS == startTime && deleteFlg == 0){
                                        alertType = .blocked
                                        break
                                    }
                                }
                                
                                
                                if(shift.startTime != startTimeByFS){
                                    alertType = .successed
                                }
                                else{
                                    if(deleteFlg == 1){
                                        alertType = .successed
                                    }
                                }
                            }
                            
                            if(alertType == .successed){
                                tempArray.append(shift)
                                batch.setData([
                                    "10_STAFF_ID"   : shift.staffId,
                                    "20_START_DATE" : Timestamp(date:shift.startDate),
                                    "30_END_DATE"   : Timestamp(date:shift.endDate),
                                    "40_START_TIME" : Timestamp(date:startTime),
                                    "50_SEQ"        : shift.seq,
                                    "70_CREATE_DATE": Timestamp(date:shift.createDate),
                                    "80_UPDATE_DATE": Timestamp(date:shift.updateDate),
                                    "99_DELETE_FLG" : shift.deleteFlg
                                ],forDocument: docRef)
                            }
                        }
                    }
                    
                    if(alertType == .shiftExist || alertType == .blocked){
                        tempArray.removeAll()
                        gcp.dismiss()
                        // アラートを表示
                        self.showinfAlert = true
                    }
                    else{
                        batch.commit(){ err in
                            if let err = err {
                                alertType = .unexpectedError
                            }
                            else {
                                alertType = .successed
                            }
                            tempArray.removeAll()
                            gcp.dismiss()
                            // アラートを表示
                            self.showinfAlert = true
                        }
                    }
                    
                }
            }
    }
}

struct DayRectView_Previews: PreviewProvider {
    static var previews: some View {
        DayRectView(day:Date())
    }
}
