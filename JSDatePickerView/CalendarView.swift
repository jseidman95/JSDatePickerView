//
//  CalendarView.swift
//  JSDatePickerView
//
//  Created by Jesse Seidman on 12/26/17.
//  Copyright © 2017 Jesse Seidman. All rights reserved.
//

import UIKit

//This class is the cell that holds the day data in the CollectionView
class CalendarViewCell:UICollectionViewCell
{
    //FILEPRIVATE VARS
    fileprivate let dateNumberLabel        : UILabel      = UILabel()      //The label that holds the date number
    fileprivate var circleDistanceFromEdge : CGFloat = 0.0                 //Customize the circle radius
    fileprivate var todayCircleLayer       : CAShapeLayer = CAShapeLayer() //The circle that is shown on today's cell
    fileprivate var selectedCircleLayer    : CAShapeLayer = CAShapeLayer() //The circle that is shown on selection

    fileprivate var selectedCircleColor    : UIColor = UIColor.red
    {
        didSet {self.setSelectedCircleColor(selectedCircleColor)}
    }
    
    //init from StoryBoard
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        
        startUp()
    }
    
    //init from code
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        startUp()
    }

    //PRIVATE FUNCTIONS
    
    private func startUp()
    {
        //make the label
        makeLabel()
        
        //make and store the circle layer
        self.selectedCircleColor = UIColor.brown
        self.circleDistanceFromEdge = 10.0
        
        //make the default border
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    private func setSelectedCircleColor(_ color:UIColor)
    {
        self.selectedCircleLayer = makeCircle(color: color)
    }
    private func setTodayCircleColor(_ color:UIColor)
    {
        self.todayCircleLayer = makeCircle(color: color)
    }
    //this function makes the date number label that is in the center of the cell
    private func makeLabel()
    {
        //add the label
        self.addSubview(dateNumberLabel)
        
        //make sure there are no constraint conflicts
        self.translatesAutoresizingMaskIntoConstraints                 = false
        self.dateNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        
        //make constraints
        let centerXConstraint = NSLayoutConstraint(item: dateNumberLabel,
                                                   attribute: .centerX,
                                                   relatedBy: .equal,
                                                   toItem: self,
                                                   attribute: .centerX,
                                                   multiplier: 1.0,
                                                   constant: 0.0)
        let centerYConstraint = NSLayoutConstraint(item: dateNumberLabel,
                                                   attribute: .centerY,
                                                   relatedBy: .equal,
                                                   toItem: self,
                                                   attribute: .centerY,
                                                   multiplier: 1.0,
                                                   constant: 0.0)
        
        //add constraints
        self.addConstraint(centerXConstraint)
        self.addConstraint(centerYConstraint)
    }
    
    //This function makes the circle that is shown when a cell is selected
    private func makeCircle(color:UIColor) -> CAShapeLayer
    {
        //make circle path
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: self.frame.width/2,y: self.frame.height/2),
                                      radius: (self.frame.width - circleDistanceFromEdge) / 2,
                                      startAngle: CGFloat(0),
                                      endAngle:CGFloat(Double.pi * 2),
                                      clockwise: true)
        
        //make shape layer
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
        
        //change the fill color
        shapeLayer.fillColor = color.cgColor
        
        //change the stroke color
        shapeLayer.strokeColor = color.cgColor
        
        //change the line width
        shapeLayer.lineWidth = 3.0
        
        return shapeLayer
    }
    
    //FILEPRIVATE FUNCTIONS
    //This function adds the selection circle
    fileprivate func addCircle(layer: CALayer)
    {
        self.layer.insertSublayer(layer, below: dateNumberLabel.layer)
        self.dateNumberLabel.textColor = UIColor.white
    }
    
    //This function removes the selection circle
    fileprivate func deleteCircle(layer: CALayer)
    {
        layer.removeFromSuperlayer()
        self.dateNumberLabel.textColor = UIColor.black
    }
}

//This class contains the CollectionView that makes up the calendar
class CalendarView:UICollectionView,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout
{
    //PRIVATE VARS
    
    private let daysPerLine:Int = 7
    private var selectedCell:CalendarViewCell? = nil
    private var calendarData:[CalendarDay] = []
    
    //PUBLIC GET PRIVATE SET VARS
    
    public private(set) var cellWidth:CGFloat = 0.0 //helps the picker view set frame
    
    //PUBLIC VARS
    
    public var cellBackgroundColor:UIColor = UIColor.white
    public var grayedCellColor:UIColor = UIColor(red: 231/255.0,
                                                 green: 232/255.0,
                                                 blue: 233/255.0,
                                                 alpha: 1.0)
    public var todayCircleColor:UIColor    = UIColor.purple
    public var selectedCircleColor:UIColor = UIColor.yellow
    public var circleDistanceFromEdge:CGFloat = 0.0
    public var parent:JSDatePickerView? = nil
    public var font:UIFont = UIFont()
    public var currentDate:Date = Date()
    
