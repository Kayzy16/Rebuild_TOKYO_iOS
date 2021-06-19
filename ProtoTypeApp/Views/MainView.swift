//
//  MainView.swift
//  ProtoTypeApp
//
//  Created by 高木一弘 on 2021/06/09.
//

import SwiftUI

struct MainView: View {
    
    @EnvironmentObject var viewRouter : ViewRouter
    
    let staffList = StaffDao.getAll()
    @State private var selectedStaff : Staff?
    
    var body: some View {
//        let drag = DragGesture()
//            .onEnded {
//                if $0.translation.width < -100 {
//                    withAnimation{
//                        viewRouter.sideMenuState = .isHidden
//                    }
//                }
//
//                if $0.translation.width > 100 {
//                    withAnimation{
//                        viewRouter.sideMenuState = .isVisible
//                    }
//                }
//            }
//        return
            GeometryReader { geometry in
            
            ZStack (alignment: .top) {
                NavigationView{
                    VStack{
                        ZStack{
                            Image("headerBackground")
                            VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/){
                                Text("Reserve your lesson")
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.top)
                        
                        if viewRouter.loginUserType == .customer {
                            NavigationLink(destination: StaffPickerView(selectedStaff: $selectedStaff)){
                                ZStack(alignment:.center){
                                    
                                    Rectangle()
                                        .fill(ColorManager.darkOrage)
                                        .frame(height: 40)
                                    
                                    Text(selectedStaff?.name ?? "select your instructor")
                                        .frame(height: 40)
                                        .foregroundColor(.white)
                                }
                            }
                            .padding()
                        }
                        else{
                            EmptyView()
                        }
                        
                        
                        CalendarView()
                            .environmentObject(viewRouter)
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
                        Spacer()
                    }
                }
                
                Image("headerIcon")
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
                            .frame(width: geometry.size.width*2/3)
                            .transition(.move(edge:.leading))
                            .opacity(1)
                    }
                }
            }
//            .gesture(drag)
            
        }
        
        
    }
    
    private func isStaff() -> Bool {
        if viewRouter.loginUserType == .staff {
            return true
        }
        else{
            return false
        }
    }
}

struct MainView_Previews: PreviewProvider {

    static var previews: some View {


        MainView().environmentObject(ViewRouter())
    }
}
