//
//  JSDatePickerView.swift
//  JSDatePickerView
//
//  Created by Jesse Seidman on 2/14/18.
//  Copyright © 2018 Jesse Seidman. All rights reserved.
//

import UIKit

class JSDatePickerView: UIView,
                        DualCollectionViewScrollDelegate,
                        CollectionViewTouchTransferDelegate
{
  // PRIVATE VARS
  // Bools
  private var datePickerIsScrolling = false
  private var didSetConstraints     = false
  private var isCalendarExpanded    = false
  private var isFirstTimeExpanding  = true  // for special presentation on the first time
  
  // CollectionViews
  private var calendarCV  :CalendarCollectionView!
  private var datePickerCV:DatePickerCollectionView!
  
  // NSLayoutConstraints
  private var dateConstraint = NSLayoutConstraint()
  private var calConstraint  = NSLayoutConstraint()
  
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
  
  // INITS
  override init(frame: CGRect)
  {
    super.init(frame: frame)
    
    self.startUp()
  }
  
  required init?(coder aDecoder: NSCoder)
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
    makeDatePickerCV()
    makeCalendarCV()

    // set data for self
    self.backgroundColor = UIColor.clear
  }
  
  private func makeDatePickerCV()
  {
    // make CV
    datePickerCV = DatePickerCollectionView(frame: self.frame, collectionViewLayout: UICollectionViewFlowLayout())
    
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
    datePickerCV.touchTransferDelegate = self
    
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
      datePickerCV.topAnchor.constraint(equalTo: self.topAnchor).isActive     = true
      datePickerCV.leftAnchor.constraint(equalTo: self.leftAnchor).isActive   = true
      datePickerCV.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
      dateConstraint = datePickerCV.heightAnchor.constraint(equalToConstant: self.datePickerHeight)
      dateConstraint.isActive = true
      
      // make sure constraints stick to calendarCV
      calendarCV.translatesAutoresizingMaskIntoConstraints = false
      
      // add constraints to calendarCV
      calendarCV.rightAnchor.constraint(equalTo: self.rightAnchor).isActive        = true
      calendarCV.leftAnchor.constraint(equalTo: self.leftAnchor).isActive          = true
      calendarCV.topAnchor.constraint(equalTo: datePickerCV.bottomAnchor).isActive = true
      calendarCV.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive      = true
      calConstraint = calendarCV.heightAnchor.constraint(equalToConstant: 0.0)
      calConstraint.isActive = true
    }
  }
  
  override func layoutSubviews()
  {
    super.layoutSubviews()
    
    makeConstraints()
    
    // scroll to middle
    datePickerCV.scrollToItem(at: IndexPath(row: datePickerCV.dateArray.count / 2, section: 0),
                              at: .centeredHorizontally,
                              animated: false)
    
    let layout = datePickerCV.collectionViewLayout as! UICollectionViewFlowLayout
    layout.invalidateLayout()
    layout.prepare()
  }
  
  
  // DualCollectionViewScrollDelegate
  func collectionViewDidScroll(_ collectionView: UICollectionView)
  {
    if collectionView is CalendarCollectionView
    {
      if !datePickerIsScrolling && calendarIsScrolling
      {
        datePickerCV.setContentOffset(calendarCV.contentOffset, animated: false)
      }
    }
    else if collectionView is DatePickerCollectionView
    {
      if !calendarIsScrolling && isCalendarExpanded
      {
        calendarCV.setContentOffset(datePickerCV.contentOffset, animated: false)
      }
    }
  }
  
  func collectionViewDidEndScroll(_ collectionView: UICollectionView, withDifferenceOf diff: Int)
  {
    if collectionView is CalendarCollectionView
    {
      datePickerCV.shiftAndScroll(diff:diff)
    }
    else if collectionView is DatePickerCollectionView
    {
      if (datePickerCV.pickerMode == .day && datePickerCV.currentDate.getMonth() != calendarCV.currentDate.getMonth()) ||
          datePickerCV.pickerMode == .month
      {
        if !isCalendarExpanded
        {
          changeLog += diff
        }
        else
        {
          calendarCV.shiftAndScroll(diff:diff)
        }
      }
    }
    
    calendarIsScrolling   = false
    datePickerIsScrolling = false
  }
  
  func collectionViewWillBeginDragging(_ collectionView: UICollectionView)
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
  func collectionView(_ collectionView: UICollectionView,
                      didSelectItemAt indexPath: IndexPath)
  {
    if collectionView is DatePickerCollectionView
    {
      if !isCalendarExpanded
      {
        isCalendarExpanded = true
        self.calConstraint.constant = self.calendarHeight
        
        if isFirstTimeExpanding
        {
          isFirstTimeExpanding = false
          self.calendarCV.setContentOffset(CGPoint(x: self.frame.width * CGFloat(self.calendarCV.monthArray.count/2),
                                                   y: 0),
                                           animated: false)
        }
        datePickerCV.pickerMode = .month
        datePickerCV.loadData()
        self.datePickerCV.performBatchUpdates({
          self.datePickerCV.reloadSections(NSIndexSet(index: 0) as IndexSet)
        }, completion: nil)
        UIView.animate(withDuration: 0.45,
                       delay: 0.0,
                       options: .curveEaseOut,
                       animations: {
                        
                        self.calendarCV.layoutIfNeeded()
                        self.superview?.layoutIfNeeded()
                        self.calendarCV.reloadData()
                        if !self.isFirstTimeExpanding { self.calendarCV.shiftAndScroll(diff: self.changeLog) }
                       },
                       completion: {_ in
                        self.changeLog = 0
                       })
      }
      else
      {
        isCalendarExpanded = false
        self.calConstraint.constant = 0.0
        datePickerCV.pickerMode = .day
        datePickerCV.loadData()
        self.datePickerCV.performBatchUpdates({
          self.datePickerCV.reloadSections(NSIndexSet(index: 0) as IndexSet)
        }, completion: nil)
        UIView.animate(withDuration: 0.45,
                       delay: 0.0,
                       options: .curveEaseOut,
                       animations: {
                        self.calendarCV.layoutIfNeeded()
                        self.superview?.layoutIfNeeded()
                       },
                       completion: nil)
      }
    }
  }
}

