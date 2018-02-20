//
//  JSDatePickerView.swift
//  JSDatePickerView
//
//  Created by Jesse Seidman on 2/14/18.
//  Copyright © 2018 Jesse Seidman. All rights reserved.
//

import UIKit

class JSDatePickerView: UIView, DualCollectionViewScrollDelegate,CollectionViewTouchTransferDelegate
{
  // PRIVATE VARS
  private var datePickerIsScrolling = false
  private var calendarIsScrolling   = false
  private var calendarCV:CalendarCollectionView!
  private var datePickerCV:DatePickerCollectionView!
  private var didSetConstraints = false
  private var isCalendarExpanded = false
  private var dateConstraint = NSLayoutConstraint()
  private var calConstraint  = NSLayoutConstraint()
  
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

    self.backgroundColor = UIColor.cyan
  }
  
  private func makeDatePickerCV()
  {
    // make CV
    datePickerCV = DatePickerCollectionView(frame: self.frame, collectionViewLayout: UICollectionViewFlowLayout())
    
    // set delegates
    datePickerCV.dualScrollDelegate = self
    datePickerCV.touchTransferDelegate = self
   
    // add CV to frame
    self.addSubview(datePickerCV)
  }
  
  private func makeCalendarCV()
  {
    // make CV
    calendarCV = CalendarCollectionView(frame: self.frame, collectionViewLayout: UICollectionViewFlowLayout())
    
    // set delegates
    calendarCV.dualScrollDelegate = self
    datePickerCV.touchTransferDelegate = self
    
    // add CV to frame
    self.addSubview(calendarCV)
  }
  
  private func makeConstraints()
  {
    if !didSetConstraints
    {
      didSetConstraints = true
      
      // make sure constraints stick
      datePickerCV.translatesAutoresizingMaskIntoConstraints = false
      
      // add constraints
      datePickerCV.topAnchor.constraint(equalTo: self.topAnchor).isActive     = true
      datePickerCV.leftAnchor.constraint(equalTo: self.leftAnchor).isActive   = true
      datePickerCV.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
      dateConstraint = datePickerCV.heightAnchor.constraint(equalToConstant: self.frame.height)
      dateConstraint.isActive = true
      
      // make sure constraints stick
      calendarCV.translatesAutoresizingMaskIntoConstraints = false
      
      // add constraints
      calendarCV.rightAnchor.constraint(equalTo: self.rightAnchor).isActive        = true
      calendarCV.leftAnchor.constraint(equalTo: self.leftAnchor).isActive          = true
      calendarCV.topAnchor.constraint(equalTo: datePickerCV.bottomAnchor).isActive = true
      calendarCV.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive      = true
      calConstraint = calendarCV.heightAnchor.constraint(equalToConstant: 0.0)
      calConstraint.isActive = true
      
      print(self.frame.height)
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
  
  // CollectionViewTouchTransferDelegate
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
  {
    if collectionView is DatePickerCollectionView
    {
      if !isCalendarExpanded
      {
        isCalendarExpanded = true
        //self.fixedHeightConstraint?.constant *= 5
        UIView.animate(withDuration: 0.6,
                       delay: 0.0,
                       options: .curveEaseOut,
                       animations: {
                        self.layoutIfNeeded()
                        self.calendarCV.reloadData()
                       },
                       completion: nil)
      }
      else
      {
        isCalendarExpanded = false
        //self.fixedHeightConstraint?.constant = self.datePickerCV.frame.height
        UIView.animate(withDuration: 0.6,
                       delay: 0.0,
                       options: .curveEaseOut,
                       animations: {
                        self.layoutIfNeeded()
                       },
                       completion: nil)
      }
    }
  }
}

