//
//  CalenderUtilities.swift
//  JSDatePickerView
//
//  Created by Jesse Seidman on 12/28/17.
//  Copyright © 2017 Jesse Seidman. All rights reserved.
//

import UIKit

//This enum holds month/day data that is used in the calendar
enum MonthEnum: Int, CustomStringConvertible
{
    //months with raw values
    case January = 1, February, March, April, May, June, July, August, September, October, November, December
    
    public static func getDays(month:MonthEnum) -> Int
    {
        var days = 0
        
        //30 Days has September...
        switch month
        {
        case .September:
            fallthrough
        case .April:
            fallthrough
        case .June:
            fallthrough
        case .November:
            days = 30
        case .February:
            let dateComponents = Calendar.current.dateComponents(in: .current, from: Date())
            let year           = dateComponents.year
            if let year = year
            {
                if isLeapYear(year) { days = 29 }
                else {days = 28}
            }
        default:
            days = 31
        }
        
        return days
    }
    
    //PRIVATE FUNCTIONS
    
    //Leap year functions used for figuring out the dayes in february
    private static func isLeapYear(_ year: Int) -> Bool
    {
        return ((year % 4 == 0) && (year % 100 != 0) || (year % 400 == 0))
    }
    
    //PUBLIC FUNCTIONS
    
    public static func getPreviousMonth(month:MonthEnum) -> MonthEnum
    {
        return month.rawValue == 1 ? .December : MonthEnum.init(rawValue: month.rawValue - 1)!
    }
    
    //CustomStringConvertible variable
    var description: String
    {
        var desc = ""
        
        switch self
        {
            case .January:
                desc = "January"
            case .February:
                desc = "February"
            case .March:
                desc = "March"
            case .April:
                desc = "April"
            case .May:
                desc = "May"
            case .June:
                desc = "June"
            case .July:
                desc = "July"
            case .August:
                desc = "August"
            case .September:
                desc = "September"
            case .October:
                desc = "October"
            case .November:
                desc = "November"
            case .December:
                desc = "December"
        }
        return desc
    }
}

enum DayEnum: Int, CustomStringConvertible
{
    case Sunday = 1, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday
    
    var description: String
    {
        var desc = ""
        
        switch self
        {
            case .Sunday:
                desc = "Sunday"
            case .Monday:
                desc = "Monday"
            case .Tuesday:
                desc = "Tuesday"
            case .Wednesday:
                desc = "Wednesday"
            case .Thursday:
                desc = "Thursday"
            case .Friday:
                desc = "Friday"
            case .Saturday:
                desc = "Saturday"
        }
        return desc
    }
}

//this struct holds the data for the collection view cells
//the variable are nullable because there could either be date data or just day labels
struct CalendarDay
{
    public var day       : DayEnum?
    public var month     : MonthEnum?
    public var dayNumber : Int?
    public var year      : Int?
    public var labelText : String?
    public var grayed    : Bool
}

class CalendarUtil:NSObject
{
    public static func getCalendarData(for date: Date) -> [CalendarDay]
    {
        var dataArray = [CalendarDay]()
        
        //add the day labels first
        for i in 1...7 { dataArray.append(CalendarDay(day: nil,
                                                      month: nil,
                                                      dayNumber: nil,
                                                      year: nil,
                                                      labelText: DayEnum(rawValue: i)?.description,
                                                      grayed:false))}

        //get date components from given date
        let components = Calendar.current.dateComponents([.month,.day,.year], from: date)
        
        //get first day of the month date
        var currDate = getFirstOfMonth(components)

        //roll back to first previous sunday (if applicable)
        while !isTodaySunday(currDate)
        {
            currDate = Calendar.current.date(byAdding: .day, value: -1, to: currDate)!
        }

        //roll forward from the sunday until the last of the month
        while currDate <= getLastOfMonth(components)
        {
            //get date components of current date
            let components = Calendar.current.dateComponents([.month, .weekday, .day, .year], from: currDate)
            
            //append the date to the date array
            dataArray.append(CalendarDay(day: DayEnum(rawValue: components.weekday!),
                                         month: MonthEnum(rawValue: components.month!),
                                         dayNumber: components.day,
                                         year: components.year,
                                         labelText: nil,
                                         grayed: components.month != Calendar.current.dateComponents([.month], from: date).month))
            
            //increment
            if let nextDate = Calendar.current.date(byAdding: .day, value: 1, to: currDate)
            {
                currDate = nextDate
            }
            else { break }
        }
        
        //go until just before the last saturday
        while(Calendar.current.dateComponents([.weekday], from: currDate).weekday != DayEnum.Sunday.rawValue)
        {
            //get current date components
            let components = Calendar.current.dateComponents([.month, .weekday, .day, .year], from: currDate)
            
            //append the date
            dataArray.append(CalendarDay(day: DayEnum(rawValue: components.weekday!),
                                         month: MonthEnum(rawValue: components.month!),
                                         dayNumber: components.day,
                                         year: components.year,
                                         labelText: nil,
                                         grayed:true))
            
            //increment
            if let nextDate = Calendar.current.date(byAdding: .day, value: 1, to: currDate)
            {
                currDate = nextDate
            }
            else { break }
        }
        
        return dataArray
    }
    
    //check if the given day is a sunday
    private static func isTodaySunday(_ date : Date) -> Bool
    {
        let components = Calendar.current.dateComponents([.weekday], from: date)
        let weekDay = components.weekday
        
        return weekDay == 1
    }
    
    //get the first of the month for the given components
    private static func getFirstOfMonth(_ components: DateComponents) -> Date
    {
        var newComponents = components
        newComponents.day = 1
        
        return Calendar.current.date(from: newComponents)!
    }
    
    //get the last of the month from the given components
    private static func getLastOfMonth(_ components: DateComponents) -> Date
    {
        var newComponents = components
        
        if let monthRaw = components.month
        {
            if let month = MonthEnum(rawValue: monthRaw)
            {
                newComponents.day = MonthEnum.getDays(month: month)
            }
        }
        
        return Calendar.current.date(from: newComponents)!
    }
}
