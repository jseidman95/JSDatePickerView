//
//  CalendarView.swift
//  JSDatePickerView
//
//  Created by Jesse Seidman on 12/26/17.
//  Copyright © 2017 Jesse Seidman. All rights reserved.
//

import UIKit
import EAInfiniteScrollView

// delegate that allows the calendar to talk to the DatePicker (or wherever the user implements the calendar)
public protocol CalendarViewDelegate
{
  func calendarView(currentDateFor calendarCollectionView:CalendarCollectionView) -> Date
  func calendarView(_ calendarView:CalendarCollectionView, didSelectDate:Date)
}

// This class contains the CollectionView that makes up the calendar
public class CalendarView:UIView,InfiniteScrollViewDataSource
{
  // PRIVATE VARS
  private var infiniteScrollView:InfiniteScrollView = InfiniteScrollView()
  private var leftCalendarCollectionView:UIView = UIView()
  private var rightCalendarCollectionView:UIView = UIView()
  
  // INITS
  public override init(frame: CGRect)
  {
    super.init(frame: frame)
    
    self.startUp()
  }
  
  public required init?(coder aDecoder: NSCoder)
  {
    super.init(coder: aDecoder)
    
    self.startUp()
  }
  
  // PRIVATE FUNCS
  private func startUp()
  {
    // make calendar collections
    rightCalendarCollectionView = makeCalendarView()
    leftCalendarCollectionView  = makeCalendarView()
    
    // set delegate
    infiniteScrollView.infiniteDelegate = self
    
    // set inf scroll data
    //infiniteScrollView.showsHorizontalScrollIndicator = false
    
    // add scrollview
    self.addSubview(infiniteScrollView)
    
    // make sure constraints stick
    infiniteScrollView.translatesAutoresizingMaskIntoConstraints = false
    
    // add constraints
    infiniteScrollView.topAnchor.constraint(equalTo: self.topAnchor).isActive       = true
    infiniteScrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    infiniteScrollView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive     = true
    infiniteScrollView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive   = true
  }
  
  private func makeCalendarView() -> UIView
  {
    // make view
    let view = UIView(frame: infiniteScrollView.frame)
    
    // make collectionview
    let calendarCollectionView = CalendarCollectionView(frame: view.frame,
                                                        collectionViewLayout: UICollectionViewFlowLayout())

    // add collectionview
    view.addSubview(calendarCollectionView)

    // make sure constraints stick
    calendarCollectionView.translatesAutoresizingMaskIntoConstraints = false

    // add constraints
    calendarCollectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive         = true
    calendarCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive   = true
    calendarCollectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    // The size of the height and width of the cell
    let width = (view.frame.width / CGFloat(calendarCollectionView.daysPerLine)).rounded()
    calendarCollectionView.widthAnchor.constraint(equalToConstant: width * CGFloat(calendarCollectionView.daysPerLine)).isActive = true
    
    return view
  }
  
  public func infiniteItemForDirection(_ direction: direction) -> UIView
  {
    return makeCalendarView()
  }
}
