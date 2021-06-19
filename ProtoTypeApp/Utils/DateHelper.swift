//
//  DateHelper.swift
//  ProtoTypeApp
//
//  Created by 高木一弘 on 2021/06/13.
//

import Foundation


public func getFormatedDate(from:Date) -> String{
    let f = DateFormatter()
    f.timeStyle = .none
    f.dateStyle = .short
    f.locale = Locale(identifier: "ja_JP")
    return f.string(from: from)
}

public func getFormatedTime(from:Date) -> String{
    let f = DateFormatter()
    f.timeStyle = .short
    f.dateStyle = .none
    f.locale = Locale(identifier: "ja_JP")
    return f.string(from: from)
}

public func getYearInt(from : Date) -> Int {
    let calendar = Calendar(identifier: .gregorian)
    let thisYear = calendar.component(.year, from: from)
    return thisYear
}

public func getMonthInt(from : Date) -> Int {
    let calendar = Calendar(identifier: .gregorian)
    let month = calendar.component(.month, from: from)
    return month
}


public func getDayInt(from : Date) -> Int {
    let calendar = Calendar(identifier: .gregorian)
    let day = calendar.component(.day, from: from)
    return day
}

public func getWeekDayInt(from : Date) -> Int {
    let calendar = Calendar(identifier: .gregorian)
    let day = calendar.component(.weekday, from: from)
    return day
}

public func maxLessonNum() -> Int {
//    let n = (business_end - business_start + (lesson_rest_length/60)) / ((lesson_length/60) + (lesson_rest_length/60))
    
    let business_open_minute = (business_end - business_start)*60
    let lesson_term_num = (business_open_minute + lesson_rest_length) / (lesson_length+lesson_rest_length)
    return Int(lesson_term_num)
}

public func lessonStartTime(index:Int) -> String{
    
    let calendar = Calendar(identifier: .gregorian)
    let date = calendar.date(from: DateComponents(hour: business_start))!
    let modifiedDate = Calendar.current.date(byAdding:.minute,value:(lesson_length+lesson_rest_length)*index,to:date)!
    
    let f = DateFormatter()
    f.timeStyle = .short
    f.dateStyle = .none
    f.locale = Locale(identifier: "ja_JP")
    return f.string(from: modifiedDate)
}

public func lessonStartTime(d:Date,index:Int) -> Date{
    let calendar = Calendar(identifier: .gregorian)
    let date = calendar.date(from: DateComponents(year:getYearInt(from: d),month:getMonthInt(from: d),day:getDayInt(from: d),hour: business_start,minute: 0,second: 0,nanosecond: 0))!
    let modifiedDate = Calendar.current.date(byAdding:.minute,value:(lesson_length+lesson_rest_length)*index,to:date)!
    
    return modifiedDate
}
public func lessonEndTime(index:Int) -> String{
    let calendar = Calendar(identifier: .gregorian)
    let date = calendar.date(from: DateComponents(hour: business_start))!
    let modifiedDate = Calendar.current.date(byAdding:.minute,value:lesson_length+(lesson_length+lesson_rest_length)*index,to:date)!
    
    let f = DateFormatter()
    f.timeStyle = .short
    f.dateStyle = .none
    f.locale = Locale(identifier: "ja_JP")
    return f.string(from: modifiedDate)
}

public func lessonEndTime(d:Date,index:Int) -> Date{
    let calendar = Calendar(identifier: .gregorian)
    let date = calendar.date(from: DateComponents(year:getYearInt(from: d),month:getMonthInt(from: d),day:getDayInt(from: d),hour: business_start,minute: 0,second: 0,nanosecond: 0))!
    let modifiedDate = Calendar.current.date(byAdding:.minute,value:lesson_length+(lesson_length+lesson_rest_length)*index,to:date)!
    return modifiedDate
}

public func getNext3Day(from:Date) -> Date {
    let calendar = Calendar(identifier: .gregorian)
    let date = calendar.date(from: DateComponents(year:getYearInt(from: from),month:getMonthInt(from: from),day:getDayInt(from: from),hour:0,minute:0,second: 0,nanosecond: 0))!
    
    return Calendar.current.date(byAdding: .day, value: 3, to: date)!
}
public func getLast3Day(from:Date) -> Date {
    let calendar = Calendar(identifier: .gregorian)
    let date = calendar.date(from: DateComponents(year:getYearInt(from: from),month:getMonthInt(from: from),day:getDayInt(from: from),hour:0,minute:0,second: 0,nanosecond: 0))!
    
    return Calendar.current.date(byAdding: .day, value: -3, to: date)!
}

public func getLastWeedStartDay(from:Date) -> Date {
    let calendar = Calendar(identifier: .gregorian)
    let date = calendar.date(from: DateComponents(year:getYearInt(from: from),month:getMonthInt(from: from),day:getDayInt(from: from),hour:0,minute:0,second: 0,nanosecond: 0))!
    
    return Calendar.current.date(byAdding: .day, value: -7, to: date)!
}

public func getNextWeedStartDay(from:Date) -> Date {
    let calendar = Calendar(identifier: .gregorian)
    let date = calendar.date(from: DateComponents(year:getYearInt(from: from),month:getMonthInt(from: from),day:getDayInt(from: from),hour:0,minute:0,second: 0,nanosecond: 0))!
    
    return Calendar.current.date(byAdding: .day, value: 7, to: date)!
}

public func getNextDay(from:Date) -> Date {
    return Calendar.current.date(byAdding: .day, value: 1, to: from)!
}
public func getFutureDate(from:Date,offset:Int) -> Date{
    let calendar = Calendar(identifier: .gregorian)
    let date = calendar.date(from: DateComponents(year:getYearInt(from: from),month:getMonthInt(from: from),day:getDayInt(from: from),hour:0,minute:0,second: 0,nanosecond: 0))!
//    let modifiedDate = Calendar.current.date(byAdding: .day, value: offset, to: date)!
    
//    let date = calendar.date(from: DateComponents(year:getYearInt(from: from),month:getMonthInt(from: from),getDayInt(hour:0,minute:0,second: 0,nanosecond: 0))!
    return Calendar.current.date(byAdding: .day, value: offset, to: date)!
}

public func getDate(y:Int,m:Int,d:Int) -> Date{
    let calendar = Calendar(identifier: .gregorian)
    return calendar.date(from: DateComponents(year:y,month:m,day:d,hour:0,minute:0,second: 0,nanosecond: 0))!
}

public func getNormalizedDate(from:Date) -> Date{
    let calendar = Calendar(identifier: .gregorian)
    let date = calendar.date(from: DateComponents(year:getYearInt(from: from),month:getMonthInt(from: from),day:getDayInt(from: from),hour:0,minute:0,second: 0,nanosecond: 0))!
    return date
}

/**
 現在時間がレッスン開始時間を過ぎている場合true
 */
public func isLessonPassed(startTime:Date) -> Bool{
    let now = Date()
    if(startTime < now){
        return true
    }
    else{
        return false
    }
}
