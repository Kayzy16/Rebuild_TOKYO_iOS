//
//  ListRowAuthLevel.swift
//  app
//
//  Created by 高木一弘 on 2022/02/26.
//

import SwiftUI

import SwiftUI

struct ListRowAuthLevel: View {
    private var authLevel : AuthLevel
    
    init(authLevel:AuthLevel){
        self.authLevel = authLevel
    }
    
    var body: some View {
        Text(authLevel.name)
    }
}
