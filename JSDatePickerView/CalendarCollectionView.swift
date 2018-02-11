//
//  CalendarCollectionView.swift
//  JSDatePickerView
//
//  Created by Jesse Seidman on 2/11/18.
//  Copyright © 2018 Jesse Seidman. All rights reserved.
//

import UIKit

// This class is the cell that holds the day data in the CollectionView
internal class CalendarViewCell:UICollectionViewCell
{
  // INTERNAL VARS
  internal let dateNumberLabel        : UILabel      = UILabel()      //The label that holds the date number
  internal var circleDistanceFromEdge : CGFloat      = 0.0            //Customize the circle radius
  internal var selectedCircleLayer    : CAShapeLayer = CAShapeLayer() //The circle that is shown on selection
  
  internal var selectedCircleColor    : UIColor = UIColor.red
  {
    didSet { self.setSelectedCircleColor(selectedCircleColor) }
  }
  
  // INITS
  // init from StoryBoard
  internal required init?(coder aDecoder: NSCoder)
  {
    super.init(coder: aDecoder)
    
    startUp()
  }
  
  // init from code
  internal override init(frame: CGRect)
  {
    super.init(frame: frame)
    
    startUp()
  }
  
  // PRIVATE FUNCTIONS
  private func startUp()
  {
    // make the label
    makeLabel()
    
    // make and store the circle layer
    self.selectedCircleColor = UIColor.gray
    self.circleDistanceFromEdge = 10.0
  }
  
  private func setSelectedCircleColor(_ color:UIColor)
  {
    self.selectedCircleLayer = makeCircle(color: color)
  }
  
  //this function makes the date number label that is in the center of the cell
  private func makeLabel()
  {
    // add the label
    self.addSubview(dateNumberLabel)
    
    // make sure there are no constraint conflicts
    self.translatesAutoresizingMaskIntoConstraints                 = false
    self.dateNumberLabel.translatesAutoresizingMaskIntoConstraints = false
    
    
    // make anchors
    dateNumberLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
    dateNumberLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
  }
  
  // This function makes the circle that is shown when a cell is selected
  private func makeCircle(color:UIColor) -> CAShapeLayer
  {
    // make circle path
    let circlePath = UIBezierPath(arcCenter: CGPoint(x: self.frame.width/2,y: self.frame.height/2),
                                  radius: (self.frame.width - circleDistanceFromEdge) / 2,
                                  startAngle: CGFloat(0),
                                  endAngle:CGFloat(Double.pi * 2),
                                  clockwise: true)
    
    // make shape layer
    let shapeLayer = CAShapeLayer()
    shapeLayer.path = circlePath.cgPath
    
    // change the fill color
    shapeLayer.fillColor = color.cgColor
    
    // change the stroke color
    shapeLayer.strokeColor = color.cgColor
    
    // change the line width
    shapeLayer.lineWidth = 3.0
    
    return shapeLayer
  }
  
  // INTERNAL FUNCTIONS
  // This function adds the selection circle
  internal func addCircle(layer: CALayer)
  {
    self.layer.insertSublayer(layer, below: dateNumberLabel.layer)
    self.dateNumberLabel.textColor = UIColor.white
  }
  
  // This function removes the selection circle
  internal func deleteCircle(layer: CALayer)
  {
    layer.removeFromSuperlayer()
    self.dateNumberLabel.textColor = UIColor.black
  }
}

