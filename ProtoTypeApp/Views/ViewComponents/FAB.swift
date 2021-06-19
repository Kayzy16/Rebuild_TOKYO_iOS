//
//  FAB.swift
//  ProtoTypeApp
//
//  Created by 高木一弘 on 2021/06/15.
//

import Foundation
import SwiftUI

struct FAB: View {
    @Binding var tapped : Bool
    
    var body: some View {
        ZStack(alignment: .bottomTrailing){
            Rectangle()
                .foregroundColor(.clear)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            
            Button(action: {
                self.tapped.toggle()
            }){
                
                ZStack{
                    Circle()
                        .fill(ColorManager.accentOrage)
                        .frame(width:60,height:60)
                        .shadow(radius: 5, x: 5, y: 5)
                    
                    
                    Image(systemName: "plus")
                        .foregroundColor(.white)
                    
                }
            }
            .padding(CGFloat(24))
        }
    }
}

struct FAB_Previews: PreviewProvider {
    static var previews: some View {
        FAB(tapped: .constant(false))
    }
}
