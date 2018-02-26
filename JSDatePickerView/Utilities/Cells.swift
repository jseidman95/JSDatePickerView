//
//  Cells.swift
//  JSDatePickerView
//
//  Created by Jesse Seidman on 2/1/18.
//  Copyright © 2018 Jesse Seidman. All rights reserved.
//

import UIKit

public class DateCell: UICollectionViewCell
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
  
  internal func setSelectedCircle()
  {
    self.selectedCircleLayer = makeCircle(color: self.selectedCircleColor)
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
                                  radius: (self.frame.height - circleDistanceFromEdge) / 2,
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
