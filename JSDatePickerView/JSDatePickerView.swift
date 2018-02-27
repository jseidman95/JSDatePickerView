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

public class JSDatePickerView: UIView
{
  // PRIVATE VARS
  // Bools
  private var datePickerIsScrolling  = false
  private var didSetConstraints      = false
  private var isCalendarExpanded     = false
  private var widthGreaterThanHeight = true
  
  // CollectionViews
  public var calendarCV  :CalendarCollectionView!
  private var datePickerCV:DatePickerCollectionView!
  
  // NSLayoutConstraints
  private var dateConstraint = NSLayoutConstraint()
  private var calConstraint  = NSLayoutConstraint()
  
  // Orientation tracker
  private var deviceOrientation: UIDeviceOrientation = .unknown
  
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
  
  override public func layoutSubviews()
  {
    super.layoutSubviews()
    
    // make the constraints, if needed
    makeConstraints()

    // reload on device orientation switch
    if deviceOrientation != UIDevice.current.orientation
    {
      // reload the data
      self.reloadAllData()
      
      // update the orientation
      deviceOrientation = UIDevice.current.orientation
      
      // reset calendar insets
      let layout = self.calendarCV.collectionViewLayout as! UICollectionViewFlowLayout
      let diff = self.calendarCV.frame.width - ((self.calendarCV.frame.width / 7).rounded() * 7)
      layout.sectionInset = UIEdgeInsets(top: 0.0,
                                         left: diff/2,
                                         bottom: 0.0,
                                         right: diff/2)
    }
  }
}

extension JSDatePickerView
{
  /** Public **/
  public func expandCalendar()   { _expandCalendar() }
  public func collapseCalendar() { _collapseCalendar() }
  
}

extension JSDatePickerView
{
  /** Private **/
  
  private func scrollToMiddle()
  {
    // scroll to middle of just the date picker (because it is the only thing open)
    datePickerCV.scrollToItem(at: IndexPath(row: datePickerCV.dateArray.count / 2, section: 0),
                              at: .centeredHorizontally,
                              animated: false)
  }
  
  private func _expandCalendar()
  {
    
    // set calendar bool and height constraint
    isCalendarExpanded = true
    self.calConstraint.constant = self.calendarHeight
    
    self.calendarCV.setContentOffset(CGPoint(x: self.calendarCV.frame.width * CGFloat(self.calendarCV.monthArray.count/2), y: 0), animated: false)
    
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
    UIView.animate(withDuration: 0.40,
                   delay: 0.0,
                   options: .curveEaseOut,
                   animations: {
                    self.calendarCV.layoutIfNeeded()
                    self.superview?.layoutIfNeeded()
                    
                    // shift and scroll to the correct location
                    self.calendarCV.shiftAndScroll(diff: self.changeLog)
                   },
                   completion: { _ in
                    // reset the change log
                    self.changeLog = 0
                    //self.reloadAllData()
                   })
  }
  
  private func _collapseCalendar()
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
    UIView.animate(withDuration: 0.40,
                   delay: 0.0,
                   options: .curveEaseOut,
                   animations: {
                    self.calendarCV.layoutIfNeeded()
                    self.superview?.layoutIfNeeded()
                   },
                   completion: { _ in
                    //self.reloadAllData()
                   })
  }
  
  private func startUp()
  {
    makeDatePickerCV()
    makeCalendarCV()
    
    // set data for self
    self.backgroundColor = UIColor.clear
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
    calendarCV.dualScrollDelegate    = self
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
      
      // make sure constraints stick to calendarCV
      calendarCV.translatesAutoresizingMaskIntoConstraints = false
      
      if #available(iOS 11.0, *)
      {
        let safeGuide = self.safeAreaLayoutGuide
      
        datePickerCV.topAnchor.constraint(equalTo: safeGuide.topAnchor).isActive = true
        datePickerCV.leftAnchor.constraint(equalTo: safeGuide.leftAnchor).isActive = true
        datePickerCV.rightAnchor.constraint(equalTo: safeGuide.rightAnchor).isActive = true

        datePickerCV.centerXAnchor.constraint(equalTo: safeGuide.centerXAnchor).isActive = true
        dateConstraint = datePickerCV.heightAnchor.constraint(equalToConstant: self.datePickerHeight)
        dateConstraint.isActive = true
      
        // add constraints to calendarCV
        calendarCV.topAnchor.constraint(equalTo: datePickerCV.bottomAnchor).isActive = true
        calendarCV.bottomAnchor.constraint(equalTo: safeGuide.bottomAnchor).isActive      = true
        calendarCV.leftAnchor.constraint(equalTo: safeGuide.leftAnchor).isActive = true
        calendarCV.rightAnchor.constraint(equalTo: safeGuide.rightAnchor).isActive = true
        calendarCV.centerXAnchor.constraint(equalTo: datePickerCV.centerXAnchor).isActive   = true
        calConstraint = calendarCV.heightAnchor.constraint(equalToConstant: 0.0)
        calConstraint.isActive = true
      }
      else
      {
        // add constraints to datepickerCV
        datePickerCV.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        datePickerCV.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        datePickerCV.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        dateConstraint = datePickerCV.heightAnchor.constraint(equalToConstant: self.datePickerHeight)
        dateConstraint.isActive = true
        
        // add constraints to calendarCV
        calendarCV.topAnchor.constraint(equalTo: datePickerCV.bottomAnchor).isActive = true
        calendarCV.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive      = true
        calendarCV.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        calendarCV.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        calConstraint = calendarCV.heightAnchor.constraint(equalToConstant: 0.0)
        calConstraint.isActive = true
      }
    }
  }
  
  // Reload data for both collectionViews and re-center
  private func reloadAllData()
  {
    self.calendarCV.layoutIfNeeded()
    self.calendarCV.reloadData()
    self.datePickerCV.reloadData()
    self.scrollToMiddle()
  }
}
extension JSDatePickerView: DualCollectionViewScrollDelegate
{
  /** DualCollectionViewScrollDelegate **/
  
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
    datePickerCV.isUserInteractionEnabled = true
    calendarCV.isUserInteractionEnabled   = true
  }
  
  // set scrolling bools
  public func collectionViewWillBeginDragging(_ collectionView: UICollectionView)
  {
    if collectionView is CalendarCollectionView
    {
      calendarIsScrolling = true
      datePickerCV.isUserInteractionEnabled = false
    }
    else
    {
      datePickerIsScrolling = true
      calendarCV.isUserInteractionEnabled = false
    }
  }
}

extension JSDatePickerView: CollectionViewTouchTransferDelegate
{
/** CollectionViewTouchTransferDelegate **/
  
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
        _expandCalendar()
      }
      else
      {
        _collapseCalendar()
      }
    }
    else if collectionView is CalendarCollectionView
    {
      changeLog = 0
      currentDate = self.calendarCV.pickerDate
      pickerDelegate?.jsDatePicker(self, didChangeDateFrom: self.calendarCV)
    }
  }
}
