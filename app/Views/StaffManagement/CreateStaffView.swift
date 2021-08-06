//
//  CreateStaffView.swift
//  ProtoTypeApp
//
//  Created by 高木一弘 on 2021/06/15.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import GradientCircularProgress

struct CreateStaffView: View {
    
    // モーダルの表示制御用
    @Binding var isPresented : Bool
    // アラート表示用のフラグ。
    @State var isAlertShowing = false
    
    // 入力のキャンセル・完了時のコンポーネント制御用フラグ
    @State var isFinishing = false
    
    // 入力のキャンセル・完了時に一覧画面に戻るための変数
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var firestoreData : FirestoreDataRepository
    
    var gcp = GradientCircularProgress()
    
    @State private var name = ""
    @State private var mail  = ""
    @State private var password = ""
    
    let db = Firestore.firestore()
    
    @State private var alertType : AlertType = .confirm
    enum AlertType {
        case confirm
        case complete
        case failed
    }
    
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
//                        .onReceive(Just(fee)){ newValue in
//                            let filtered = newValue.filter {"0123456789".contains($0)}
//
//                            if filtered != newValue{
//                                self.fee = filtered
//                            }
//                        }
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
            }
            
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading:
                    Button(action: {self.isPresented.toggle()}, label: {Text("キャンセル").foregroundColor(.white)}),
                trailing:
                    Button(
                        action: {
                            self.isFinishing    = true
                            self.isAlertShowing = true
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
                    title: Text("スタッフを登録しますか？"),
                    message: nil,
                    primaryButton: .cancel(Text("キャンセル")),
                    secondaryButton:
                        .default (
                            Text("OK"),
                            action: {
                                saveStaffDataToFirestore(with: getDataFromView())
                            }
                        )
                    )
            case .complete:
                return Alert(
                    title: Text("スタッフを作成しました"),
                    message:nil,
                    dismissButton:.default(Text("OK"),action: {
                        self.alertType = .confirm
                        self.presentationMode.wrappedValue.dismiss()
                    })
                )
            case .failed:
                return Alert(
                    title: Text("スタッフの作成に失敗しました"),
                    message: Text("通信環境をお確かめの上、時間を置いて再度実施してください"),
                    dismissButton:.default(Text("OK"),action: {
                        self.alertType = .confirm
                        self.presentationMode.wrappedValue.dismiss()
                    })
                )
        }
    }
    
    private func saveStaffDataToFirestore(with:Staff){
        gcp.show(message: "Loading...", style: ProgressCircleStyle())
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = false
        db.settings = settings
        
        Auth.auth().createUser(withEmail: with.mail, password: with.password) { authResult, error in
            
            if let authResult = authResult {
                let staffId = authResult.user.uid
                
                let TAG_COLLECTION = "20_STAFF"
                
                let TAG_STAFF_NAME = "10_NAME"
                let TAG_EMAIL = "20_EMAIL"
                let TAG_CREATE_DATE = "70_CREATE_DATE"
                let TAG_UPDATE_DATE = "80_UPDATE_DATE"
                let TAG_DELETE_FLG = "99_DELETE_FLG"
                
                let now = Timestamp(date: Date())
                
                
                db.collection(TAG_COLLECTION).document(staffId).setData([
                    TAG_STAFF_NAME: with.name,
                    TAG_EMAIL : with.mail,
                    TAG_CREATE_DATE: now,
                    TAG_UPDATE_DATE: now,
                    TAG_DELETE_FLG:0
                ]) { err in
                    if let err = err {
                        print("error : " + err.localizedDescription)
                        gcp.dismiss()
                        self.alertType = .failed
                        self.isAlertShowing.toggle()
                    } else {
                        gcp.dismiss()
                        self.alertType = .complete
                        self.isAlertShowing.toggle()
                        
//                        firestoreData.staff.entities.append(with)
                        
//                        for i in 0..<firestoreData.staff.entities.count {
//                            if firestoreData.staff.entities[i].id == with.id{
//                                firestoreData.staff.entities[i] = with
//                            }
//                        }
                        
                    }
                }
            }
            else{
                self.alertType = .failed
                self.isAlertShowing.toggle()
            }
        }
    }
    
    private func getDataFromView() -> Staff {
        let stff = Staff()
        stff.name     = self.name
        stff.mail     = self.mail
        stff.password = self.password
        return stff
    }
    
    private func isFormValid() -> Bool {
        if(!name.isEmpty && !mail.isEmpty && !password.isEmpty){
            return true
        }
        else{
            return false
        }
    }
}

//struct CreateStaffView_Previews: PreviewProvider {
//    static var previews: some View {
//        CreateStaffView(isPresented: .constant(true))
//    }
//}
