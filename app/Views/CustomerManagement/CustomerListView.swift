//
//  CustomerListView.swift
//  app
//
//  Created by 高木一弘 on 2021/08/02.
//

import SwiftUI

struct CustomerListView: View {
    @EnvironmentObject var firestoreData : FirestoreDataRepository
    @State private var showCreateSheet = false
    @State var customerList :[Customer] = []
    
    
    var body: some View {
        NavigationView{
            ZStack {
                Form {
                    List{
                        ForEach(self.customerList,id:\.id){(cus : Customer) in
                            if cus.isInvalidated || cus.deleteFlg == 1{
                                EmptyView()
                            }
                            else{
                                NavigationLink(
                                    destination:EditCustomerView(cstmr: cus)
                                        .onDisappear{
                                            self.customerList = firestoreData.customer.entities                                            
                                        }
                                ){
                                    ListRowCustomer(with:cus)
                                        .contentShape(Rectangle())
                                }
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                    .frame(height:480)
                    .sheet(isPresented: $showCreateSheet, onDismiss: {
                            customerList = firestoreData.customer.entities}, content: {CreateCustomerView(isPresented:$showCreateSheet)})
                    
                }
                FAB(tapped: $showCreateSheet)
            }
            
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("顧客管理")
        }
        .onAppear{
            self.customerList = firestoreData.customer.entities
        }
        
    }

}

struct CustomerListView_Previews: PreviewProvider {
    static var previews: some View {
        CustomerListView()
    }
}
