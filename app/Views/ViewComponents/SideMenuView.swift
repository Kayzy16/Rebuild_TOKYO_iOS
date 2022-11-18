//
//  SideMenuView.swift
//  ProtoTypeApp
//
//  Created by 高木一弘 on 2021/06/10.
//

import SwiftUI

struct SideMenuView: View {
    
    @Environment(\.openURL) var openURL
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var viewRouter: ViewRouter
    @EnvironmentObject var firestoreData : FirestoreDataRepository
    @State private var showSheet : Bool = false
    
    @State private var sheetType : SheetType = .staffManagement
    
    private enum SheetType {
        case staffManagement
        case customerManagement
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            AppIconView()
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
                openURL(URL(string:"https://rebuild-tokyo.com/aplicationterm/")!)
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
                openURL(URL(string:"https://rebuild-tokyo.com/privacypolicy/")!)
                
                viewRouter.sideMenuState = .isHidden
            }
            
            
            // staff management
            if viewRouter.loginUserType != .customer{
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
            
            if viewRouter.loginUserType != .customer{
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
//                    Spacer()
//                    Image("icon_twitter")
//                        .resizable()
//                        .frame(width: 24, height: 24)
//                    Spacer()
//                    Image("icon_facebook")
//                        .resizable()
//                        .frame(width: 24, height: 24)
                    Spacer()
                    Image(colorScheme == .dark ? "icon_instagram_dark" : "icon_instagram")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .onTapGesture {
                            openURL(URL(string:"https://www.instagram.com/rebuildtokyo/")!)
                            
                            viewRouter.sideMenuState = .isHidden
                        }
                    Spacer()
                }
                
            }
            .padding(.top)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(ColorManager.backGroundMain)
        .edgesIgnoringSafeArea(.all)
        .sheet(isPresented: $showSheet, content: {
            switch sheetType{
                case .staffManagement:StaffListView().environmentObject(firestoreData)
                case .customerManagement:CustomerListView()
            }
            
        })
    }
}

struct AppIconView: View {
    @Environment(\.colorScheme) var colorScheme
    var body : some View {
        HStack{
            Spacer()
            Image(colorScheme == .dark ? "headerIcon_dark" : "headerIcon")
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
