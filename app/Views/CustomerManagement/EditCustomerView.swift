//
//  EditCustomerView.swift
//  app
//
//  Created by 高木一弘 on 2021/08/02.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import GradientCircularProgress

struct EditCustomerView: View {
    
    private var customer : Customer
    
    // 入力のキャンセル・完了時のコンポーネント制御用フラグ
    @State var isEditing = false
    
    // アラート表示用のフラグ。
    @State var updateAlert = false
    @State var mailInitAlert = false
    @State var deleteAlert = false
//    @State var requireAlert = false
    
    // 一覧画面に戻るための変数
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var firestoreData : FirestoreDataRepository
    
    @State private var name = ""
    @State private var mail = ""
    @State private var ticketLeft = 0
    var gcp = GradientCircularProgress()
    
    
    enum AlertType {
        case confirm
        case complete
        case failed
    }
    
    @State private var alertType : AlertType = .confirm
    let db = Firestore.firestore()
    
    init(cstmr:Customer){
        self.customer = cstmr
        self._name = State(initialValue: customer.name)
        self._mail  = State(initialValue: customer.mail)
        
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
//                        .onReceive(Just(fee)){ newValue in
//                            let filtered = newValue.filter {"0123456789".contains($0)}
//
//                            if filtered != newValue{
//                                self.fee = filtered
//                            }
//                        }
            }
            HStack {
                Text("コース")
                    .font(.body)
                Spacer()
                Text(firestoreData.programs.getProgramName(withID: self.customer.program))
            }
            HStack {
                Text("予約可能数(今月残)")
                    .font(.body)
                Spacer()
                if(self.ticketLeft>=0){
                    Text(String(ticketLeft))
                }
                else{
                    Text("")
                }
                
            }
            .onAppear{
                getTicketLeft(with: self.customer.id)
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
            
            Section{
                EmptyView()

            }
            .padding(.bottom, 100)
            
            Section{
                Button(
                    action:{
                        // アラートを表示
                        self.deleteAlert = true
                        self.alertType = .confirm
                    },
                    label: {
                        Text("顧客を削除")
                            .foregroundColor(.red)
                    }
                )
                .alert(isPresented: $deleteAlert){
                    showDeleteAlert()
                }
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
                .disabled(self.name.isEmpty)
                .alert(isPresented: $updateAlert){
                    showUpdateAlert()
                }
        )
    }
    
