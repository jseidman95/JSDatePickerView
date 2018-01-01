//
//  JSDatePickerView.swift
//  JSDatePickerView
//
//  Created by Jesse Seidman on 12/26/17.
//  Copyright © 2017 Jesse Seidman. All rights reserved.
//

import UIKit

class JSDatePickerView: UIView
{
    //PRIVATE VARS
    
    //Calendar Vars
    private var calendarView:CalendarView? = nil         //holds the reference to the CalendarView
    private var firstTimeCalendarExpanding :Bool = true  //used to see if the calendar needs to be added or presented
    private var calendarHeightConstraint   :NSLayoutConstraint = NSLayoutConstraint()
    private var calendarWidthConstraint    :NSLayoutConstraint = NSLayoutConstraint()
    
    //Date vars
    public var currentDate:Date = Date()
    
    public var calendarFont:UIFont = UIFont()
    {
        didSet
        {
            calendarView?.font = calendarFont
        }
    }
    
    //PUBLIC VARS
    public let leftButton  : UIButton  = UIButton(type: .custom)
    public var isCalendarExpanded:Bool = false //helps witht the presentation of the calendar
    public let rightButton : UIButton  = UIButton()
    public let centerLabel : UILabel   = UILabel()
    
    //init from code
    override init(frame: CGRect)
    {
        super.init(frame: frame)

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
        
        //set label text
        let components = Calendar.current.dateComponents(in: .current, from: currentDate)
        self.centerLabel.text = "\(components.month!)/\(components.day!)/\(components.year!)"
        
        //add to view
        self.addSubview(centerLabel)
    }
    
    //This function makes the forward and backwards arrow buttons
    private func makeButtons()
    {
        //add images
        leftButton.setImage(#imageLiteral(resourceName: "arrowLeft"), for: .normal)
        rightButton.setImage(#imageLiteral(resourceName: "arrowRight"), for: .normal)
        
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
        if self.isCalendarExpanded
        {
            let newDate = Calendar.current.date(byAdding: .month, value: -1, to: (calendarView?.currentDate)!)! 
            calendarView?.reloadDateAnimated(newDate: newDate)

            let components = Calendar.current.dateComponents(in: .current, from: newDate)
            self.centerLabel.text = "\(MonthEnum(rawValue: components.month!)!.description) \(components.year!)"
        }
        else
        {
            let newDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate)!
            currentDate = newDate
            calendarView?.reloadDate(newDate: newDate)
            
            let components = Calendar.current.dateComponents(in: .current, from: newDate)
            self.centerLabel.text = "\(components.month!)/\(components.day!)/\(components.year!)"
        }
    }
    
    //the function that handles the forward action
    @objc public func rightButtonAction()
    {
        
        if self.isCalendarExpanded
        {
            let newDate = Calendar.current.date(byAdding: .month, value: 1, to: (calendarView?.currentDate)!)!
            calendarView?.reloadDateAnimated(newDate: newDate)
            
            let components = Calendar.current.dateComponents(in: .current, from: newDate)
            self.centerLabel.text = "\(MonthEnum(rawValue: components.month!)!.description) \(components.year!)"
        }
        else
        {
            let newDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
            currentDate = newDate
            calendarView?.reloadDate(newDate: newDate)
            
            let components = Calendar.current.dateComponents(in: .current, from: newDate)
            self.centerLabel.text = "\(components.month!)/\(components.day!)/\(components.year!)"
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
            self.superview?.addSubview(calendarView)
            
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
                                                          constant: self.frame.width >= 500.0 ? 500.0 :
                                                                                                self.frame.width - 50.0)
            calendarHeightConstraint = NSLayoutConstraint(item: calendarView,
                                                          attribute: .height,
                                                          relatedBy: .equal,
                                                          toItem: nil,
                                                          attribute: .notAnAttribute,
                                                          multiplier: 1.0,
                                                          constant: 0.0)
            
            //add all the constraints
            self.superview?.addConstraints([calendarCenterConstraint,
                                            calendarTopConstraint,
                                            calendarWidthConstraint,
                                            calendarHeightConstraint])
      
            //make sure layout applies the constraints
            self.superview?.layoutIfNeeded()
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
                                                              constant: 20.0)
        let arrowRightHeightConstraint   = NSLayoutConstraint(item: rightButton,
                                                              attribute: .height,
                                                              relatedBy: .equal,
                                                              toItem: nil,
                                                              attribute: .notAnAttribute,
                                                              multiplier: 1.0,
                                                              constant: 20.0)
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        calendarView?.reloadDate(newDate: currentDate)
        
        if let calendarView = calendarView
        {
            //set calendar date
            calendarView.currentDate = currentDate
            
            //if the calendar has never been added to the superview, add it
            if firstTimeCalendarExpanding
            {
                addCalendar()
                firstTimeCalendarExpanding = !firstTimeCalendarExpanding
                
                //make sure the right calendar data is shown
                calendarView.reloadData()
            }
            
            //change the value of the height constraint
            self.calendarHeightConstraint.constant = (self.isCalendarExpanded == false ?
                                                                                 calendarView.contentSize.height :
                                                                                 0.0)
            
            let components = Calendar.current.dateComponents(in: .current, from: currentDate)
            self.centerLabel.text = (self.isCalendarExpanded == false ?
                                                                "\(MonthEnum(rawValue: components.month!)!.description) \(components.year!)" :
                                                                "\(components.month!)/\(components.day!)/\(components.year!)")
            
            //make sure the calendar is the correct width and no spaces are in between
            self.calendarWidthConstraint.constant = calendarView.cellWidth * 7
  
            self.isCalendarExpanded = !self.isCalendarExpanded
            
            //animate the layoutIfNeeded because that is what will change the height
            UIView.animate(withDuration: 0.2, animations: {
                self.superview?.layoutIfNeeded()
            })
        }
    }
    
    //PUBLIC FUNCTIONS
    
    public func updateHeight()
    {
        self.calendarHeightConstraint.constant = (calendarView?.contentSize.height)!
        self.superview?.layoutIfNeeded()
    }
}
