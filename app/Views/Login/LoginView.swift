//
//  LoginView.swift
//  ProtoTypeApp
//
//  Created by 高木一弘 on 2021/06/09.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import GradientCircularProgress

struct LoginView: View {
    var staffViewModel = StaffViewModel()
    @State var loadingComp : Bool = false
    
    @State private var mail     = ""
    @State private var password = ""
    @State private var auth_comp  : Bool = false
    @State private var auth_error : Bool = false
    
    @State private var login_user_id = ""
    @State private var login_user_type = 0
    @State private var error_msg = "メールアドレス、またはパスワードが謝っています"
    
    @EnvironmentObject var viewRouter: ViewRouter
    
    var gcp = GradientCircularProgress()
    let db = Firestore.firestore()
    
    @EnvironmentObject var firestoreData : FirestoreDataRepository
    
    init(){
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = false
        db.settings = settings
    }
    
    
    var body: some View {
        NavigationView{
            ZStack {
                Image("LaunchScreen")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .edgesIgnoringSafeArea(.top)
                    .edgesIgnoringSafeArea(.bottom)
                
                
                if loadingComp {
                    Rectangle()
                        .fill(ColorManager.fogMask)
                        .edgesIgnoringSafeArea(.top)
                        .edgesIgnoringSafeArea(.bottom)
                        .opacity(0.6)
                        .blur(radius: 10.0)
                        .transition(.opacity)
                    
                    VStack() {
                        Spacer()
                        Text(self.error_msg)
                            .opacity(auth_error ? 1 : 0)
                            .foregroundColor(.red)
                        
                        TextField("E-mail address",text:$mail)
                            .textFieldStyle(FatTextFieldStyle())
                            .background(Color(.white))
                            .foregroundColor(.black)
                            .frame(width : 300,height: 50)
                            .keyboardType(.emailAddress)
                            .transition(.opacity)
                            
                        
                        SecureField("password",text:$password)
                            .textFieldStyle(FatTextFieldStyle())
                            .background(Color(.white))
                            .foregroundColor(.black)
                            .frame(width : 300,height: 50)
                            .padding(.bottom)
                            .transition(.opacity)
                        
                        
                        
                        Button(action: {tryLogin()})
                        {
                            Text("Sign in")
                                .font(.body)
                                .foregroundColor(Color.white)
                        }
                        .padding(.all)
                        .background(ColorManager.accentOrage)
                        
                        Spacer()
                            
                    }
                }
                
            }
            .onAppear{
                DispatchQueue.main.asyncAfter(deadline:.now()+3.0){
                    withAnimation(){
                        self.loadingComp.toggle()
                    }
                }
            }
        }
    }
    
    private func tryLogin(){
        gcp.show(message: "Loading...", style: ProgressCircleStyle())
        Auth.auth().signIn(withEmail: mail, password: password){(result,error) in
            if error != nil{
                self.auth_error = true
                error_msg = "メールアドレス、またはパスワードが謝っています"
                gcp.dismiss()
            }
            else{
                getSystemMasterData()
            }
        }
    }
    
    private func finishAuth(){
        withAnimation{
            viewRouter.currentPage = .calendar
        }
        self.auth_comp = true
    }
    
    private func getSystemMasterData(){
        let docRef = db.collection("10_CONSTANTS").document("10_SETTING_VALUES")
        docRef.getDocument{ (document, error) in
          if let doc = document {
            let data = doc.data()
            business_start = data?["10_BUSINESS_START_TIME"] as? Int ?? 10
            business_end = data?["11_BUSINESS_END_TIME"] as? Int ?? 22
            lesson_length = data?["20_LESSON_LENGTH"] as? Int ?? 90
            lesson_rest_length = data?["21_LESSON_REST_LENGTH"] as? Int ?? 30
            default_ticket_Num = data?["30_DEFAULT_TICKET_NUM"] as? Int ?? 30
            
            updateUI()
            
          } else {
            print("Document does not exist in cache")
          }
        }
    }
    
    private func updateUI(){
        let user = Auth.auth().currentUser
        if let user = user {
            let docRef = db.collection("20_STAFF").document(user.uid)
            
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    viewRouter.loginUserType = .staff
                    viewRouter.loginStaffId = user.uid
                    finishAuth()
                } else {
                    viewRouter.loginUserType = .customer
                    viewRouter.loginCustomerId = user.uid
                    checkCustomerState()
                }
            }
        }
    }
    private func checkCustomerState(){
        let user = Auth.auth().currentUser
        if let user = user{
            let docRef = db.collection("30_CUSTOMER").document(user.uid)
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    let data = document.data()
                    let deleteFlg = data?["99_DELETE_FLG"] as? Int ?? 0
                    if deleteFlg > 0{
                        error_msg = "アカウントが無効です"
                        self.auth_error = true
                    }
                    else{
                        checkTicket()
                    }
                }
            }
        }
    }
    
    private func checkTicket(){
        let user = Auth.auth().currentUser
        if let user = user{
            let docRef = db.collection("60_CUSTOMER_TICKET").document(user.uid)

            // TODO チケットの更新月と、現在の月を比較
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    firestoreData.ticket.fetchData(customerId: user.uid)
                    finishAuth()
                }
            }
        }
    }
    
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
