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
        case WeekDay.sunday.rawValue : return "日"
        case WeekDay.monday.rawValue : return "月"
        case WeekDay.tuesday.rawValue : return "火"
        case WeekDay.wednesday.rawValue : return "水"
        case WeekDay.thursday.rawValue : return "木"
        case WeekDay.friday.rawValue : return "金"
        case WeekDay.saturday.rawValue : return "土"
        
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
