//
//  CalendarTimeAxis.swift
//  ProtoTypeApp
//
//  Created by 高木一弘 on 2021/06/13.
//

import SwiftUI

struct CalendarTimeAxis: View {
    
    var body: some View {
        VStack{
            ForEach(0..<maxLessonNum()) { i in
                CalendarTimeLabel(startTime: lessonStartTime(index: i), endTime:lessonEndTime(index: i))
            }
        }
    }
}

struct CalendarTimeAxis_Previews: PreviewProvider {
    static var previews: some View {
        CalendarTimeAxis()
    }
}
