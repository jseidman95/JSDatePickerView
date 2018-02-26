//
//  MainViewController.swift
//  JSDatePickerView
//
//  Created by Jesse Seidman on 2/20/18.
//  Copyright © 2018 Jesse Seidman. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, JSDatePickerDelegate
{
  private var js:JSDatePickerView? = nil
  
  func jsDatePicker(_ jsDatePicker: JSDatePickerView,
                    didChangeDateFrom collectionView: UICollectionView)
  {
    print("new date", jsDatePicker.currentDate)
    if collectionView is CalendarCollectionView
    {
      jsDatePicker.collapseCalendar()
    }
  }
  
  override func viewDidLoad()
  {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
    let myFrame = CGRect(x: 0.0,
                         y: 0.0,
                         width: self.view.frame.width,
                         height: 150.0)
    js = JSDatePickerView(frame: myFrame)
    js?.pickerDelegate = self
    self.view.addSubview(js!)
    
    let safeArea = self.view.safeAreaLayoutGuide
    js?.translatesAutoresizingMaskIntoConstraints = false
    js?.topAnchor.constraint(equalTo: safeArea.topAnchor).isActive = true
    js?.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
    js?.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
    
    let myView = UIView(frame: self.view.frame)
    myView.backgroundColor = UIColor.red
    myView.translatesAutoresizingMaskIntoConstraints = false
    
    self.view.addSubview(myView)
    
    myView.topAnchor.constraint(equalTo: js!.bottomAnchor).isActive = true
    myView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
    myView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
    myView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
    
    //js.datePickerHeight = 500.0
  }
}
