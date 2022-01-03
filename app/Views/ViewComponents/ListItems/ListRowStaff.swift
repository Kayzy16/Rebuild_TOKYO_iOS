//
//  ListRowStaff.swift
//  ProtoTypeApp
//
//  Created by 高木一弘 on 2021/06/15.
//

import SwiftUI

struct ListRowStaff: View {
    private var staff : Staff
    
    init(staff:Staff){
        self.staff = staff
    }
    
    var body: some View {
        HStack {
            Text(staff.name)
            Spacer()
        }
        .frame(maxWidth:.infinity)
        .contentShape(Rectangle())
    }
}
