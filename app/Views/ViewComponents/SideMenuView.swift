//
//  SideMenuView.swift
//  ProtoTypeApp
//
//  Created by 高木一弘 on 2021/06/10.
//

import SwiftUI

struct SideMenuView: View {
    
    @Environment(\.openURL) var openURL
    @EnvironmentObject var viewRouter: ViewRouter
    @State private var showSheet : Bool = false
    
    @State private var sheetType : SheetType = .staffManagement
    
    private enum SheetType {
        case staffManagement
        case customerManagement
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            AppIconView()
            HStack{
                Text("FAQ")
                Spacer()
            }
            .padding(.top)
            .padding(.leading)
            .frame(maxWidth:.infinity)
            .contentShape(Rectangle())
            .onTapGesture {
//                openURL(URL(string:"https://arcane-3b5c3.web.app/terms-of-condition")!)
                viewRouter.sideMenuState = .isHidden
            }
            HStack{
                Text("About us")
                Spacer()
            }
            .padding(.top)
            .padding(.leading)
            .frame(maxWidth:.infinity)
            .contentShape(Rectangle())
            .onTapGesture {
//                openURL(URL(string:"https://arcane-3b5c3.web.app/terms-of-condition")!)
                viewRouter.sideMenuState = .isHidden
            }
//            Divider()
            // 利用規約
            HStack{
                Text("term of service")
                Spacer()
            }
            .padding(.top)
            .padding(.leading)
            .frame(maxWidth:.infinity)
            .contentShape(Rectangle())
            .onTapGesture {
//                openURL(URL(string:"https://arcane-3b5c3.web.app/terms-of-condition")!)
                viewRouter.sideMenuState = .isHidden
            }
            
            
            // プライバシーポリシー
            HStack {
//                Image(systemName: "lock.fill")
//                    .imageScale(.large)
//                    .frame(width: 32, height: 32)
                Text("privacy policy")
                Spacer()
            }
            .padding(.top)
            .padding(.leading)
            .frame(maxWidth:.infinity)
            .contentShape(Rectangle())
            .onTapGesture {
//                openURL(URL(string:"https://arcane-3b5c3.web.app/privacy-policy")!)
                
                viewRouter.sideMenuState = .isHidden
            }
            
            // contact
//            HStack {
////                Image(systemName: "phone.fill")
////                    .imageScale(.large)
////                    .frame(width: 32, height: 32)
//                Text("contact us")
////                    .font(.headline)
//                Spacer()
//            }
//            .padding(.top)
//            .padding(.leading)
//            .frame(maxWidth:.infinity)
//            .contentShape(Rectangle())
//            .onTapGesture {
//                openURL(URL(string:"https://twitter.com/Arcane_tweet")!)
//
//                viewRouter.sideMenuState = .isHidden
//            }
            
            // staff management
            if viewRouter.loginUserType == .staff{
                HStack {
//                    Image(systemName: "gearshape.fill")
//                        .imageScale(.large)
//                        .frame(width: 32, height: 32)
                    Text("スタッフ管理")
//                        .font(.headline)
                    Spacer()
                }
                .padding(.top)
                .padding(.leading)
                .frame(maxWidth:.infinity)
                .contentShape(Rectangle())
                .onTapGesture {
                    sheetType = .staffManagement
                    showSheet.toggle()
                }
            }
            
            if viewRouter.loginUserType == .staff{
                HStack {
//                    Image(systemName: "gearshape.fill")
//                        .imageScale(.large)
//                        .frame(width: 32, height: 32)
                    Text("顧客管理")
//                        .font(.headline)
                    Spacer()
                }
                .padding(.top)
                .padding(.leading)
                .frame(maxWidth:.infinity)
                .contentShape(Rectangle())
                .onTapGesture {
                    sheetType = .customerManagement
                    showSheet.toggle()
                }
            }
            
            Group{
                Divider()
                
                HStack{
                    Spacer()
                    Image("icon_twitter")
                        .resizable()
                        .frame(width: 24, height: 24)
                    Spacer()
                    Image("icon_facebook")
                        .resizable()
                        .frame(width: 24, height: 24)
                    Spacer()
                    Image("icon_instagram")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .onTapGesture {
                            openURL(URL(string:"https://www.instagram.com/rebuildtokyo/")!)
                            
                            viewRouter.sideMenuState = .isHidden
                        }
                    Spacer()
                }
                .padding(.top)
                .padding(.bottom)
                
            }
            .padding(.top)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.white))
        .edgesIgnoringSafeArea(.all)
        .sheet(isPresented: $showSheet, content: {
            switch sheetType{
                case .staffManagement:StaffListView()
                case .customerManagement:CustomerListView()
            }
            
        })
    }
}

struct AppIconView: View {
    var body : some View {
        HStack{
            Spacer()
            Image("headerIcon")
                .resizable()
                .scaledToFit()
                .frame(width: 100.0, height: 50.0)
//            Image("LaunchScreen")
//                .resizable()
//                .scaleEffect(1.5)
//                .frame(width: 100, height: 100)
//                .clipShape(Circle())
//                .overlay(
//                    Circle().stroke(Color.white, lineWidth: 4))
//                .shadow(radius: 10)
//                .padding(.top)
            Spacer()
        }
        .padding(.top)
        .padding(.top)
        .padding(.top)
    }
}


struct SideMenuView_Previews: PreviewProvider {
    static var previews: some View {
        SideMenuView().environmentObject(ViewRouter())
    }
}