    private func sendPassSettingMail(withEmail:String){
        gcp.show(message: "Loading...", style: ProgressCircleStyle())
        Auth.auth().sendPasswordReset(withEmail: withEmail) { error in
            if let error = error {
                print("password reset failed : \(error)")
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
    
    private func showUpdateAlert() -> Alert {
        switch alertType {
        case .confirm:
            return Alert(
                title: Text("顧客情報を修正しますか？"),
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
                title: Text("顧客情報を更新しました"),
                message:nil,
                dismissButton:.default(Text("OK"),action: {
                    self.alertType = .confirm
                    self.presentationMode.wrappedValue.dismiss()
                })
            )
        case .failed:
            return Alert(
                title: Text("顧客情報の更新に失敗しました"),
                message: Text("通信環境をお確かめの上、時間を置いて再度実施してください"),
                dismissButton:.default(Text("OK"),action: {
                    self.alertType = .confirm
                    self.presentationMode.wrappedValue.dismiss()
                })
            )
        }
    }
    
    private func showDeleteAlert() -> Alert {
        switch alertType {
        case .confirm:
            return Alert(
                title: Text("顧客情報を削除"),
                message: Text("お客様がアプリへのログインおよび予約が不可となります。\n削除した場合、元に戻す事はできません。\n削除しますか？"),
                primaryButton: .cancel(Text("キャンセル")),
                secondaryButton:
                    .destructive (
                        Text("削除する"),
                        action: {
                            deleteData(with: getDataFromView())
                        }
                    )
                )
        case .complete:
            return Alert(
                title: Text("顧客情報を削除しました"),
                message:nil,
                dismissButton:.default(Text("OK"),action: {
                    self.alertType = .confirm
                    self.presentationMode.wrappedValue.dismiss()
                })
            )
        case .failed:
            return Alert(
                title: Text("顧客情報の削除に失敗しました"),
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
                    message:Text("お送りしたメール文面にしたがって、パスワードの再設定をお客様に依頼してください"),
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
    
    private func getTicketLeft(with:String){
        DispatchQueue.global().async {
            
            let docRef = self.db.collection("60_CUSTOMER_TICKET").document(with)
            
            docRef.getDocument{(document,error)in
                if let document = document, document.exists{
                    let data               = document.data()
                    self.ticketLeft = data?["10_NUM_LEFT"] as? Int ?? 0
                }
                else{
                    self.ticketLeft = -1
                }
            }
        }
    }
    
    private func updateData(with:Customer){
        gcp.show(message: "Loading...", style: ProgressCircleStyle())
        let TAG_COLLECTION = "30_CUSTOMER"

        let TAG_STAFF_NAME = "10_NAME"
        let TAG_UPDATE_DATE = "80_UPDATE_DATE"

        let now = Timestamp(date: Date())


        db.collection(TAG_COLLECTION).document(with.id).updateData([
            TAG_STAFF_NAME: with.name,
            TAG_UPDATE_DATE: now,
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
                
                for i in 0..<firestoreData.customer.entities.count {
                    if firestoreData.customer.entities[i].id == with.id{
                        firestoreData.customer.entities[i].name = with.name
                    }
                }
            }
        }
    }
    
    private func deleteData(with:Customer){
        gcp.show(message: "Loading...", style: ProgressCircleStyle())
        let db = Firestore.firestore()
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = false
        db.settings = settings
        
    
        let csRef = db.collection("30_CUSTOMER").document(with.id)
        let ticRef = db.collection("60_CUSTOMER_TICKET").document(with.id)
        
        db.collection("50_RESERVATION").whereField("20_CUSTOMER_ID", isEqualTo: with.id)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                    gcp.dismiss()
                    self.alertType = .failed
                    self.deleteAlert.toggle()
                } else {
                    
                    db.runTransaction({ (transaction, errorPointer) -> Any? in
                        transaction.updateData(["99_DELETE_FLG"  : 1],forDocument: csRef)
                        transaction.updateData(["99_DELETE_FLG"  : 1],forDocument: ticRef)
                        
                        for document in querySnapshot!.documents {
                            transaction.updateData(["99_DELETE_FLG"  : 1],forDocument: document.reference)
                        }
                        
                        return nil
                    }) { (object, error) in
                        if let error = error {
                            print("Transaction failed: \(error)")
                            gcp.dismiss()
                            self.alertType = .failed
                            self.deleteAlert.toggle()
                        } else {
                            print("Transaction successfully committed!")
                            gcp.dismiss()
                            for i in 0..<firestoreData.customer.entities.count {
                                if firestoreData.customer.entities[i].id == with.id{
                                    firestoreData.customer.entities[i].deleteFlg = 1
                                    firestoreData.customer.entities.remove(at: i)
                                }
                            }
                            
                            for j in 0..<firestoreData.reservation.entities.count {
                                if firestoreData.reservation.entities[j].customerId == with.id{
                                    firestoreData.reservation.entities[j].deleteFlg = 1
                                }
                            }
                            
                            self.alertType = .complete
                            self.deleteAlert.toggle()
                        }
                    }
                }
        }
        

        
    }
    
    private func getDataFromView() -> Customer{
        let cstmr = self.customer
        cstmr.name     = self.name
        return cstmr
    }
    
    private func isFormValid() -> Bool {
        if(!name.isEmpty && !mail.isEmpty){
            return true
        }
        else{
            return false
        }
    }
}