public class CalendarCollectionView:UICollectionView,
                                      UICollectionViewDelegate,
                                      UICollectionViewDataSource,
                                      UICollectionViewDelegateFlowLayout
{
  // PRIVATE VARS
  internal let daysPerLine:Int = 7             //This variable holds the amount of cells that are displayed per line
  private var calendarData:[CalendarDay] = []     //This is the data source for the CollectionView
  private var selectedCell:CalendarViewCell? = nil
  private var grayedCellColor:UIColor = UIColor(red: 231/255.0,
                                                green: 232/255.0,
                                                blue: 233/255.0,
                                                alpha: 1.0)
  
  // PUBLIC VARS
  public var currentDate:Date = Date() //The current date of the calendar
  public var cellBackgroundColor:UIColor = UIColor.white   //The background color of the cell
  public var selectedCircleColor:UIColor = UIColor(red:   255/255.0, //The color of circle when the user selects
    green: 51/255.0,
    blue:  51/255.0,
    alpha: 1.0)
  public var selectedCircleDistanceFromEdge:CGFloat = 0.0  //The circle's distance from the edge of the cell
  public var font:UIFont = UIFont.systemFont(ofSize: 12.0) //The font of the cells
  public var calendarViewDelegate:CalendarViewDelegate? = nil
  
  // PUBLIC GET PRIVATE SET VARS
  public private(set) var cellWidth:CGFloat = 0.0 //helps the picker view set frame, dont want the user messing with this
  
  // INITS
  // init from code
  public override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout)
  {
    super.init(frame: frame, collectionViewLayout: layout)
    
    startUp()
  }
  
  // init from StoryBoard
  public required init?(coder aDecoder: NSCoder)
  {
    super.init(coder: aDecoder)
    
    startUp()
  }
  
  // PRIVATE FUNCTIONS
  // This function handles the start up
  private func startUp()
  {
    
    // register cell class and set delgates
    self.register(CalendarViewCell.self, forCellWithReuseIdentifier: "dateBoxCell")
    self.delegate   = self
    self.dataSource = self
    
    // set cell layout data
    let layout = UICollectionViewFlowLayout()
    layout.minimumInteritemSpacing = 0.0
    layout.minimumLineSpacing      = 0.0
    self.collectionViewLayout      = layout
    
    //set background color for cell
    self.backgroundColor = UIColor.white
    
    //set cell circle radius
    self.selectedCircleDistanceFromEdge = 10.0
    
    // get calendar data
    self.reloadDate(newDate: currentDate)
  }
  
  // UICollectionViewDelegate Functions
  public func collectionView(_ collectionView: UICollectionView,
                             cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
  {
    // get cell
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "dateBoxCell", for: indexPath) as? CalendarViewCell
    
    //clear the data to avoid any dequeueing errors
    cell?.deleteCircle(layer: cell!.selectedCircleLayer)
    cell?.backgroundColor = cellBackgroundColor
    cell?.dateNumberLabel.font = font
    cell?.selectedCircleColor = selectedCircleColor
    
    // set the label
    if calendarData[indexPath.row].day == nil // if the cell is a day cell and not a date cell
    {
      if let labelText = calendarData[indexPath.row].labelText
      {
        // only get first three letter of the month
        cell?.dateNumberLabel.text = String(labelText[...labelText.index(labelText.startIndex, offsetBy: 2)])
        
        // bold the month titles
        cell?.dateNumberLabel.font = UIFont.boldSystemFont(ofSize: font.pointSize)
      }
    }
    else // if the cell is a date cell
    {
      if let dayNumber = calendarData[indexPath.row].dayNumber
      {
        cell?.dateNumberLabel.text = "\(dayNumber)"
      }
    }
    
    
    // get the components of today to check if the cell being displayed
    if let pickedDate = self.calendarViewDelegate?.calendarView(currentDateFor: self)
    {
      let components = Calendar.current.dateComponents([.day,.month,.year], from: Date())
      let pickedComponents = Calendar.current.dateComponents([.day,.month,.year], from: pickedDate)
      
      // if the current cell is today's date, increase the font size
      if components.day   == calendarData[indexPath.row].dayNumber       &&
        components.month == calendarData[indexPath.row].month?.rawValue &&
        components.year  == calendarData[indexPath.row].year
      {
        cell?.dateNumberLabel.font = UIFont.boldSystemFont(ofSize: font.pointSize + 7.0)
      }
      
      // if the cell is the same date as from the DatePickerView, put the selected circle on it
      if pickedComponents.day   == calendarData[indexPath.row].dayNumber       &&
        pickedComponents.month == calendarData[indexPath.row].month?.rawValue &&
        pickedComponents.year  == calendarData[indexPath.row].year
      {
        if let selectedCircleLayer = cell?.selectedCircleLayer
        {
          cell?.addCircle(layer: selectedCircleLayer)
          selectedCell = cell
        }
      }
    }
    
    // if the calendar data is not from this month, it should be grayed out slightly
    if calendarData[indexPath.row].grayed
    {
      cell?.backgroundColor = grayedCellColor
    }
    
    // return the cell
    return cell!
  }
  
  // The calendar displays a grid based on the calculated data
  public func collectionView(_ collectionView: UICollectionView,
                             numberOfItemsInSection section: Int) -> Int
  {
    return calendarData.count
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
      let size = (collectionView.bounds.width - spaceToSubtract) / CGFloat(daysPerLine)
      
      // save the cell width for the PickerView to use when resizing the width of the calendar
      self.cellWidth = size.rounded()
      
      // make new size
      cellSize = CGSize(width: size, height: self.frame.height / CGFloat(calendarData.count / daysPerLine))
    }
    
    return cellSize
  }
  
  // allow the user to select a day and change the date listed in the picker view
  public func collectionView(_ collectionView: UICollectionView,
                             didSelectItemAt indexPath: IndexPath)
  {
    let pickedDate = self.calendarViewDelegate?.calendarView(currentDateFor: self) ?? Date()
    
    // get the components from the date in the date picker view
    let components = Calendar.current.dateComponents([.day,.month], from: pickedDate)
    
    // make sure the date is not the date of the date picker view or a label cell
    guard (components.day   == calendarData[indexPath.row].dayNumber &&
      components.month == calendarData[indexPath.row].month?.rawValue) ||
      calendarData[indexPath.row].labelText != nil
      else
    {
      // get the cell that was selected
      let cell = collectionView.cellForItem(at: indexPath) as? CalendarViewCell
      
      if let cell = cell
      {
        // first delete the current selection circle
        self.selectedCell?.deleteCircle(layer: self.selectedCell!.selectedCircleLayer)
        
        // add the new selection circle
        cell.addCircle(layer: cell.selectedCircleLayer)
        
        // inform delegate of change
        var dateComponents   = DateComponents()
        dateComponents.day   = calendarData[indexPath.row].dayNumber
        dateComponents.month = calendarData[indexPath.row].month?.rawValue
        dateComponents.year  = calendarData[indexPath.row].year
        
        if let date = Calendar.current.date(from: dateComponents)
        {
          self.calendarViewDelegate?.calendarView(self, didSelectDate: date)
        }
      }
      return
    }
  }
  
  public func collectionView(_ collectionView: UICollectionView,
                             willDisplay cell: UICollectionViewCell,
                             forItemAt indexPath: IndexPath)
  {
    UIView.performWithoutAnimation {
      cell.layoutIfNeeded()
    }
  }
  
  // PUBLIC FUNCTIONS
  public func reloadDate(newDate:Date)
  {
    calendarData = CalendarUtil.getCalendarData(for: newDate)
    self.currentDate = newDate
    self.reloadData()
  }
  
  public func reloadDateAnimated(newDate:Date)
  {
    calendarData = CalendarUtil.getCalendarData(for: newDate)
    self.currentDate = newDate
    
    self.performBatchUpdates({
      let range = NSMakeRange(0, self.numberOfSections)
      let sections = NSIndexSet(indexesIn: range)
      self.reloadSections(sections as IndexSet)
    }, completion: nil)
  }
}
