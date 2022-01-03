//
//  CalendarGridView.swift
//  ProtoTypeApp
//
//  Created by 高木一弘 on 2021/06/11.
//

import SwiftUI

struct CalendarGridView: View {
    
    @Binding var weekStartDay : Date
    @EnvironmentObject var viewRouter: ViewRouter
    @EnvironmentObject var firestoreData : FirestoreDataRepository
    
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
                        CalendarDayView(day: .constant(getFutureDate(from: weekStartDay, offset: i)))
                            .environmentObject(firestoreData)
                    }
                }
                .onAppear{
//                    print(weekStartDay)
                }
            })
        }
    }
}

struct CalendarGridView_Previews: PreviewProvider {
    static var previews: some View {
        let d = Date()
        CalendarGridView(weekStartDay: .constant(d)).environmentObject(ViewRouter())
    }
}
