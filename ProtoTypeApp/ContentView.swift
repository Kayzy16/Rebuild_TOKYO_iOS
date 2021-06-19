//
//  ContentView.swift
//  ProtoTypeApp
//
//  Created by 高木一弘 on 2021/06/08.
//

import SwiftUI

struct ContentView: View {
    
    @State var currentPage : Page = .auth
    @EnvironmentObject var viewRouter: ViewRouter
    
    var body: some View {
        switch viewRouter.currentPage {
        case .auth:
            LoginView()
        case .calendar:
            MainView()
                .transition(.move(edge: .trailing))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(ViewRouter())
    }
}
