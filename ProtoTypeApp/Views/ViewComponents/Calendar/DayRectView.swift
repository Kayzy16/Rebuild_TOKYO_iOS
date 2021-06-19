//
//  DayRectView.swift
//  ProtoTypeApp
//
//  Created by 高木一弘 on 2021/06/12.
//

import SwiftUI

struct DayRectView: View {
    
    var month   : Int
    var day     : Int
    var weekDay : Int
    
    init(day:Date){
        self.month = getMonthInt(from: day)
        self.day   = getDayInt(from: day)
        self.weekDay = getWeekDayInt(from: day)
    }
    
    var body: some View {
        HStack {
            Text(String(month) + "/" + String(day))
                .foregroundColor(.white)
            Text(getWeekDaylabel(weekDay: self.weekDay))
                .foregroundColor(.white)
        }
        .frame(width:day_rect_width,height: day_rect_height)
        .background(isToday() ? ColorManager.accentOrage : ColorManager.accentNavy)
    }
    
    public func isToday() -> Bool {
        let today = Date()
        let calendar = Calendar(identifier: .gregorian)
        let thisYear = calendar.component(.year, from: today)
        
        let labeledDate = calendar.date(from: DateComponents(year: thisYear, month: self.month, day: self.day))!
        
        return calendar.isDateInToday(labeledDate)
    }
    
    private func getWeekDaylabel(weekDay : Int) -> String {
        switch weekDay {
        case WeekDay.sunday.rawValue : return "Sun"
        case WeekDay.monday.rawValue : return "Mon"
        case WeekDay.tuesday.rawValue : return "Tue"
        case WeekDay.wednesday.rawValue : return "Wed"
        case WeekDay.thursday.rawValue : return "Thu"
        case WeekDay.friday.rawValue : return "Fri"
        case WeekDay.saturday.rawValue : return "Sat"
        
        default:
            return "err"
        }
    }
}

struct DayRectView_Previews: PreviewProvider {
    static var previews: some View {
        DayRectView(day:Date())
    }
}
