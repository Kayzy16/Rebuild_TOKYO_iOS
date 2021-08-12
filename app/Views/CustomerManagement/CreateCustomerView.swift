//
//  CreateCustomerView.swift
//  app
//
//  Created by 高木一弘 on 2021/08/02.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import GradientCircularProgress

struct CreateCustomerView: View {
    // モーダルの表示制御用
    @Binding var isPresented : Bool
    // アラート表示用のフラグ。
    @State var isAlertShowing = false
    
    // 入力のキャンセル・完了時のコンポーネント制御用フラグ
    @State var isFinishing = false
    
    // 入力のキャンセル・完了時に一覧画面に戻るための変数
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var firestoreData : FirestoreDataRepository
    
    @State private var name = ""
    @State private var mail  = ""
    @State private var password = ""
    @State private var selectedProgram : Program?
    @State private var initialTicket = ""
    @State private var errorMsg = "通信環境をお確かめの上、時間を置いて再度実施してください"
    
    let db = Firestore.firestore()
    
    @State private var alertType : AlertType = .confirm
    enum AlertType {
        case confirm
        case complete
        case failed
    }
    
    var gcp = GradientCircularProgress()
    
    var body: some View {
        NavigationView {
            Form{
                HStack {
                    Text("名前")
                        .font(.body)
                    Spacer()
                    TextField("",text:$name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width:CGFloat(160))
                        .disabled(isFinishing)
                        .font(.body)
                }
                
                HStack {
                    Text("メールアドレス")
                        .font(.body)
                    Spacer()
                    TextField("",text:$mail)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width:CGFloat(160))
                        .disabled(isFinishing)
                        .font(.body)
                        .keyboardType(.emailAddress)
                }
                HStack {
                    Text("パスワード")
                        .font(.body)
                    Spacer()
                    TextField("",text:$password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width:CGFloat(160))
                        .disabled(isFinishing)
                        .font(.body)
                }
                
                HStack {
                    NavigationLink(destination: ProgramPickerView(selectedProgram: $selectedProgram)){
                        HStack{
                            Text("コース")
                            Spacer()
                            Text(selectedProgram?.name ?? "")
                        }
                    }
                }
                
                HStack {
                    Text("予約可能数(毎月)")
                        .font(.body)
                    Spacer()
                    Text(String(selectedProgram?.num ?? 0))
//                    TextField("",text:$password)
//                        .textFieldStyle(RoundedBorderTextFieldStyle())
//                        .frame(width:CGFloat(160))
//                        .disabled(isFinishing)
//                        .font(.body)
                }
                
                HStack {
                    Text("予約可能数(初月)")
                        .font(.body)
                    Spacer()
                    TextField("",text:$initialTicket)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                        .frame(width:CGFloat(160))
                        .disabled(isFinishing)
                        .font(.body)
                }
                
            }
            
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading:
                    Button(action: {self.isPresented.toggle()}, label: {Text("キャンセル").foregroundColor(.white)}),
                trailing:
                    Button(
                        action: {
                            if isInitialTicketValid(){
                                self.isFinishing    = true
                                self.isAlertShowing = true
                            }
                            else{
                                errorMsg = "『予約回数(毎月)』が『予約可能数(初月)』より大きくなるよう入力してください"
                                self.alertType = .failed
                                self.isAlertShowing.toggle()
                            }
                        },
                        label: {
                            if(!isFormValid()){
                                Text("完了")
                                    .disabled(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                            }
                            else{
                                Text("完了")
                            }
                        }
                    )
                    .disabled(!isFormValid())
                    .alert(isPresented: $isAlertShowing){
                        showAlert()
                    }
            )
        }
    }
    
    private func showAlert() -> Alert {
        switch alertType {
            case .confirm:
                return Alert(
                    title: Text("顧客を登録しますか？"),
                    message: nil,
                    primaryButton: .cancel(Text("キャンセル")),
                    secondaryButton:
                        .default (
                            Text("OK"),
                            action: {
                                saveCustomerDataToFirestore(with: getDataFromView())
                            }
                        )
                    )
            case .complete:
                return Alert(
                    title: Text("顧客を登録しました"),
                    message:nil,
                    dismissButton:.default(Text("OK"),action: {
                        self.alertType = .confirm
                        self.presentationMode.wrappedValue.dismiss()
                    })
                )
            case .failed:
                return Alert(
                    title: Text("顧客の作成に失敗しました"),
                    message: Text(errorMsg),
                    dismissButton:.default(Text("OK"),action: {self.alertType = .confirm})
                )
        }
    }
    
    private func saveCustomerDataToFirestore(with:Customer){
        gcp.show(message: "Loading...", style: ProgressCircleStyle())
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = false
        db.settings = settings
        let now = Timestamp(date: Date())
        
        Auth.auth().createUser(withEmail: with.mail, password: with.password) { authResult, error in
            
            if nil != error {
                
                if let errCode = AuthErrorCode(rawValue: error!._code){
                    switch errCode {
                        case .invalidEmail:
                            errorMsg = "メールアドレスの形式が正しくありません"
                        case .emailAlreadyInUse:
                            errorMsg = "登録済みのメールアドレスです"
                        case .weakPassword:
                            errorMsg = "パスワードは6文字以上で入力してください"
                        default:
                            errorMsg = "通信環境をお確かめの上、時間を置いて再度実施してください"
                    }
                }
                else{
                    errorMsg = "想定外のエラーが発生しました。管理者に連絡してください"
                    
                }
                gcp.dismiss()
                self.alertType = .failed
                self.isAlertShowing.toggle()
                self.isFinishing.toggle()
                return
            }

            if let authResult = authResult {
                
                let db = Firestore.firestore()
                let settings = FirestoreSettings()
                settings.isPersistenceEnabled = false
                db.settings = settings
                
                let batch = db.batch()
                
                
                let cstmr = db.collection("30_CUSTOMER").document(authResult.user.uid)
                batch.setData([
                    "10_NAME"        : with.name,
                    "20_EMAIL"       : with.mail,
                    "30_PROGRAM"     : self.selectedProgram!.id,
                    "70_CREATE_DATE" : now,
                    "80_UPDATE_DATE" : now,
                    "99_DELETE_FLG"  : 0
                ],forDocument: cstmr)
                
                let tickt = db.collection("60_CUSTOMER_TICKET").document(authResult.user.uid)
                batch.setData([
                    "10_NUM_LEFT"    :Int(self.initialTicket) ?? 0,
                    "70_CREATE_DATE" :now,
                    "80_UPDATE_DATE" :now,
                    "99_DELETE_FLG"  :0
                ],forDocument: tickt)
//
                batch.commit(){ err in
                    if let err = err {
                        print("Error writing reservation :  \(err)")
                        gcp.dismiss()
                        self.alertType = .failed
                        self.isAlertShowing.toggle()
                    }
                    else{
                        gcp.dismiss()
                        self.alertType = .complete
                        self.isAlertShowing.toggle()
                    }
                }
            }
            else{
                gcp.dismiss()
                errorMsg = "想定外のエラーが発生しました。管理者に連絡してください"
                self.alertType = .failed
                self.isAlertShowing.toggle()
                self.isFinishing.toggle()
            }
        }
    }
    
    private func getDataFromView() -> Customer {
        let cstmr = Customer()
        cstmr.name     = self.name
        cstmr.mail     = self.mail
        cstmr.password = self.password
        return cstmr
    }
    
    private func isFormValid() -> Bool {
        if(!name.isEmpty && !mail.isEmpty && !password.isEmpty && (nil != selectedProgram) && !initialTicket.isEmpty){
            return true
        }
        else{
            return false
        }
    }
    
    private func isInitialTicketValid() -> Bool{
        let usualTicket = selectedProgram?.num ?? 0
        let initialTicket = Int(self.initialTicket) ?? 0
        if usualTicket < initialTicket {
            return false
        }
        else{
            return true
        }
    }
}

//struct CreateStaffView_Previews: PreviewProvider {
//    static var previews: some View {
//        CreateStaffView(isPresented: .constant(true))
//    }
//}
