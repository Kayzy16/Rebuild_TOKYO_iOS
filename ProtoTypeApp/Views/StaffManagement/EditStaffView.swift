//
//  EditStaffView.swift
//  ProtoTypeApp
//
//  Created by 高木一弘 on 2021/06/15.
//

import SwiftUI

struct EditStaffView: View {
    
    private var staff : Staff
    
    // 入力のキャンセル・完了時のコンポーネント制御用フラグ
    @State var isEditing = false
    
    // アラート表示用のフラグ。
    @State var updateAlert = false
    @State var deleteAlert = false
    @State var requireAlert = false
    
    // 一覧画面に戻るための変数
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State private var name = ""
    @State private var mail = ""
    @State private var password = ""
    
    
    enum AlertType {
        case confirm
        case complete
    }
    
    @State private var alertType : AlertType = .confirm
    
    init(staff:Staff){
        self.staff = staff
        self._name = State(initialValue: staff.name)
        self._mail  = State(initialValue: staff.mail)
        self._password = State(initialValue: staff.password)
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
                    .disabled(!isEditing)
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
                    .disabled(!isEditing)
                    .font(.body)
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
                            StaffDao.update(target:self.staff,with:getDataFromView())
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
                .disabled(name.isEmpty)
                .alert(isPresented: $updateAlert){
                    Alert(
                        title: Text("更新が完了しました"),
                        dismissButton:
                            .default(Text("OK"),
                             action: {self.presentationMode.wrappedValue.dismiss()})
                    )
                }
        )
    }
    
    private func getDataFromView() -> Staff{
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

struct EditStaffView_Previews: PreviewProvider {
    static var previews: some View {
        let stff = StaffDao.getFirst()
        EditStaffView(staff:stff)
    }
}
