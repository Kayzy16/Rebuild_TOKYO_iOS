//
//  ListRowProgram.swift
//  app
//
//  Created by 高木一弘 on 2021/08/03.
//

import SwiftUI

import SwiftUI

struct ListRowProgram: View {
    private var program : Program
    
    init(program:Program){
        self.program = program
    }
    
    var body: some View {
        Text(program.name)
    }
}
