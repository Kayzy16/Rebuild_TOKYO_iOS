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
    
    init(day:Date){
        self.day = day
        
        
        
        let f = DateFormatter()
        f.timeStyle = .long
        f.dateStyle = .long
        f.locale = Locale(identifier: "ja_JP")
        
        
        print("----------- self.day  -------------")
        print(f.string(from: self.day))
        print("----------- startTime  -------------")
        print(f.string(from: lessonStartTime(d: self.day, index: 0)))
        print(f.string(from: lessonStartTime(d: self.day, index: 1)))
        print(f.string(from: lessonStartTime(d: self.day, index: 2)))
        print(f.string(from: lessonStartTime(d: self.day, index: 3)))
        print(f.string(from: lessonStartTime(d: self.day, index: 4)))
        print("------------------------")
    }
    
    var body: some View {
        VStack() {
            ForEach(0..<maxLessonNum()) { i in
                EventFrameView(date: day, startTime: lessonStartTime(d: day, index: i),startTimeLabel: lessonStartTime(index: i), endTimeLabel:lessonEndTime(index: i))
                    .padding(.bottom)
            }
        }
    }
}

struct CalendarDayView_Previews: PreviewProvider {
    static var previews: some View {
        let d = Date()
        CalendarDayView(day : d).environmentObject(ViewRouter())
    }
}
