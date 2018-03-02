//
//  DatePickerCollectionView.swift
//  JSDatePickerView
//
//  Created by Jesse Seidman on 2/14/18.
//  Copyright © 2018 Jesse Seidman. All rights reserved.
//

import UIKit

public class DatePickerCollectionView: UICollectionView,
                                UICollectionViewDelegate,
                                UICollectionViewDataSource,
                                UICollectionViewDelegateFlowLayout
{
  // PUBLIC VARS
  public var font:UIFont = UIFont.systemFont(ofSize: 17.0)
  
  // INTERNAl VARS
  internal var dateArray:[Date] = []
  internal var dualScrollDelegate:DualCollectionViewScrollDelegate? = nil
  internal var touchTransferDelegate:CollectionViewTouchTransferDelegate? = nil
  internal var currentDate = Date()
  internal var preloadedCellCount:Int = 50
  internal var pickerMode:Calendar.Component = .day
  
  // INITS
  override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout)
  {
    super.init(frame: frame, collectionViewLayout: layout)
    
    self.startUp()
  }
  
  public required init?(coder aDecoder: NSCoder)
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
    self.register(DateCell.self, forCellWithReuseIdentifier: "dateCell")

    // set cell layout data
    let layout = UICollectionViewFlowLayout()
    layout.minimumInteritemSpacing = 0.0
    layout.minimumLineSpacing      = 0.0
    layout.scrollDirection         = .horizontal
    self.collectionViewLayout      = layout
    
    addGradientMask()
  }
  
  internal func loadData()
  {
    dateArray = []
    for i in stride(from: preloadedCellCount, through: 1, by: -1) // add previous days
    {
      dateArray.append(Calendar.current.date(byAdding: pickerMode, value: -1 * i, to: currentDate)!)
    }
    dateArray.append(currentDate) // add current day
    for i in 1...preloadedCellCount
    {
      dateArray.append(Calendar.current.date(byAdding: pickerMode, value: i, to: currentDate)!)
    }
  }
  
  private func shiftDateArray(diff:Int)
  {
    if diff > 0
    {
      for i in 0..<dateArray.count
      {
        if i + diff < dateArray.count
        {
          dateArray[i] = dateArray[i + diff]
        }
        else
        {
          dateArray[i] = Calendar.current.date(byAdding: pickerMode, value: 1, to: dateArray[i-1])!
        }
      }
    }
    else
    {
      for i in stride(from: dateArray.count-1, through: 0, by: -1)
      {
        if i + diff >= 0
        {
          dateArray[i] = dateArray[i + diff]
        }
        else
        {
          dateArray[i] = Calendar.current.date(byAdding: pickerMode, value: -1, to: dateArray[i+1])!
        }
      }
    }
    
    self.reloadData()
  }
  
  // UICollectionViewDataSource
  public func collectionView(_ collectionView: UICollectionView,
                      numberOfItemsInSection section: Int) -> Int
  {
    return dateArray.count
  }
  
  public func collectionView(_ collectionView: UICollectionView,
                      cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
  {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "dateCell", for: indexPath) as? DateCell
    
    cell?.dateLabel.font = font
    cell?.dateLabel.text = dateArray[indexPath.row].getString(from: pickerMode == .day ?
                                                                                      "EEEE, MMM d, yyyy" :
                                                                                      "MMMM yyyy")
    
    return cell!
  }
  
  // UICollectionViewDelegateFlowLayout
  public func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize
  {
    return self.frame.size
  }
  
  // UICollectionViewDelegate
  public func collectionView(_ collectionView: UICollectionView,
                             didSelectItemAt indexPath: IndexPath)
  {
    touchTransferDelegate?.collectionView(collectionView, didSelectItemAt: indexPath)
  }
  
  // UIScrollViewDelegate
  public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
  {
    // set new currentDate
    currentDate = dateArray[Int(self.contentOffset.x / self.frame.width)]

    // calculated difference from middle
    let diff = Int(self.contentOffset.x / self.frame.width) - dateArray.count / 2
    
    self.shiftAndScroll(diff: diff)
    
    dualScrollDelegate?.collectionViewDidEndScroll(self, withDifferenceOf: diff)
  }
  
  public func scrollViewDidScroll(_ scrollView: UIScrollView)
  {
    self.mask?.frame = self.bounds
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
    self.scrollToItem(at: IndexPath(row: dateArray.count/2, section: 0),
                      at: .centeredHorizontally,
                      animated: false)
  }
  
  private func addGradientMask()
  {
    let coverView = GradientView(frame: self.bounds)
    let coverLayer = coverView.layer as! CAGradientLayer
    coverLayer.colors = [UIColor.white.withAlphaComponent(0.4).cgColor,
                         UIColor.white.cgColor,
                         UIColor.white.cgColor,
                         UIColor.white.withAlphaComponent(0.4).cgColor]
    coverLayer.locations = [0.0, 0.1, 0.9, 1.0]
    coverLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
    coverLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
    self.mask = coverView
  }
}

class GradientView: UIView
{
  override class var layerClass: AnyClass
  {
    return CAGradientLayer.self
  }
}
