//
//  CalenderUtilities.swift
//  JSDatePickerView
//
//  Created by Jesse Seidman on 12/28/17.
//  Copyright © 2017 Jesse Seidman. All rights reserved.
//

import UIKit

public protocol DualCollectionViewScrollDelegate
{
  func collectionViewDidScroll(_ collectionView:UICollectionView)
  func collectionViewDidEndScroll(_ collectionView:UICollectionView, withDifferenceOf diff:Int)
  func collectionViewWillBeginDragging(_ collectionView:UICollectionView)
}

public protocol CollectionViewTouchTransferDelegate
{
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
}

//This enum holds month/day data that is used in the calendar
public enum MonthEnum: Int, CustomStringConvertible
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
    public var description: String
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

public enum DayEnum: Int, CustomStringConvertible
{
    case Sunday = 1, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday
    
    public var description: String
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
    
    public static func getSuffix(dayNumber:Int) -> String
    {
        if dayNumber % 10 == 1 && (dayNumber != 11){ return "st" }
        else if dayNumber % 10 == 2 && (dayNumber != 12){ return "nd" }
        else if dayNumber % 10 == 3 && (dayNumber != 13){ return "rd" }
        else {return "th"}
    }
}

//this struct holds the data for the collection view cells
//the variable are nullable because there could either be date data or just day labels
internal struct CalendarDay
{
  public var day       : DayEnum?
  public var month     : MonthEnum?
  public var dayNumber : Int?
  public var year      : Int?
  public var labelText : String?
  public var gray      : GrayType
  public var date      : Date?
}

internal enum GrayType:Equatable
{
  case previousMonth(Int,Bool)
  case nextMonth(Int,Bool)
  case none
  
  static func ==(lhs: GrayType, rhs: GrayType) -> Bool
  {
    switch (lhs, rhs)
    {
      case (let .previousMonth(monthNum, isPrevious), let .previousMonth(monthNum2, isPrevious2)):
        return monthNum == monthNum2 && isPrevious == isPrevious2
      
      case (let .nextMonth(monthNum, isPrevious), let .nextMonth(monthNum2, isPrevious2)):
        return monthNum == monthNum2 && isPrevious == isPrevious2
      
      case (.none, .none):
        return true
      default:
        return false
    }
  }
}

internal class CalendarUtil:NSObject
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
                                                    gray:.none,
                                                    date: nil))}

      //get date components from given date
      let components = Calendar.current.dateComponents([.month,.day,.year], from: date)
      var grayCount = 1;
    
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
                                       gray: components.month != Calendar.current.dateComponents([.month], from: date).month ?
                                                                                                .previousMonth(grayCount,currDate == getLastOfMonth(components)) :
                                                                                                .none,
                                       date: currDate))
        
          // increment gray count
          if components.month != Calendar.current.dateComponents([.month], from: date).month { grayCount += 1}
          else { grayCount = 1 }
        
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
                                       gray:.nextMonth(grayCount,currDate == getFirstOfMonth(components)),
                                       date: currDate))
        
          // increment gray count
          grayCount += 1
        
          //increment
          if let nextDate = Calendar.current.date(byAdding: .day, value: 1, to: currDate)
          {
              currDate = nextDate
          }
          else { break }
      }
    
      return dataArray
  }
  
  public static func rotate(calendarArray:[CalendarDay]) -> [CalendarDay]
  {
    var cal:[CalendarDay] = []
    
    for i in 0..<7
    {
      cal.append(calendarArray[i])
      var j = 0
      for _ in 1..<calendarArray.count / 7
      {
        j += 7
        cal.append(calendarArray[i + j])
      }
    }
    
    return cal
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

extension Date
{
  func getString(from dateString:String) -> String
  {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = dateString
    let strMonth = dateFormatter.string(from: self)
    return strMonth
  }
  
  func getMonth() -> Int
  {
    return Calendar.current.component(.month, from: self)
  }
}
