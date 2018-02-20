//
//  DatePickerCollectionView.swift
//  JSDatePickerView
//
//  Created by Jesse Seidman on 2/14/18.
//  Copyright © 2018 Jesse Seidman. All rights reserved.
//

import UIKit

class DatePickerCollectionView: UICollectionView,
                                UICollectionViewDelegate,
                                UICollectionViewDataSource,
                                UICollectionViewDelegateFlowLayout
{
  // PUBLIC VARS
  public var currentDate = Date()
  public var preloadedCellCount:Int = 50
  public var pickerMode:Calendar.Component = .month
  public var dualScrollDelegate:DualCollectionViewScrollDelegate? = nil
  public var touchTransferDelegate:CollectionViewTouchTransferDelegate? = nil
  
  // INTERNAl VARS
  internal var dateArray:[Date] = []
  
  // INITS
  override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout)
  {
    super.init(frame: frame, collectionViewLayout: layout)
    
    self.startUp()
  }
  
  required init?(coder aDecoder: NSCoder)
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
    
    // get data
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
//    // get current cell data
//    let currentCell = self.visibleCells[0]
//    let currentIndexPath = self.indexPath(for: currentCell)
//
//    // set new currentDate
//    currentDate = dateArray[(currentIndexPath?.row)!]
//
//    // calculated difference from middle
//    let diff = (currentIndexPath?.row)! - dateArray.count / 2

    print("date diff \(diff)")
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
  func collectionView(_ collectionView: UICollectionView,
                      numberOfItemsInSection section: Int) -> Int
  {
    return dateArray.count
  }
  
  func collectionView(_ collectionView: UICollectionView,
                      cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
  {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "dateCell", for: indexPath) as? DateCell
    
    cell?.dateLabel.text = dateArray[indexPath.row].getString(from: pickerMode == .day ?
                                                                                      "EEEE, MMM d, yyyy" :
                                                                                      "MMMM")
    
    return cell!
  }
  
  // UICollectionViewDelegateFlowLayout
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize
  {
    return self.frame.size
  }
  
  // UICollectionViewDelegate
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
  {
    touchTransferDelegate?.collectionView(collectionView, didSelectItemAt: indexPath)
  }
  
  // UIScrollViewDelegate
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
  {
    // set new currentDate
    //currentDate = dateArray[(currentIndexPath?.row)!]
    
    // calculated difference from middle
    let diff = Int(self.contentOffset.x / self.frame.width) - dateArray.count / 2
    
    shiftAndScroll(diff:diff)
    dualScrollDelegate?.collectionViewDidEndScroll(self, withDifferenceOf: diff)
  }
  
  func scrollViewDidScroll(_ scrollView: UIScrollView)
  {
    dualScrollDelegate?.collectionViewDidScroll(self)
  }
  
  // INTERNAL FUNCS
  internal func shiftAndScroll(diff:Int)
  {
    shiftDateArray(diff:diff)
    self.scrollToItem(at: IndexPath(row: dateArray.count/2, section: 0),
                      at: .centeredHorizontally,
                      animated: false)
  }
}
