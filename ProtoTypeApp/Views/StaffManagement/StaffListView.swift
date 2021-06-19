//
//  StaffListView.swift
//  ProtoTypeApp
//
//  Created by 高木一弘 on 2021/06/15.
//

import SwiftUI
import RealmSwift

struct StaffListView: View {
    
    @ObservedObject private var staffList = StaffViewModel()
    @State private var showCreateSheet = false
    
    var body: some View {
        NavigationView{
            ZStack {
                Form {
                    List{
                        ForEach(staffList.entities,id:\.id){(stff : Staff) in
                            if stff.isInvalidated {
                                EmptyView()
                            }
                            else{
                                NavigationLink(destination:EditStaffView(staff: stff)){
                                    ListRowStaff(staff:stff)
                                        .contentShape(Rectangle())
                                }
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                    .frame(height:480)
                    .sheet(isPresented: $showCreateSheet, content: {CreateStaffView(isPresented:$showCreateSheet)})
                }
                FAB(tapped: $showCreateSheet)
            }
            
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("スタッフを管理")
        }
        
    }
}

struct StaffListView_Previews: PreviewProvider {
    static var previews: some View {
        StaffListView()
    }
}
