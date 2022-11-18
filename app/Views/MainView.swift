//
//  MainView.swift
//  ProtoTypeApp
//
//  Created by 高木一弘 on 2021/06/09.
//

import SwiftUI

struct MainView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var viewRouter : ViewRouter
    @EnvironmentObject var firestoreData : FirestoreDataRepository
    @State private var selectedTab  = 1
    
//    let staffList = StaffDao.getAll()
    @State private var selectedStaff : Staff?
    
    var body: some View {
            GeometryReader { geometry in
            
            ZStack (alignment: .top) {
                NavigationView{
                    VStack{
                        ZStack{
                            Image("headerBackground")
                            VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/){
                                Text(selectedTab == 0 ? "Confirm your trainig" : "Reserve your trainig")
                                    .foregroundColor(.white)
                                
                                if(connected_environment != "PROD"){
                                    Text(connected_environment)
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .padding(.top)
                        if viewRouter.loginUserType == .customer {
                            
                            TabView(selection:$selectedTab) {
                                
                                
                                ReservationSummaryView()
                                    .environmentObject(firestoreData)
                                    .environmentObject(viewRouter)
                                    .tabItem {
                                        VStack{
                                            Image(systemName: "person")
                                            Text("STATUS")
                                        }
                                    }.tag(0)
                                
                                
                                CustomerCalendarView(selectedStaff: self.$selectedStaff)
                                    .environmentObject(viewRouter)
                                    .environmentObject(firestoreData)
                                    .tabItem {
                                        VStack{
                                            Image(systemName: "calendar")
                                            Text("RESERVE")
                                        }
                                    }.tag(1)
                                
                                
                                
                                
                            }
                            .accentColor(ColorManager.accentOrage)
//                            .disabled(viewRouter.sideMenuState == .isVisible ? true : false)
                            .tabViewStyle(DefaultTabViewStyle())
                            .navigationBarTitleDisplayMode(.inline)
                            .navigationBarItems(
                                leading:
                                    Button(
                                        action:{
                                            withAnimation {
                                                viewRouter.sideMenuState = .isVisible
                                            }
                                        }){
                                        Image(systemName: "line.horizontal.3")
                                            .imageScale(.large)
                                    }
                            )
                            
                        }
                        else{
                            CalendarView()
                                .environmentObject(viewRouter)
                                .environmentObject(firestoreData)
                                .navigationBarTitleDisplayMode(.inline)
                                .navigationBarItems(
                                    leading:
                                        Button(
                                            action:{
                                                withAnimation {
                                                    viewRouter.sideMenuState = .isVisible
                                                }
                                            }){
                                            Image(systemName: "line.horizontal.3")
                                                .imageScale(.large)
                                        }
                                )
                        }
                        Spacer()
                    }
                }
                
                Image(colorScheme == .dark ? "headerIcon_dark" : "headerIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100.0, height: 50.0)
                
                if viewRouter.sideMenuState == .isVisible {
                    ZStack(alignment:.leading){
                        Rectangle()
                            .fill(ColorManager.fogMask)
                            .edgesIgnoringSafeArea(.top)
                            .edgesIgnoringSafeArea(.bottom)
                            .opacity(0.6)
                            .blur(radius: 10.0)
                            .onTapGesture {
                                viewRouter.sideMenuState = .isHidden
                            }
                        
                        SideMenuView()
                            .environmentObject(firestoreData)
                            .environmentObject(viewRouter)
                            .frame(width: geometry.size.width*2/3)
                            .transition(.move(edge:.leading))
                            .opacity(1)
                            
                    }
                }
            }
        }
    }
}

struct CustomerCalendarView : View {
    
    @Binding var selectedStaff : Staff?
    @EnvironmentObject var viewRouter : ViewRouter
    @EnvironmentObject var firestoreData : FirestoreDataRepository
    
    var body: some View {
        
        VStack {
            NavigationLink(destination: StaffPickerView(selectedStaff: $selectedStaff)){
                ZStack(alignment:.center){
                    
                    Rectangle()
                        .fill(ColorManager.darkOrage)
                        .frame(height: 40)
                    
                    Text(selectedStaff?.name ?? "select your trainer")
                        .frame(height: 40)
                        .foregroundColor(.white)
                }
            }
            .onAppear{
                if viewRouter.selectedStaffId.isEmpty{
                    selectedStaff = nil
                }
            }
            .padding()
            
            
            CalendarView()
                .environmentObject(viewRouter)
                .environmentObject(firestoreData)
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(
                    leading:
                        Button(
                            action:{
                                withAnimation {
                                    viewRouter.sideMenuState = .isVisible
                                }
                            }){
                            Image(systemName: "line.horizontal.3")
                                .imageScale(.large)
                        }
                )
        }
    }
}


struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView().environmentObject(ViewRouter())
    }
}
