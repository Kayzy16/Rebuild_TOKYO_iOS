//
//  ListRowCustomer.swift
//  app
//
//  Created by 高木一弘 on 2021/08/02.
//

import SwiftUI

struct ListRowCustomer: View {
    private var customer : Customer
    
    init(with:Customer){
        self.customer = with
    }
    
    var body: some View {
        Text(customer.name)
    }
}
