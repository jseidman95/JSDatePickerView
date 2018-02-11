//
//  Cells.swift
//  JSDatePickerView
//
//  Created by Jesse Seidman on 2/1/18.
//  Copyright © 2018 Jesse Seidman. All rights reserved.
//

import UIKit

public class DateTestCell: UICollectionViewCell
{
  // PUBLIC VARS
  public var dateLabel: UILabel = UILabel()
  
  // INITS
  // init from code
  public override init(frame: CGRect)
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
    self.addSubview(dateLabel)
    
    dateLabel.translatesAutoresizingMaskIntoConstraints = false
    
    dateLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
    dateLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
  }
}
