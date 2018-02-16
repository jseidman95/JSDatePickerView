//
//  JSDatePickerView.swift
//  JSDatePickerView
//
//  Created by Jesse Seidman on 2/14/18.
//  Copyright © 2018 Jesse Seidman. All rights reserved.
//

import UIKit

class JSDatePickerView: UIView, DualCollectionViewScrollDelegate
{
  // PRIVATE VARS
  private var datePickerCV:DatePickerCollectionView!
  private var calendarCV:CalendarCollectionView!
  private var datePickerIsScrolling = false
  private var calendarIsScrolling   = false
  
  // INITS
  override init(frame: CGRect)
  {
    super.init(frame: frame)
    
    self.startUp()
  }
  
  required init?(coder aDecoder: NSCoder)
  {
    super.init(coder: aDecoder)
    
    self.startUp()
  }
  
  // PRIVATE FUNCS
  private func startUp()
  {
    makeDatePickerCV()
    makeCalendarCV()
  }
  
  private func makeDatePickerCV()
  {
    // make CV
    datePickerCV = DatePickerCollectionView(frame: self.frame, collectionViewLayout: UICollectionViewFlowLayout())
    
    // set dual scroll delegate
    datePickerCV.dualScrollDelegate = self
   
    // add CV to frame
    self.addSubview(datePickerCV)
    
    // make sure constraints stick
    datePickerCV.translatesAutoresizingMaskIntoConstraints = false
    
    // add constraints
    datePickerCV.topAnchor.constraint(equalTo: self.topAnchor).isActive     = true
    datePickerCV.leftAnchor.constraint(equalTo: self.leftAnchor).isActive   = true
    datePickerCV.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
    datePickerCV.heightAnchor.constraint(equalToConstant: self.frame.height/3).isActive = true
  }
  private func makeCalendarCV()
  {
    // make CV
    calendarCV = CalendarCollectionView(frame: self.frame, collectionViewLayout: UICollectionViewFlowLayout())
    
    // set dual scroll delegate
    calendarCV.dualScrollDelegate = self
    
    // add CV to frame
    self.addSubview(calendarCV)
    
    // make sure constraints stick
    calendarCV.translatesAutoresizingMaskIntoConstraints = false
    
    // add constraints
    calendarCV.leftAnchor.constraint(equalTo: self.leftAnchor).isActive   = true
    calendarCV.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
    calendarCV.topAnchor.constraint(equalTo: datePickerCV.bottomAnchor).isActive = true
    calendarCV.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive      = true
  }
  
  override func layoutSubviews()
  {
    super.layoutSubviews()
    
    datePickerCV.scrollToItem(at: IndexPath(row: datePickerCV.dateArray.count / 2, section: 0),
                              at: .centeredHorizontally,
                              animated: false)
    
    calendarCV.scrollToItem(at: IndexPath(row: 0, section: calendarCV.monthArray.count / 2),
                              at: .top,
                              animated: false)
    
    // do this here because the scrollviews autoscroll
    calendarIsScrolling   = false
    datePickerIsScrolling = false
  }
  
  // DualCollectionViewScrollDelegate
  func collectionViewDidScroll(_ collectionView: UICollectionView)
  {
    if collectionView is CalendarCollectionView
    {
      if !datePickerIsScrolling
      {
        calendarIsScrolling = true
        datePickerCV.setContentOffset(calendarCV.contentOffset, animated: false)
      }
    }
    else if collectionView is DatePickerCollectionView
    {
      if !calendarIsScrolling
      {
        datePickerIsScrolling = true
        calendarCV.setContentOffset(datePickerCV.contentOffset, animated: false)
      }
    }
  }
  
  func collectionViewDidEndScroll(_ collectionView: UICollectionView, withDifferenceOf diff: Int) {
    if collectionView is CalendarCollectionView
    {
      calendarIsScrolling = false
      datePickerCV.shiftAndScroll(diff:diff)
    }
    else if collectionView is DatePickerCollectionView
    {
      datePickerIsScrolling = false
      calendarCV.shiftAndScroll(diff:diff)
    }
  }
}