    //init from code
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout)
    {
        super.init(frame: frame, collectionViewLayout: layout)
    
        startUp()
    }
    
    //init from StoryBoard
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        
        startUp()
    }

    //PRIVATE FUNCTIONS
    
    //This function handles the start up
    private func startUp()
    {
        //register cell class and set delgates
        self.register(CalendarViewCell.self, forCellWithReuseIdentifier: "dateBoxCell")
        self.delegate   = self
        self.dataSource = self
        
        //set cell layout data
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0.0
        layout.minimumLineSpacing      = 0.0
        self.collectionViewLayout      = layout
        
        //set background color for cell
        self.backgroundColor = UIColor.white
        
        //set cell circle radius
        self.circleDistanceFromEdge = 10.0
        
        //get calendar data
        self.calendarData = CalendarUtil.getCalendarData(for: currentDate)
        
        //make rounded corners
        self.layer.cornerRadius = 20.0
        self.layer.borderColor  = UIColor.lightGray.cgColor
        self.layer.borderWidth  = 1.0
    }

    //UICollectionViewDelegate Functions
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        //get cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "dateBoxCell", for: indexPath) as? CalendarViewCell
        
        //clear the data to avoid any dequeueing errors
        cell?.deleteCircle(layer: cell!.todayCircleLayer)
        cell?.deleteCircle(layer: cell!.selectedCircleLayer)
        cell?.backgroundColor = cellBackgroundColor
        cell?.dateNumberLabel.font = font
        cell?.selectedCircleColor = selectedCircleColor
        
        //set the label
        if calendarData[indexPath.row].day == nil
        {
            if let labelText = calendarData[indexPath.row].labelText
            {
                cell?.dateNumberLabel.text = String(labelText[...labelText.index(labelText.startIndex, offsetBy: 2)])
                cell?.dateNumberLabel.font = UIFont.boldSystemFont(ofSize: font.pointSize)
            }
        }
        else
        {
            if let dayNumber = calendarData[indexPath.row].dayNumber
            {
                cell?.dateNumberLabel.text = "\(dayNumber)"
            }
        }
        
        
        //get the components of today to check if the cell being displayed
        let components = Calendar.current.dateComponents([.day,.month,.year], from: Date())
        let componentsSelected = Calendar.current.dateComponents([.day,.month,.year], from: (self.parent?.currentDate)!)
        
        if components.day   == calendarData[indexPath.row].dayNumber       &&
           components.month == calendarData[indexPath.row].month?.rawValue &&
           components.year  == calendarData[indexPath.row].year
        {
            cell?.dateNumberLabel.font = UIFont.boldSystemFont(ofSize: font.pointSize + 3.0)
        }
        else if componentsSelected.day   == calendarData[indexPath.row].dayNumber       &&
                componentsSelected.month == calendarData[indexPath.row].month?.rawValue &&
                componentsSelected.year  == calendarData[indexPath.row].year
        {
            cell?.addCircle(layer: (cell?.selectedCircleLayer)!)
        }

        
        //if the calendar data is not from this month, it should be grayed out slightly
        if calendarData[indexPath.row].grayed
        {
            cell?.backgroundColor = grayedCellColor
        }

        //return the cell
        return cell!
    }
    
    //The calendar displays a grid based on the calculated data
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return calendarData.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        var cellSize = CGSize()
        
        //get flow layout
        let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout
        
        if let flowLayout = flowLayout
        {
            //calculate the amount of space to account for when getting the width of the cells
            let spaceToSubtract = flowLayout.sectionInset.left  +
                                  flowLayout.sectionInset.right +
                                  (flowLayout.minimumInteritemSpacing * CGFloat(daysPerLine - 1))
            
            //The size of the height and width of the cell
            let size = (collectionView.bounds.width - spaceToSubtract) / CGFloat(daysPerLine)
            
            //save the cell width for the PickerView to use when resizing the width of the calendar
            self.cellWidth = size.rounded()
            
            //make new size
            cellSize = CGSize(width: size, height: size)
        }
        
        return cellSize
    }
    
    //allow the user to select a day and change the date listed in the picker view
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        let components = Calendar.current.dateComponents([.day,.month], from: currentDate)
        
        guard (components.day   == calendarData[indexPath.row].dayNumber &&
               components.month == calendarData[indexPath.row].month?.rawValue) ||
               calendarData[indexPath.row].labelText != nil
        else
        {
            let cell = collectionView.cellForItem(at: indexPath) as? CalendarViewCell
            
            if let cell = cell
            {
                if selectedCell == nil
                {
                    cell.addCircle(layer: cell.selectedCircleLayer)
                    selectedCell = cell
                }
                else if cell == selectedCell
                {
                    cell.deleteCircle(layer: cell.selectedCircleLayer)
                    selectedCell = nil
                }
                else
                {
                    selectedCell?.deleteCircle(layer: selectedCell!.selectedCircleLayer)
                    cell.addCircle(layer: cell.selectedCircleLayer)
                    selectedCell = cell
                }
            }
            return
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath)
    {
        UIView.performWithoutAnimation {
            cell.layoutIfNeeded()
        }
    }
    
    //PUBLIC FUNCTIONS
    
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
        }, completion: {
            _ in
            self.parent?.updateHeight()
        })
    }
}
