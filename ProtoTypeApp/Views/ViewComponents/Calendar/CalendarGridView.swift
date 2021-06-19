//
//  CalendarGridView.swift
//  ProtoTypeApp
//
//  Created by 高木一弘 on 2021/06/11.
//

import SwiftUI

struct CalendarGridView: View {
    
    let weekStartDay : Date
    @EnvironmentObject var viewRouter: ViewRouter
    
    var body: some View {
        
        VStack{
            HStack{
                ForEach(0..<3){i in
                    DayRectView(day: getFutureDate(from: weekStartDay, offset: i))
                }
            }
            
            ScrollView(.vertical, showsIndicators: false, content: {
                HStack{
                    ForEach(0..<3){ i in
                        CalendarDayView(day: getFutureDate(from: weekStartDay, offset: i))
                    }
                }
            })
        }
    }
}

struct CalendarGridView_Previews: PreviewProvider {
    static var previews: some View {
        let d = Date()
        CalendarGridView(weekStartDay: d).environmentObject(ViewRouter())
    }
}
