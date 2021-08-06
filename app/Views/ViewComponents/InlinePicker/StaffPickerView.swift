//
//  StaffPickerView.swift
//  ProtoTypeApp
//
//  Created by 高木一弘 on 2021/06/15.
//

import SwiftUI

struct StaffPickerView: View {
    
    @EnvironmentObject var firestoreData : FirestoreDataRepository
    
    @State var staffList : [Staff] = []
    @Binding var selectedStaff : Staff?
    @EnvironmentObject var viewRouter: ViewRouter
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        List {
            ForEach(staffList,id:\.id) { (stff : Staff) in
                if stff.isInvalidated{
                    EmptyView()
                }
                else{
                    ListRowStaff(staff: stff)
                        .onTapGesture {
                            self.selectedStaff = stff
                            viewRouter.selectedStaffId = stff.id
                            self.presentationMode.wrappedValue.dismiss()
                        }
                }
            }
        }
        .onAppear{
            staffList  = firestoreData.staff.entities
        }
    }
    
}
