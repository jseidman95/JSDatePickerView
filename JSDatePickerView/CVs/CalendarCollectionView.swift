//
//  CalendarCollectionView.swift
//  JSDatePickerView
//
//  Created by Jesse Seidman on 2/15/18.
//  Copyright © 2018 Jesse Seidman. All rights reserved.
//

import UIKit

public class CalendarCollectionView: UICollectionView,
                              UICollectionViewDelegate,
                              UICollectionViewDataSource,
                              UICollectionViewDelegateFlowLayout
{
  // PRIVATE VARS
  private var grayCounter = 0
  private let daysPerLine:Int = 7 //This variable holds the amount of cells that are displayed per line
  private var selectedCell:CalendarViewCell? = nil
  private var grayedCellColor:UIColor = UIColor(red:   192/255.0,
                                                green: 192/255.0,
                                                blue:  192/255.0,
                                                alpha: 1.0)
  private var autoScrolling = false
  
  // PUBLIC VARS
  public var cellBackgroundColor:UIColor = UIColor.white   //The background color of the cell
  public var selectedCircleColor:UIColor = UIColor(red:   255/255.0, //The color of circle when the user selects
                                                   green: 51/255.0,
                                                   blue:  51/255.0,
                                                   alpha: 1.0)
  public var selectedCircleDistanceFromEdge:CGFloat = 10.0  //The circle's distance from the edge of the cell
  public var font:UIFont = UIFont.systemFont(ofSize: 12.0) //The font of the cells
  public var dualScrollDelegate:DualCollectionViewScrollDelegate? = nil
  public var touchTransferDelegate:CollectionViewTouchTransferDelegate? = nil
  public var preloadedCellCount:Int = 50
  
  // INTERNAl VARS
  internal var monthArray:[[CalendarDay]] = []
  internal var currentDate:Date = Date() //The current date of the calendar
  internal var pickerDate:Date  = Date()
  
  // PUBLIC GET PRIVATE SET VARS
  public private(set) var cellWidth:CGFloat = 0.0 //helps the picker view set frame, dont want the user messing with this
  
  // INITS
  override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout)
  {
    super.init(frame: frame, collectionViewLayout: layout)
    
    self.startUp()
  }
  
  required public init?(coder aDecoder: NSCoder)
  {
    super.init(coder: aDecoder)
    
    self.startUp()
  }
  
  // PRIVATE FUNCS
  private func startUp()
  {
    // set delegates and data source
    self.delegate   = self
    self.dataSource = self
    
    // set data
    self.backgroundColor = UIColor.clear
    self.isPagingEnabled = true
    self.showsHorizontalScrollIndicator = false
    
    // register cell class and set delgates
    self.register(CalendarViewCell.self, forCellWithReuseIdentifier: "calendarCell")
    
    // set cell layout data
    let layout = UICollectionViewFlowLayout()
    layout.minimumInteritemSpacing = 0.0
    layout.minimumLineSpacing      = 0.0
    layout.scrollDirection         = .horizontal
    self.collectionViewLayout      = layout
    
    // get data
    for i in stride(from: preloadedCellCount, through: 1, by: -1) // add previous days
    {
      monthArray.append(CalendarUtil.rotate(calendarArray: CalendarUtil.getCalendarData(for: Calendar.current.date(byAdding: .month, value: -1 * i, to: currentDate)!)))
    }
    
    monthArray.append(CalendarUtil.rotate(calendarArray: CalendarUtil.getCalendarData(for: currentDate)))
    
    for i in 1...preloadedCellCount
    {
      monthArray.append(CalendarUtil.rotate(calendarArray: CalendarUtil.getCalendarData(for: Calendar.current.date(byAdding: .month, value: i, to: currentDate)!)))
    }
  }
  
  private func shiftDateArray(diff:Int)
  {
    // set new currentDate
    currentDate = Calendar.current.date(byAdding: .month, value: diff, to: currentDate)!

    if diff > 0
    {
      for i in 0..<monthArray.count
      {
        if i + diff < monthArray.count
        {
          monthArray[i] = monthArray[i + diff]
        }
        else
        {
          monthArray[i] = CalendarUtil.rotate(calendarArray: CalendarUtil.getCalendarData(for: Calendar.current.date(byAdding: .month, value: 1, to: monthArray[i-1][16].date!)!))
        }
      }
    }
    else
    {
      for i in stride(from: monthArray.count-1, through: 0, by: -1)
      {
        if i + diff >= 0
        {
          monthArray[i] = monthArray[i + diff]
        }
        else
        {
          monthArray[i] = CalendarUtil.rotate(calendarArray: CalendarUtil.getCalendarData(for: Calendar.current.date(byAdding: .month, value: -1, to: monthArray[i+1][16].date!)!))
        }
      }
    }
    
    self.reloadData()
  }
  
  // UICollectionViewDataSource
  public func collectionView(_ collectionView: UICollectionView,
                      numberOfItemsInSection section: Int) -> Int
  {
    return monthArray[section].count
  }
  
  public func numberOfSections(in collectionView: UICollectionView) -> Int
  {
    return monthArray.count
  }
  
  public func collectionView(_ collectionView: UICollectionView,
                             cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
  {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "calendarCell", for: indexPath) as? CalendarViewCell
    
    //clear the data to avoid any dequeueing errors
    cell?.deleteCircle(layer: cell!.selectedCircleLayer)
    cell?.backgroundColor = cellBackgroundColor
    cell?.dateNumberLabel.font = font
    cell?.selectedCircleColor = selectedCircleColor
    cell?.circleDistanceFromEdge = self.selectedCircleDistanceFromEdge
    cell?.layer.mask = nil
    
    // set the label
    if monthArray[indexPath.section][indexPath.row].day == nil // if the cell is a day cell and not a date cell
    {
      if let labelText = monthArray[indexPath.section][indexPath.row].labelText
      {
        // only get first three letter of the month
        cell?.dateNumberLabel.text = String(labelText[...labelText.index(labelText.startIndex, offsetBy: 2)])
        
        // bold the month titles
        cell?.dateNumberLabel.font = UIFont.boldSystemFont(ofSize: font.pointSize)
      }
    }
    else // if the cell is a date cell
    {
      if let dayNumber = monthArray[indexPath.section][indexPath.row].dayNumber
      {
        cell?.dateNumberLabel.text = "\(dayNumber)"
      }
      let calComponents = Calendar.current.dateComponents([.month,.day,.year],
                                                             from: monthArray[indexPath.section][indexPath.row].date!)
      let currentComponents = Calendar.current.dateComponents([.month,.day,.year], from: Date())
      if calComponents == currentComponents
      {
        cell?.dateNumberLabel.font = UIFont(name: (cell?.dateNumberLabel.font.fontName)!,
                                            size: (cell?.dateNumberLabel.font.pointSize)! + 10.0)
      }
    }
    
    // if the calendar data is not from this month, it should be grayed out slightly
    switch monthArray[indexPath.section][indexPath.row].gray
    {
      case .previousMonth(let grayNum, let isLast):
        cell?.backgroundColor = grayedCellColor.withAlphaComponent(1-(CGFloat(grayNum) * 0.065 + 0.15))
        if isLast
        {
          let rectShape = CAShapeLayer()
          rectShape.bounds = (cell?.frame)!
          rectShape.position = (cell?.center)!
          rectShape.path = UIBezierPath(roundedRect: (cell?.bounds)!,
                                        byRoundingCorners: [.topRight,.bottomRight],
                                        cornerRadii: CGSize(width: 15, height: 15)).cgPath
          cell?.layer.mask = rectShape
        }
      case .nextMonth(let grayNum, let isFirst):
        cell?.backgroundColor = grayedCellColor.withAlphaComponent(CGFloat(grayNum)*0.065 + 0.15)
        if isFirst
        {
          let rectShape = CAShapeLayer()
          rectShape.bounds = (cell?.frame)!
          rectShape.position = (cell?.center)!
          rectShape.path = UIBezierPath(roundedRect: (cell?.bounds)!,
                                        byRoundingCorners: [.topLeft,.bottomLeft],
                                        cornerRadii: CGSize(width: 15, height: 15)).cgPath
          cell?.layer.mask = rectShape
        }
      case .none:
        break
    }
    
    // set the selected layer
    if let currDate = monthArray[indexPath.section][indexPath.row].date
    {
      let components = Calendar.current.dateComponents([.day,.month,.year], from: pickerDate)
      let currentComponents = Calendar.current.dateComponents([.day,.month,.year], from: currDate)
      
      if components == currentComponents && monthArray[indexPath.section][indexPath.row].gray == GrayType.none
      {
        cell?.setSelectedCircle()
        cell?.addCircle(layer: (cell?.selectedCircleLayer)!)
        self.selectedCell = cell
      }
    }
    
    return cell!
  }
  
  // The size of the items is calculated precisely to preserve the grid layout
  public func collectionView(_ collectionView: UICollectionView,
                             layout collectionViewLayout: UICollectionViewLayout,
                             sizeForItemAt indexPath: IndexPath) -> CGSize
  {
    var cellSize = CGSize()
    
    // get flow layout
    let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout
    
    if let flowLayout = flowLayout
    {
      // calculate the amount of space to account for when getting the width of the cells
      let spaceToSubtract = flowLayout.sectionInset.left  +
        flowLayout.sectionInset.right +
        (flowLayout.minimumInteritemSpacing * CGFloat(daysPerLine - 1))

      // The size of the height and width of the cell
      let size = (self.bounds.width - spaceToSubtract) / CGFloat(daysPerLine)
      
      // save the cell width for the PickerView to use when resizing the width of the calendar
      self.cellWidth = size.rounded()
      
      // make new size
      cellSize = CGSize(width: cellWidth, height: self.frame.height / CGFloat(monthArray[indexPath.section].count / daysPerLine))
    }

    return cellSize
  }
  
  public func collectionView(_ collectionView: UICollectionView,
                             willDisplay cell: UICollectionViewCell,
                             forItemAt indexPath: IndexPath)
  {
    UIView.performWithoutAnimation {
      cell.layoutIfNeeded()
    }
  }
  
  public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
  {
    if let newDate = monthArray[indexPath.section][indexPath.row].date
    {
      if newDate.getMonth() == currentDate.getMonth()
      {
        self.selectedCell?.deleteCircle(layer: (selectedCell?.selectedCircleLayer)!)

        let cell = collectionView.cellForItem(at: indexPath) as? CalendarViewCell
        cell?.setSelectedCircle()
        cell?.addCircle(layer: (cell?.selectedCircleLayer)!)
        self.selectedCell = cell

        self.pickerDate = newDate
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05, execute: {
          self.touchTransferDelegate?.collectionView(collectionView, didSelectItemAt: indexPath)
        })
      }
    }
  }
  // UIScrollViewDelegate
  public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
  {
    // calculated difference from middle
    let diff = Int(self.contentOffset.x / self.frame.width) - monthArray.count / 2
    
    if !autoScrolling
    {
      currentDate = monthArray[Int(self.contentOffset.x / self.frame.width)][2].date!
    }
    autoScrolling = false
    
    self.shiftAndScroll(diff:diff)
    
    dualScrollDelegate?.collectionViewDidEndScroll(self, withDifferenceOf: diff)
  }
  
  public func scrollViewDidScroll(_ scrollView: UIScrollView)
  {
    dualScrollDelegate?.collectionViewDidScroll(self)
  }
  
  public func scrollViewWillBeginDragging(_ scrollView: UIScrollView)
  {
    dualScrollDelegate?.collectionViewWillBeginDragging(self)
  }
  
  // INTERNAL FUNCS
  internal func shiftAndScroll(diff:Int)
  {
    shiftDateArray(diff:diff)
    autoScrolling = true
    self.scrollToItem(at: IndexPath(row: 0, section:  monthArray.count/2),
                      at: .left,
                      animated: false)
  }
  
}
