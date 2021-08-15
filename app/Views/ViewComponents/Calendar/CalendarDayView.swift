//
//  CalendarDayView.swift
//  ProtoTypeApp
//
//  Created by 高木一弘 on 2021/06/13.
//

import SwiftUI

struct CalendarDayView: View {
    var day : Date
    @EnvironmentObject var viewRouter: ViewRouter
    @EnvironmentObject var firestoreData : FirestoreDataRepository
    
    init(day:Date){
        self.day = day
    }
    
    var body: some View {
        HStack {
            VStack() {
                ForEach(0..<maxLessonNum()) { i in
                    EventFrameView(date: day, startTime: lessonStartTime(d: day, index: i),startTimeLabel: lessonStartTime(index: i), endTimeLabel:lessonEndTime(index: i))
                        .padding(.bottom)
                        .environmentObject(firestoreData)
                }
            }
            
//            VStack() {
//                ForEach(0..<maxLessonNum()) { i in
//                    EventFrameView(date: day, startTime: lessonStartTime(d: day, index: i),startTimeLabel: lessonStartTime(index: i), endTimeLabel:lessonEndTime(index: i))
//                        .padding(.bottom)
//                        .environmentObject(firestoreData)
//                }
//            }
        }
        
        
    }
}

struct CalendarDayView_Previews: PreviewProvider {
    static var previews: some View {
        let d = Date()
        CalendarDayView(day : d).environmentObject(ViewRouter())
    }
}
