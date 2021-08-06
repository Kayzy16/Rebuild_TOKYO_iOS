//
//  StaffListView.swift
//  ProtoTypeApp
//
//  Created by 高木一弘 on 2021/06/15.
//

import SwiftUI
import RealmSwift

struct StaffListView: View {
    
//    @ObservedObject private var staffList = StaffViewModel()
    @EnvironmentObject var firestoreData : FirestoreDataRepository
    @State private var showCreateSheet = false
    @State var staffList :[Staff] = []
    
    
    var body: some View {
        NavigationView{
            ZStack {
                Form {
                    List{
                        ForEach(self.staffList,id:\.id){(stff : Staff) in
                            if stff.isInvalidated {
                                EmptyView()
                            }
                            else{
                                NavigationLink(
                                    destination:EditStaffView(staff: stff)
                                        .onDisappear{
                                            self.staffList = firestoreData.staff.entities
                                        }
                                ){
                                    ListRowStaff(staff:stff).contentShape(Rectangle())
                                }
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                    .frame(height:480)
                    .sheet(isPresented: $showCreateSheet, onDismiss: {
                            staffList = firestoreData.staff.entities
                    }, content: {CreateStaffView(isPresented:$showCreateSheet)})
                    
                }
                FAB(tapped: $showCreateSheet)
            }
            
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("スタッフを管理")
        }
        .onAppear{
            self.staffList = firestoreData.staff.entities
        }
        
    }
    
//    private func initStaffList(){
//        let list = firestoreData.staff.entities
//        self.staffList = list
//    }
}

struct StaffListView_Previews: PreviewProvider {
    static var previews: some View {
        StaffListView()
    }
}
