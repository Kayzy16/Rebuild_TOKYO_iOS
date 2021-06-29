//
//  LoginView.swift
//  ProtoTypeApp
//
//  Created by 高木一弘 on 2021/06/09.
//

import SwiftUI

struct LoginView: View {
    var staffViewModel = StaffViewModel()
    @State var loadingComp : Bool = false
    
    @State private var mail     = ""
    @State private var password = ""
    @State private var auth_comp  : Bool = false
    @State private var auth_error : Bool = false
    
    @State private var login_user_id = ""
    @State private var login_user_type = 0
    
    @EnvironmentObject var viewRouter: ViewRouter
    
    
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
                        Text("* wrong E-mail address, or password")
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
                staffViewModel.fetchData(){ staff in
                    withAnimation(){
                        self.loadingComp.toggle()
                    }
                    
                }
            }
        }
    }
    
    private func tryLogin(){
        let staff_id = authorisingStaffId()
        let customer_id = authorisingCustomerId()
        
        
        if !staff_id.isEmpty{
            withAnimation{
                viewRouter.currentPage = .calendar
            }
            self.auth_comp = true
            viewRouter.loginUserType = .staff
            viewRouter.loginStaffId = staff_id
        }
        else if !customer_id.isEmpty{
            withAnimation{
                viewRouter.currentPage = .calendar
            }
            self.auth_comp = true
            viewRouter.loginUserType = .customer
            viewRouter.loginCustomerId = customer_id
        }
        else{
            self.auth_error.toggle()
        }
    }
    
    private func authorisingStaffId() -> String {
        let staff = StaffDao.getAll()
        var login_staff_id = ""
        
        staff.forEach(){ stf in
            if(stf.mail.lowercased() == self.mail.lowercased() && stf.password == self.password){
                login_staff_id = stf.id
            }
        }
        
        return login_staff_id
    }
    
    private func authorisingCustomerId() -> String {
        let cus = CustomerDao.getAll()
        var login_customer_id = ""
        
        cus.forEach(){ cstmr in
            if(cstmr.mail.lowercased() == self.mail.lowercased() && cstmr.password == self.password){
                login_customer_id = cstmr.id
            }
        }
        return login_customer_id
    }
    
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
