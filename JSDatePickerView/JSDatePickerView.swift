//
//  JSDatePickerView.swift
//  JSDatePickerView
//
//  Created by Jesse Seidman on 12/26/17.
//  Copyright © 2017 Jesse Seidman. All rights reserved.
//

import UIKit
import EAInfiniteScrollView

public class JSDatePickerView: UIView,InfiniteScrollViewDataSource
{
  // PRIVATE VARS
  private var scrollView = InfiniteScrollView()
  
  // PUBLIC VARS
  
  // INITS
  public override init(frame: CGRect)
  {
    super.init(frame: frame)
    
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
    // set data source for scrollview
    self.scrollView.infiniteDelegate = self
    
    self.addSubview(scrollView)
    
    
  }
  
  // InfiniteScrollViewDataSource
  public func infiniteItemForDirection(_ direction: direction) -> UIView
  {
    switch direction
    {
      case .left:
        print("LEFT")
      case .right:
        print("RIGHT")
    }
    
    return UIView()
  }
}
