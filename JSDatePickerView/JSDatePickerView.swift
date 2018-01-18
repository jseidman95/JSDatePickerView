//
//  JSDatePickerView.swift
//  JSDatePickerView
//
//  Created by Jesse Seidman on 12/26/17.
//  Copyright © 2017 Jesse Seidman. All rights reserved.
//

import UIKit

public protocol JSDatePickerViewDelegate
{
    func handleDateChange()
}

public class JSDatePickerView: UIView
{
    //PRIVATE/INTERNAL VARS
    private  var calendarView:CalendarView? = nil         //holds the reference to the CalendarView
    private  var firstTimeCalendarExpanding :Bool = true  //used to see if the calendar needs to be added or presented
    internal var calendarHeightConstraint   :NSLayoutConstraint = NSLayoutConstraint()
    private  var calendarWidthConstraint    :NSLayoutConstraint = NSLayoutConstraint()
    
    //PUBLIC VARS
    public var calendarPresentingView: UIView? = nil
    public var delegate    : JSDatePickerViewDelegate? = nil
    public let leftButton  : UIButton  = UIButton(type: .custom)
    public let rightButton : UIButton  = UIButton()
    public let centerLabel : UILabel   = UILabel()
    public var swipeLeft  = UISwipeGestureRecognizer()
    public var swipeRight = UISwipeGestureRecognizer()
    public private(set) var isCalendarExpanded:Bool = false //helps with the presentation of the calendar
    public var calendarWidth:CGFloat = 300.0
    public var currentDate:Date = Date()
    {
        didSet { delegate?.handleDateChange() }
    }
    public var cellBackgroundColor: UIColor = UIColor()
    {
        didSet { self.calendarView?.cellBackgroundColor = cellBackgroundColor }
    }
    public var selectedCellCircleColor: UIColor = UIColor()
    {
        didSet { self.calendarView?.selectedCircleColor = selectedCellCircleColor }
    }
    public var selectedCellDistanceFromEdge:CGFloat = 0.0
    {
        didSet { self.calendarView?.selectedCircleDistanceFromEdge = selectedCellDistanceFromEdge }
    }
    public var calendarFont:UIFont = UIFont()
    {
        didSet
        {
            calendarView?.font = calendarFont
        }
    }
    
    //init from code
    public override init(frame: CGRect)
    {
        super.init(frame: frame)

        startUp()
    }
    
