//
//  DateHeaderView.swift
//  JSDatePickerView
//
//  Created by Jesse Seidman on 2/1/18.
//  Copyright © 2018 Jesse Seidman. All rights reserved.
//

import UIKit

public class DateHeaderView: UICollectionReusableView
{
  // PRIVATE VARS
  private var dateLabel: UILabel = UILabel()
  
  // INITS
  // init from code
  override init(frame: CGRect)
  {
    super.init(frame: frame)
    
    startUp()
  }
  
  // init from StoryBoard
  public required init?(coder aDecoder: NSCoder)
  {
    super.init(coder: aDecoder)
    
    startUp()
  }
  
  private func startUp()
  {
    // set date label data
    self.dateLabel.text = "Holder Text"
    
    // set header view data
    self.backgroundColor = UIColor.blue
    
    // add date label
    self.addSubview(dateLabel)
    
    // make sure constraints stick
    self.dateLabel.translatesAutoresizingMaskIntoConstraints = false
    
    // add constraints
    self.dateLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
    self.dateLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
  }
}
