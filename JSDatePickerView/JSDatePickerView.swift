//
//  JSDatePickerView.swift
//  JSDatePickerView
//
//  Created by Jesse Seidman on 2/14/18.
//  Copyright © 2018 Jesse Seidman. All rights reserved.
//

import UIKit

public protocol JSDatePickerDelegate
{
  func jsDatePicker(_ jsDatePicker:JSDatePickerView, didChangeDateFrom collectionView:UICollectionView)
}

public class JSDatePickerView: UIView,
                        DualCollectionViewScrollDelegate,
                        CollectionViewTouchTransferDelegate
{
  // PRIVATE VARS
  // Bools
  private var datePickerIsScrolling  = false
  private var didSetConstraints      = false
  private var isCalendarExpanded     = false
  private var isFirstTimeExpanding   = true  // for special presentation on the first time
  private var widthGreaterThanHeight = true
  
  // CollectionViews
  public var calendarCV  :CalendarCollectionView!
  private var datePickerCV:DatePickerCollectionView!
  
  // NSLayoutConstraints
  private var dateConstraint = NSLayoutConstraint()
  private var calConstraint  = NSLayoutConstraint()

  // to observe device orientation change
  private var currentOrientation:UIDeviceOrientation = .unknown
  
  // to keep track of changes for closed calendar
  private var changeLog = 0
  
  // PUBLIC GET PRIVATE SET VARS
  public private(set) var calendarIsScrolling   = false
  
  // PUBLIC VARS
  public var datePickerBackgroundColor:UIColor = UIColor.lightGray
  {
    didSet { datePickerCV.backgroundColor = datePickerBackgroundColor }
  }
  public var calendarBackgroundColor:UIColor   = UIColor.white
  {
    didSet { calendarCV.backgroundColor = calendarBackgroundColor }
  }
  public var datePickerHeight:CGFloat = 100.0
  {
    didSet { dateConstraint.constant = datePickerHeight }
  }
  public var calendarHeight:CGFloat = 300.0
  {
    didSet { if didSetConstraints { calConstraint.constant = calendarHeight }}
  }
  public var pickerDelegate:JSDatePickerDelegate? = nil
  public var currentDate:Date = Date()
  
  // INITS
  override init(frame: CGRect)
  {
    super.init(frame: frame)
    
    self.startUp()
  }
  
  required public init?(coder aDecoder: NSCoder)
  {
    fatalError("Init from Storyboard not enabled.")
  }
  
  // custom init
  convenience init(frame:CGRect, datePickerHeight:CGFloat = 100.0, calendarHeight:CGFloat = 300.0)
  {
    self.init(frame: frame)
    
    // set given heights
    self.datePickerHeight = datePickerHeight
    self.calendarHeight   = calendarHeight
    
  }
  
  // PRIVATE FUNCS
  private func startUp()
  {
    UIDevice.current.beginGeneratingDeviceOrientationNotifications()
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(didRotate),
                                           name: Notification.Name.UIDeviceOrientationDidChange,
                                           object: nil)
    currentOrientation = UIDevice.current.orientation
    
    makeDatePickerCV()
    makeCalendarCV()

    // set data for self
    self.backgroundColor = UIColor.clear
  }
  
  deinit
  {
    NotificationCenter.default.removeObserver(self)
  }
  
  private func makeDatePickerCV()
  {
    // make CV
    datePickerCV = DatePickerCollectionView(frame: self.frame, collectionViewLayout: UICollectionViewFlowLayout())
    datePickerCV.pickerMode = .day
    datePickerCV.currentDate = self.currentDate
    datePickerCV.loadData()
    
    datePickerCV.backgroundColor = UIColor.yellow
    
    // set delegates
    datePickerCV.dualScrollDelegate    = self
    datePickerCV.touchTransferDelegate = self
   
    // add CV to frame
    self.addSubview(datePickerCV)
  }
  
  private func makeCalendarCV()
  {
    // make CV
    calendarCV = CalendarCollectionView(frame: self.frame, collectionViewLayout: UICollectionViewFlowLayout())
    
    // set delegates
    calendarCV.dualScrollDelegate      = self
    calendarCV.touchTransferDelegate = self
    
    // add CV to frame
    self.addSubview(calendarCV)
  }
  
  private func makeConstraints()
  {
    if !didSetConstraints
    {
      didSetConstraints = true
      
      // make sure constraints stick to datepickerCV
      datePickerCV.translatesAutoresizingMaskIntoConstraints = false
      
      // add constraints to datepickerCV
      datePickerCV.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
      datePickerCV.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1.0, constant: ((self.frame.width / 7).rounded() * 7) - self.frame.width).isActive = true
      datePickerCV.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
      dateConstraint = datePickerCV.heightAnchor.constraint(equalToConstant: self.datePickerHeight)
      dateConstraint.isActive = true
      
      // make sure constraints stick to calendarCV
      calendarCV.translatesAutoresizingMaskIntoConstraints = false
      
      // add constraints to calendarCV
      calendarCV.topAnchor.constraint(equalTo: datePickerCV.bottomAnchor).isActive = true
      calendarCV.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive      = true
      calendarCV.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1.0, constant: ((self.frame.width / 7).rounded() * 7) - self.frame.width).isActive = true
      calendarCV.centerXAnchor.constraint(equalTo: datePickerCV.centerXAnchor).isActive   = true
      calConstraint = calendarCV.heightAnchor.constraint(equalToConstant: 0.0)
      calConstraint.isActive = true
    }
  }
  
  override public func layoutSubviews()
  {
    super.layoutSubviews()
    
    makeConstraints()
    
//    // do this to make sure size of cells is correct
//    let layout = datePickerCV.collectionViewLayout as! UICollectionViewFlowLayout
//    layout.invalidateLayout()
//    layout.prepare()
//
//    let layout2 = calendarCV.collectionViewLayout as! UICollectionViewFlowLayout
//    layout2.invalidateLayout()
//    layout2.prepare()
  }
  
  private func scrollToMiddle()
  {
    // scroll to middle of just the date picker (because it is the only thing open)
    datePickerCV.scrollToItem(at: IndexPath(row: datePickerCV.dateArray.count / 2, section: 0),
                              at: .centeredHorizontally,
                              animated: false)
  }
  
  // DualCollectionViewScrollDelegate
  public func collectionViewDidScroll(_ collectionView: UICollectionView)
  {
    if collectionView is CalendarCollectionView
    {
      // if the calendar is being scrolled by the user
      if !datePickerIsScrolling && calendarIsScrolling
      {
        datePickerCV.setContentOffset(calendarCV.contentOffset, animated: false)
      }
    }
    else if collectionView is DatePickerCollectionView
    {
      // the date picker is being scrolled by the user
      if !calendarIsScrolling && isCalendarExpanded
      {
        calendarCV.setContentOffset(datePickerCV.contentOffset, animated: false)
      }
    }
  }
  
  public func collectionViewDidEndScroll(_ collectionView: UICollectionView,
                                  withDifferenceOf diff: Int)
  {
    // if calendar is ending scroll
    if collectionView is CalendarCollectionView
    {
      // add the proper difference to the changeLog
      changeLog +=  -diff
      datePickerCV.shiftAndScroll(diff:diff)
    }
    // if the date picker is ending scroll
    else if collectionView is DatePickerCollectionView
    {
      if !isCalendarExpanded
      {
        self.currentDate = datePickerCV.currentDate
        pickerDelegate?.jsDatePicker(self, didChangeDateFrom: datePickerCV)
      }

      if (datePickerCV.pickerMode == .day && datePickerCV.currentDate.getMonth() != calendarCV.currentDate.getMonth() + changeLog) ||
          datePickerCV.pickerMode == .month
      {
        // if the calendar isnt expanded, we need to keep track of the changes to scroll to the right location when it opens
        if !isCalendarExpanded
        {
          changeLog += datePickerCV.pickerMode == .day ? (diff < 0 ? -1:1) : diff
        }
        else
        {
          changeLog +=  -1 * (datePickerCV.pickerMode == .day ? (diff < 0 ? -1:1) : diff)
          calendarCV.shiftAndScroll(diff:datePickerCV.pickerMode == .day ? (diff < 0 ? -1:1) : diff)
        }
      }
    }
    
    // reset the scrolling bools
    calendarIsScrolling   = false
    datePickerIsScrolling = false
  }
  
  // set scrolling bools
  public func collectionViewWillBeginDragging(_ collectionView: UICollectionView)
  {
    if collectionView is CalendarCollectionView
    {
      calendarIsScrolling = true
    }
    else
    {
      datePickerIsScrolling = true
    }
  }
  
  // CollectionViewTouchTransferDelegate
  public func collectionView(_ collectionView: UICollectionView,
                      didSelectItemAt indexPath: IndexPath)
  {
    // if the calendar is being expanded
    if collectionView is DatePickerCollectionView
    {
      // if the calendar should be expanded
      if !isCalendarExpanded
      {
        expandCalendar()
      }
      else
      {
        collapseCalendar()
      }
    }
    else if collectionView is CalendarCollectionView
    {
      changeLog = 0
      currentDate = self.calendarCV.pickerDate
      pickerDelegate?.jsDatePicker(self, didChangeDateFrom: self.calendarCV)
    }
  }
  
  public func expandCalendar()
  {
    // set calendar bool and height constraint
    isCalendarExpanded = true
    self.calConstraint.constant = self.calendarHeight
    
    // if the calendar is being presented for the first time, it should be scrolled to the middle location
    if isFirstTimeExpanding
    {
      isFirstTimeExpanding = false
      self.calendarCV.setContentOffset(CGPoint(x: self.calendarCV.frame.width * CGFloat(self.calendarCV.monthArray.count/2),
                                               y: 0),
                                       animated: false)
    }
    
    // set the date picker mode to month and load the correct data
    datePickerCV.currentDate = self.currentDate
    datePickerCV.pickerMode = .month
    datePickerCV.loadData()
    
    // pass the current date into the calendar
    calendarCV.pickerDate = datePickerCV.currentDate
    
    // reload all the cells so proper data gets shown
    self.datePickerCV.performBatchUpdates({
      self.datePickerCV.reloadSections(NSIndexSet(index: 0) as IndexSet)
    }, completion: nil)
    
    // animate the presentation of the calendar
    UIView.animate(withDuration: 0.45,
                   delay: 0.0,
                   options: .curveEaseOut,
                   animations: {
                    self.calendarCV.layoutIfNeeded()
                    self.superview?.layoutIfNeeded()
                    self.calendarCV.reloadData()
                    
                    // shift and scroll to the correct location
                    if !self.isFirstTimeExpanding { self.calendarCV.shiftAndScroll(diff: self.changeLog) }
                   },
                   completion: {_ in
                    // reset the change log
                    self.changeLog = 0
                    self.scrollToMiddle()
                   })
  }
  
  public func collapseCalendar()
  {
    // change the calendar bool and shrink the calendar
    isCalendarExpanded = false
    self.calConstraint.constant = 0.0
    
    // change the picker mode back to day and load the correct data
    datePickerCV.pickerMode  = .day
    datePickerCV.currentDate = calendarCV.pickerDate
    datePickerCV.loadData()
    
    // make sure all cells get updated in picker view
    self.datePickerCV.performBatchUpdates({
      self.datePickerCV.reloadSections(NSIndexSet(index: 0) as IndexSet)
    }, completion: nil)
    
    // animate shrinking of calendar
    UIView.animate(withDuration: 0.45,
                   delay: 0.0,
                   options: .curveEaseOut,
                   animations: {
                    self.calendarCV.layoutIfNeeded()
                    self.superview?.layoutIfNeeded()
                   },
                   completion: { _ in
                    self.scrollToMiddle()
                   })
  }
  
  @objc private func didRotate()
  {
    datePickerCV.reloadData()
    calendarCV.reloadData()
    self.calendarCV.layoutIfNeeded()
    self.scrollToMiddle()
  }
}

