//
//  AuthPickerView.swift
//  app
//
//  Created by 高木一弘 on 2022/02/26.
//

import SwiftUI

struct AuthPickerView: View {
    
    @EnvironmentObject var firestoreData : FirestoreDataRepository
    
    @State var authLevelList : [AuthLevel] = []
    @Binding var selectedAuthLevel : AuthLevel?
    @EnvironmentObject var viewRouter: ViewRouter

    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        List {
            ForEach(authLevelList,id:\.id) { (auth : AuthLevel) in
                ListRowAuthLevel(authLevel: auth)
                    .onTapGesture {
                        self.selectedAuthLevel = auth
                        print(self.selectedAuthLevel?.name)
                        print(self.selectedAuthLevel?.authLevel)
                        self.presentationMode.wrappedValue.dismiss()
                        
                    }
            }
        }
        .onAppear{
            authLevelList = firestoreData.authLevel.entities
        }
    }
    
}
