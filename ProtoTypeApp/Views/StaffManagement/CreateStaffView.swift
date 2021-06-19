//
//  CreateStaffView.swift
//  ProtoTypeApp
//
//  Created by 高木一弘 on 2021/06/15.
//

import SwiftUI

struct CreateStaffView: View {
    
    // モーダルの表示制御用
    @Binding var isPresented : Bool
    // アラート表示用のフラグ。
    @State var isAlertShowing = false
    
    // 入力のキャンセル・完了時のコンポーネント制御用フラグ
    @State var isFinishing = false
    
    // 入力のキャンセル・完了時に一覧画面に戻るための変数
    @Environment(\.presentationMode) var presentationMode
    
    @State private var name = ""
    @State private var mail  = ""
    @State private var password = ""
    
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
                            
                            let stff = getDataFromView()
                            StaffDao.save(with: stff)
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
                        Alert(
                            title: Text("スタッフを保存しました"),
                            dismissButton:
                                .default(
                                    Text("OK"),
                                    action: {
                                        self.isPresented.toggle()
                                    }
                                ))
                    }
            )
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

struct CreateStaffView_Previews: PreviewProvider {
    static var previews: some View {
        CreateStaffView(isPresented: .constant(true))
    }
}
