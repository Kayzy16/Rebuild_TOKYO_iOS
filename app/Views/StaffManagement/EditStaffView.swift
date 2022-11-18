//
//  EditStaffView.swift
//  ProtoTypeApp
//
//  Created by 高木一弘 on 2021/06/15.
//
import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import GradientCircularProgress

struct EditStaffView: View {
    
    private var staff : Staff
    
    // 入力のキャンセル・完了時のコンポーネント制御用フラグ
    @State var isEditing = false
    
    // アラート表示用のフラグ。
    @State var updateAlert = false
    @State var mailInitAlert = false
//    @State var deleteAlert = false
//    @State var requireAlert = false
    
    // 一覧画面に戻るための変数
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var firestoreData : FirestoreDataRepository
    @EnvironmentObject var viewRouter: ViewRouter

    var gcp = GradientCircularProgress()
    @State private var name = ""
    @State private var mail = ""
    @State private var password = ""
//    @State private var authLevel = 20
    @State private var selectedAuthLevel : AuthLevel?
    
    
    enum AlertType {
        case confirm
        case complete
        case failed
    }
    @State private var alertType : AlertType = .confirm
    
    
    let db = Firestore.firestore()
    
    init(staff:Staff){
        self.staff = staff
        self._name = State(initialValue: staff.name)
        self._mail  = State(initialValue: staff.mail)
        self._password = State(initialValue: staff.password)
//        self._authLevel = State(initialValue: staff.authLevel)
        
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = false
        db.settings = settings
    }
    