    //init from StoryBoard
    public required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        
        startUp()
    }
    
    //PRIVATE FUNCTIONS
    
    //This function handles the start up
    private func startUp()
    {
        //make subviews
        makeDateLabel()
        makeButtons()
        makeCalendar()
        
        //make constraints
        makeConstraints()
        
        //set calendar font
        self.calendarFont = UIFont.systemFont(ofSize: 17.0)
    }
    
    //This function makes the label that shows the current date
    private func makeDateLabel()
    {
        //set the current date
        currentDate = Date()
        
        //set date label text
        setLabelFullDate(date: currentDate)
        
        //add gesture rec to view
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDateTap)))
        
        //add left swipe
        swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(rightButtonAction))
        swipeLeft.direction = .left
        self.addGestureRecognizer(swipeLeft)
        
        //add right swipe
        swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(leftButtonAction))
        swipeRight.direction = .right
        self.addGestureRecognizer(swipeRight)
        
        //add to view
        self.addSubview(centerLabel)
    }
    
    //This function makes the forward and backwards arrow buttons
    private func makeButtons()
    {
        //add images
        leftButton.setImage(UIImage(named: "JSDatePickerView.bundle/arrowLeft",
                                    in: Bundle(for: JSDatePickerView.self),
                                    compatibleWith: nil),
                            for: .normal)
        rightButton.setImage(UIImage(named: "JSDatePickerView.bundle/arrowRight",
                                     in: Bundle(for: JSDatePickerView.self),
                                     compatibleWith: nil),
                             for: .normal)
        
        //add actions
        leftButton.addTarget(self,  action: #selector(leftButtonAction),  for: .touchUpInside)
        rightButton.addTarget(self, action: #selector(rightButtonAction), for: .touchUpInside)
        
        //add to view
        self.addSubview(leftButton)
        self.addSubview(rightButton)
    }
    
    //the function that handles the back action
    @objc public func leftButtonAction()
    {
        addValueToDate(value: -1, left: true)
    }
    
    //the function that handles the forward action
    @objc public func rightButtonAction()
    {
        addValueToDate(value: 1, left: false)
    }
    
    private func addValueToDate(value:Int, left: Bool)
    {
        if self.isCalendarExpanded
        {
            //go back a month and reload the date with animation so the user can see
            if let calDate = calendarView?.currentDate
            {
                if let newDate =  Calendar.current.date(byAdding: .month, value: value, to: calDate)
                {
                    calendarView?.reloadDateAnimated(newDate: newDate)
                    move(left: left, month: true, date: newDate)
                }
            }
        }
        else //set the current date and reload the calendar date without animation
        {
            if let newDate = Calendar.current.date(byAdding: .day, value: value, to: currentDate)
            {
                currentDate = newDate
                calendarView?.reloadDate(newDate: newDate)
                move(left: left, month: false, date: currentDate)
            }
        }
    }
    
    //This function makes the CalendarView object which will get added later
    private func makeCalendar()
    {
        //make CalendarView
        calendarView = CalendarView(frame: CGRect(x: 0.0, y: 0.0,
                                    width: self.frame.width, height: 50.0),
                                    collectionViewLayout: UICollectionViewFlowLayout())
        
        //pass reference to self so the calendarview can use the buttons...
        calendarView?.parent = self
    }
    
    //The CalendarView object gets its own function because its constraints rely heavily on the superview
    //and this function is only called when a superview is definetly non-nil
    private func addCalendar()
    {
        if let calendarView = calendarView
        {
            //ensure constraints
            calendarView.translatesAutoresizingMaskIntoConstraints = false
            
            //add it to superview before so constraints will be applied
            self.calendarPresentingView?.addSubview(calendarView)
            
            //make the constraints
            let calendarCenterConstraint = NSLayoutConstraint(item: calendarView,
                                                              attribute: .centerX,
                                                              relatedBy: .equal,
                                                              toItem: centerLabel,
                                                              attribute: .centerX,
                                                              multiplier: 1.0,
                                                              constant: 0.0)
            let calendarTopConstraint    = NSLayoutConstraint(item: calendarView,
                                                              attribute: .top,
                                                              relatedBy: .equal,
                                                              toItem: self,
                                                              attribute: .bottom,
                                                              multiplier: 1.0,
                                                              constant: 5.0)
            
            //make the other constraints which help size and hide the calendar
            calendarWidthConstraint  = NSLayoutConstraint(item: calendarView,
                                                          attribute: .width,
                                                          relatedBy: .equal,
                                                          toItem: nil,
                                                          attribute: .notAnAttribute,
                                                          multiplier: 1.0,
                                                          constant: calendarWidth)
            calendarHeightConstraint = NSLayoutConstraint(item: calendarView,
                                                          attribute: .height,
                                                          relatedBy: .equal,
                                                          toItem: nil,
                                                          attribute: .notAnAttribute,
                                                          multiplier: 1.0,
                                                          constant: 0.0)
            
            //add all the constraints
            self.calendarPresentingView?.addConstraints([calendarCenterConstraint,
                                            calendarTopConstraint,
                                            calendarWidthConstraint,
                                            calendarHeightConstraint])
      
            //make sure layout applies the constraints
            self.calendarPresentingView?.layoutIfNeeded()
        }
    }
    
    //This function makes the constraints all for elements except for the calendarView
    private func makeConstraints()
    {
        //make sure constraints dont conflict
        leftButton.translatesAutoresizingMaskIntoConstraints         = false
        rightButton.translatesAutoresizingMaskIntoConstraints        = false
        centerLabel.translatesAutoresizingMaskIntoConstraints        = false
        
        //make constraints
        let arrowLeftCenterYConstraint   = NSLayoutConstraint(item: leftButton,
                                                              attribute: .centerY,
                                                              relatedBy: .equal,
                                                              toItem: self,
                                                              attribute: .centerY,
                                                              multiplier: 1.0,
                                                              constant: 0.0)
        let arrowRightCenterYConstraint  = NSLayoutConstraint(item: rightButton,
                                                              attribute: .centerY,
                                                              relatedBy: .equal,
                                                              toItem: self,
                                                              attribute: .centerY,
                                                              multiplier: 1.0,
                                                              constant: 0.0)
        let arrowLeftXConstraint         = NSLayoutConstraint(item: leftButton,
                                                              attribute: .leading,
                                                              relatedBy: .equal,
                                                              toItem: self,
                                                              attribute: .leading,
                                                              multiplier: 1.0,
                                                              constant: 5.0)
        let arrowRightXConstraint        = NSLayoutConstraint(item: rightButton,
                                                              attribute: .trailing,
                                                              relatedBy: .equal,
                                                              toItem: self,
                                                              attribute: .trailing,
                                                              multiplier: 1.0,
                                                              constant: -5.0)
        let arrowLeftHeightConstraint    = NSLayoutConstraint(item: leftButton,
                                                              attribute: .height,
                                                              relatedBy: .equal,
                                                              toItem: nil,
                                                              attribute: .notAnAttribute,
                                                              multiplier: 1.0,
                                                              constant: 25.0)
        let arrowRightHeightConstraint   = NSLayoutConstraint(item: rightButton,
                                                              attribute: .height,
                                                              relatedBy: .equal,
                                                              toItem: nil,
                                                              attribute: .notAnAttribute,
                                                              multiplier: 1.0,
                                                              constant: 25.0)
        let arrowLeftAspectConstraint    = NSLayoutConstraint(item: leftButton,
                                                              attribute: .width,
                                                              relatedBy: .equal,
                                                              toItem: leftButton,
                                                              attribute: .height,
                                                              multiplier: 1.0,
                                                              constant: 0.0)
        let arrowRightAspectConstraint   = NSLayoutConstraint(item: rightButton,
                                                              attribute: .width,
                                                              relatedBy: .equal,
                                                              toItem: rightButton,
                                                              attribute: .height,
                                                              multiplier: 1.0,
                                                              constant: 0.0)
        let centerLabelCenterYConstraint = NSLayoutConstraint(item: centerLabel,
                                                              attribute: .centerY,
                                                              relatedBy: .equal,
                                                              toItem: self,
                                                              attribute: .centerY,
                                                              multiplier: 1.0,
                                                              constant: 0.0)
        let centerLabelCenterXConstraint = NSLayoutConstraint(item: centerLabel,
                                                              attribute: .centerX,
                                                              relatedBy: .equal,
                                                              toItem: self,
                                                              attribute: .centerX,
                                                              multiplier: 1.0,
                                                              constant: 0.0)
        
        //add constraints
        self.addConstraints([arrowLeftAspectConstraint,
                             arrowLeftHeightConstraint,
                             arrowLeftHeightConstraint,
                             arrowRightHeightConstraint,
                             arrowRightAspectConstraint,
                             arrowLeftXConstraint,
                             arrowRightXConstraint,
                             arrowLeftCenterYConstraint,
                             arrowRightCenterYConstraint,
                             centerLabelCenterYConstraint,
                             centerLabelCenterXConstraint])
    }
    
    private func switchLabelText(month: Bool, date: Date)
    {
        let originalY = self.centerLabel.frame.origin.y
        
        UIView.animate(withDuration: 0.15, animations: {
            self.centerLabel.frame.origin.y = month ? self.frame.minY : self.frame.maxY - self.centerLabel.frame.height
            self.centerLabel.alpha = 0.0
        }, completion: {
            _ in
            month ? self.setLabelMonth(date: date) : self.setLabelFullDate(date: date)
            self.centerLabel.frame.origin.y = month ? self.frame.maxY - self.centerLabel.frame.height : self.frame.minY
            UIView.animate(withDuration: 0.15, animations: {
                self.centerLabel.frame.origin.y = originalY
                self.centerLabel.alpha = 1.0
            })
        })
    }
    
    private func setLabelFullDate(date:Date)
    {
        let components = Calendar.current.dateComponents(in: .current, from: date)
        if let day = components.day, let month = components.month, let year = components.year, let weekDay = components.weekday
        {
            if let weekDayEnumVal = DayEnum(rawValue: weekDay), let monthEnumVal = MonthEnum(rawValue: month)
            {
                self.centerLabel.text = "\(weekDayEnumVal.description), \(monthEnumVal.description) \(day)\(DayEnum.getSuffix(dayNumber: day)), \(year)"
            }
        }
    }
    
    private func setLabelMonth(date:Date)
    {
        let components = Calendar.current.dateComponents(in: .current, from: date)
        
        if let month = components.month, let year = components.year
        {
            if let monthEnumVal = MonthEnum(rawValue: month)
            {
                self.centerLabel.text = "\(monthEnumVal.description) \(year)"
            }
        }
    }
    
    private func move(left:Bool, month:Bool, date: Date)
    {
        let components = Calendar.current.dateComponents(in: .current, from: date)
        
        if let d = components.day, let m = components.month, let y = components.year, let wd = components.weekday
        {
            if let weekDayEnumVal = DayEnum(rawValue: wd), let monthEnumVal = MonthEnum(rawValue: m)
            {
                let originalX = self.centerLabel.frame.origin.x
                
                UIView.animate(withDuration: 0.15, animations: {
                    self.centerLabel.frame.origin.x = left ? self.frame.maxX : self.frame.minX
                    self.centerLabel.alpha = 0.0
                }, completion: {
                    _ in
                    
                    if month
                    {
                        self.centerLabel.text = "\(monthEnumVal.description) \(y)"
                    }
                    else
                    {
                        self.centerLabel.text = "\(weekDayEnumVal.description), \(monthEnumVal.description) \(d)\(DayEnum.getSuffix(dayNumber: d)), \(y)"
                    }
                    self.centerLabel.frame.origin.x = left ? self.frame.minX : self.frame.maxX
                    UIView.animate(withDuration: 0.15, animations: {
                        self.centerLabel.frame.origin.x = originalX
                        self.centerLabel.alpha = 1.0
                    })
                })
            }
        }
    }

    @objc private func handleDateTap()
    {
        if let calendarView = calendarView
        {
            //if the calendar has never been added to the superview, add it
            if firstTimeCalendarExpanding
            {
                addCalendar()
                
                //make sure the calendar is the correct width and no spaces are in between
                self.calendarWidthConstraint.constant = calendarView.cellWidth * 7
                
                firstTimeCalendarExpanding = !firstTimeCalendarExpanding
            }
            
            //change the value of the height constraint
            if self.isCalendarExpanded == false
            {
                expandCalendar()
            }
            else
            {
                collapseCalendar()
            }
        }
    }
    
    //PUBLIC FUNCTIONS
    
    public func expandCalendar()
    {
        switchLabelText(month: true, date: currentDate)
        
        //make sure the right calendar data is shown
        calendarView?.reloadDate(newDate: currentDate)
        calendarView?.layoutIfNeeded()
        
        if let contentHeight = calendarView?.contentSize.height
        {
            self.calendarHeightConstraint.constant = contentHeight
        }
        
        self.isCalendarExpanded = true
        
        UIView.animate(withDuration: 0.2, animations: {
            self.calendarPresentingView?.layoutIfNeeded()
        })
    }
    
    public func collapseCalendar()
    {
        switchLabelText(month: false, date: currentDate)
        self.calendarHeightConstraint.constant = 0
        self.isCalendarExpanded = false
        
        UIView.animate(withDuration: 0.2, animations: {
            self.calendarPresentingView?.layoutIfNeeded()
        })
    }
}