    var body: some View {
        Form{
            HStack {
                Text("名前")
                    .font(.body)
                Spacer()
                TextField("",text:$name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width:CGFloat(160))
                    .disabled(!isEditing)
                    .font(.body)
            }
            
            HStack {
                Text("メールアドレス")
                    .font(.body)
                Spacer()
                TextField("",text:$mail)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width:CGFloat(160))
                    .disabled(true)
                    .font(.body)
                    .keyboardType(.emailAddress)
            }
            HStack {
                NavigationLink(destination: AuthPickerView(selectedAuthLevel: $selectedAuthLevel)){
                    HStack{
                        Text("権限ロール")
                        Spacer()
                        Text(selectedAuthLevel?.name ?? "")
                    }
                }
                .disabled(!isEditing)
            }
            
            Section{
                Button(
                    action:{
                        // アラートを表示
                        self.mailInitAlert = true
                        self.alertType = .confirm
                    },
                    label: {
                        Text("パスワードを初期化")
                            .foregroundColor(.red)
                    }
                )
                .alert(isPresented: $mailInitAlert){
                    showMailInitAlert()
                }
            }
        }
        .onAppear(){
            print(self.staff.authLevel)
            if nil == self.selectedAuthLevel{
                self.selectedAuthLevel = firestoreData.authLevel.getAuthLevel(withLevel: staff.authLevel)
            }
        }
        
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(isEditing)
        .navigationBarItems(
            leading:
                Button(
                    action: {
                        self.isEditing.toggle()
                    },
                    label: {
                        if(isEditing){
                            Text("キャンセル")
                        }
                        else{
                            self.hidden()
                        }
                    }
                ),
            trailing:
                Button(
                    action: {
                        if(isEditing){
                            
//                            StaffDao.update(target:self.staff,with:getDataFromView())
                            // アラートを表示
                            self.updateAlert = true
                        }
                        self.isEditing.toggle()
                    },
                    label: {
                        if(isEditing){
                            Text("完了")
                        }
                        else{
                            Text("編集")
                        }
                    }
                )
                .disabled(name.isEmpty || nil == selectedAuthLevel)
                .alert(isPresented: $updateAlert){
                    showAlert()
                }
        )
    }
    
    private func sendPassSettingMail(withEmail:String){
        gcp.show(message: "Loading...", style: ProgressCircleStyle())
        Auth.auth().sendPasswordReset(withEmail: withEmail) { error in
            if let error = error {
//                print("password reset failed : \(error)")
                gcp.dismiss()
                self.alertType = .failed
                self.mailInitAlert.toggle()
            }
            else{
                gcp.dismiss()
                self.alertType = .complete
                self.mailInitAlert.toggle()
            }
        }
    }
    
    private func showAlert() -> Alert {
        switch alertType {
        case .confirm:
            return Alert(
                title: Text("スタッフを修正しますか？"),
                message: nil,
                primaryButton: .cancel(Text("キャンセル")),
                secondaryButton:
                    .default (
                        Text("OK"),
                        action: {
                            updateData(with: getDataFromView())
                        }
                    )
                )
        case .complete:
            return Alert(
                title: Text("スタッフを更新しました"),
                message:nil,
                dismissButton:.default(Text("OK"),action: {
                    self.alertType = .confirm
                    self.presentationMode.wrappedValue.dismiss()
                })
            )
        case .failed:
            return Alert(
                title: Text("スタッフの更新に失敗しました"),
                message: Text("通信環境をお確かめの上、時間を置いて再度実施してください"),
                dismissButton:.default(Text("OK"),action: {
                    self.alertType = .confirm
                    self.presentationMode.wrappedValue.dismiss()
                })
            )
        }
    }
    
    private func showMailInitAlert() -> Alert {
        switch alertType {
            case .confirm :
                return Alert(
                    title: Text("パスワードを初期化しますか？"),
                    message: nil,
                    primaryButton: .cancel(Text("キャンセル")),
                    secondaryButton:
                        .destructive(
                            Text("初期化する"),
                            action: {
                                sendPassSettingMail(withEmail: self.mail)
                            }
                        )
                    )
            case .complete :
                return Alert(
                    title: Text("パスワード設定メールを送りました"),
                    message:Text("お送りしたメール文面にしたがって、パスワードの再設定をお願いします"),
                    dismissButton:
                        .default(Text("OK"),
                         action: {
                            self.presentationMode.wrappedValue.dismiss()
                         })
                )
        case .failed:
            return Alert(
                title: Text("パスワードの初期化に失敗しました"),
                message:Text(""),
                dismissButton:
                    .default(Text("通信環境をお確かめの上、時間を置いて再度実施してください"),
                     action: {
                        self.presentationMode.wrappedValue.dismiss()
                     })
            )
        }
    }
    
    private func updateData(with:Staff){
        gcp.show(message: "Loading...", style: ProgressCircleStyle())
        let TAG_COLLECTION = "20_STAFF"
        
        let TAG_STAFF_NAME = "10_NAME"
        let TAG_EMAIL = "20_EMAIL"
        let TAG_AUTH_LEVEL = "30_AUTH_LEVEL"
        let TAG_CREATE_DATE = "70_CREATE_DATE"
        let TAG_UPDATE_DATE = "80_UPDATE_DATE"
        let TAG_DELETE_FLG = "99_DELETE_FLG"
        
        let now = Timestamp(date: Date())
        
        
        db.collection(TAG_COLLECTION).document(with.id).setData([
            TAG_STAFF_NAME: with.name,
            TAG_EMAIL : with.mail,
            TAG_AUTH_LEVEL : with.authLevel,
            TAG_CREATE_DATE: with.createDate,
            TAG_UPDATE_DATE: now,
            TAG_DELETE_FLG:0
        ]) { err in
            if let err = err {
                gcp.dismiss()
                print("Error adding document: \(err)")
                self.alertType = .failed
                self.updateAlert.toggle()
            } else {
                gcp.dismiss()
                self.alertType = .complete
                self.updateAlert.toggle()
                
                for i in 0..<firestoreData.staff.entities.count {
//                    print(firestoreData.staff.entities[i].id)
                    if firestoreData.staff.entities[i].id == with.id{
                        firestoreData.staff.entities[i].name = with.name
                        firestoreData.staff.entities[i].authLevel = with.authLevel
                    }
                }
                
            }
        }
    }
    
    private func getDataFromView() -> Staff {
        let stff      = self.staff
        stff.name     = self.name
        stff.mail     = self.mail
        stff.password = self.password
        stff.authLevel = self.selectedAuthLevel?.authLevel ?? 20
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

struct EditStaffView_Previews: PreviewProvider {
    static var previews: some View {
        let stff = StaffDao.getFirst()
        EditStaffView(staff:stff)
    }
}
