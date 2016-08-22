//
//  TimePickerCollectionView.swift
//  Out
//
//  Created by Stephen Silber on 4/22/16.
//  Copyright © 2016 Out. All rights reserved.
//

import Foundation
import UIKit
import Timepiece

protocol TimePickerDateDelegate {
    func dateChanged(date: NSDate)
}

class TimePickerCollectionViewController: UICollectionViewController {
    static let cellWidth: CGFloat = 360
    
    var delegate: TimePickerDateDelegate!
    let layout = UICollectionViewFlowLayout()
    let pixelsPerSecond: CGFloat = cellWidth / CGFloat(DayPeriod.periodDuration)
    let currentDayPeriod = DayPeriod(hour: NSDate().hour)
    let interval: NSTimeInterval = 900

    private var hasSetInitialContentOffset = false
    private var startDate = NSDate().dateBySubtractingDays(1).beginningOfDay//NSDate(timeIntervalSince1970: 0)
    
    
    // http://stackoverflow.com/questions/20437657/increasing-uiscrollview-rubber-banding-resistance
    var maxOffset: CGFloat {
        guard let date = maximumDate else {
            return CGFloat.max
        }
        return offsetForDate(date)
    }
    
    var prevOffset: CGFloat = 0  // previous offset (after adjusting the value)
    
    var totalDistance: CGFloat = 0  // total distance it would have moved (had we not restricted)
    let reductionFactor: CGFloat = 0.1  // percent of total distance it will be allowed to move (under restriction)
    let scaleFactor: CGFloat = UIScreen.mainScreen().scale  // pixels per point, for smooth translation in respective devices
    

    var minimumDate: NSDate?
    var maximumDate: NSDate?
    var selectedDate: NSDate? {
        didSet {
            if let date = selectedDate {
                self.delegate?.dateChanged(date)
            }
        }
    }
    
    init() {
        super.init(collectionViewLayout: layout)
        
        layout.itemSize             = CGSizeMake(TimePickerCollectionViewController.cellWidth, 100)
        layout.scrollDirection      = .Horizontal
        layout.minimumLineSpacing   = 0
        layout.headerReferenceSize  = CGSize(width: 0, height: 0)
        layout.sectionInset         = UIEdgeInsetsZero
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = UIColor.clearColor()
        collectionView?.decelerationRate = UIScrollViewDecelerationRateFast
        collectionView?.showsHorizontalScrollIndicator = false
//        collectionView?.contentInset = UIEdgeInsetsMake(0, TimePickerCollectionViewController.cellWidth / 2, 0, TimePickerCollectionViewController.cellWidth / 2)
        collectionView?.registerClass(TimePickerCell.self, forCellWithReuseIdentifier: "timePickerCell")
    }
    
    func scrollToDate(date: NSDate, animated: Bool) {
        let offset = offsetForDate(date)
        collectionView?.setContentOffset(CGPointMake(offset, 0), animated: animated)
    }
    
    // MARK: Private date/offset calculators
    
    private func offsetForDate(date: NSDate) -> CGFloat {
        // Restrict min scroll offset
        if let minimumDate = minimumDate where date.timeIntervalSince1970 < minimumDate.timeIntervalSince1970 {
            return offsetForDate(minimumDate)
        }
        
        // Restrict max scroll offset
        if let maximumDate = maximumDate where date.timeIntervalSince1970 > maximumDate.timeIntervalSince1970 {
            return offsetForDate(maximumDate)
        }
   
        let seconds = CGFloat(date.timeIntervalSinceDate(startDate))
        return seconds * pixelsPerSecond
    }
    
    private func dateForOffset(offset: CGFloat) -> NSDate {
        let seconds = Double(offset / pixelsPerSecond)
        return NSDate(timeInterval: seconds, sinceDate: startDate)
    }
    
    private func indexPathForDate(date: NSDate) -> NSIndexPath? {
        let offset = offsetForDate(date)
        
        guard let indexPath = collectionView?.indexPathForItemAtPoint(CGPointMake(offset, 0)) else {
            return nil
        }

        return indexPath
    }
    
    private func relativeOffset(forOffset offset: CGFloat, atIndexPath indexPath: NSIndexPath) -> CGFloat {
        return offset - offsetForIndexPath(indexPath)
    }
    
    private func offsetForIndexPath(indexPath: NSIndexPath) -> CGFloat {
        guard let collectionView = collectionView else {
            return 0
        }
        
        if indexPath.section == 0 && indexPath.row == 0 {
            return 0
        } else if indexPath.section == 0 {
            return TimePickerCollectionViewController.cellWidth * CGFloat(indexPath.row - 1)
        } else {
            let numberOfPeriods = CGFloat(collectionView.numberOfItemsInSection(0) * indexPath.section)
            var offset = numberOfPeriods * TimePickerCollectionViewController.cellWidth
            
            // Account for previous periods in current day
            if indexPath.row > 0 {
                offset += TimePickerCollectionViewController.cellWidth * CGFloat(indexPath.row)
            }
            
            return offset
        }
    }
    
    private func dayPeriodForIndexPath(indexPath: NSIndexPath) -> DayPeriod {
        let date = beginningDateForIndexPath(indexPath)
        return DayPeriod(hour: date.hour)
    }
    
    
    private func beginningDateForIndexPath(indexPath: NSIndexPath) -> NSDate {
        let offset = offsetForIndexPath(indexPath)
        let date = dateForOffset(offset)

        return date
    }
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        guard let date = maximumDate else {
            return 365 // 1 year
        }
        
        let days = Int(date.timeIntervalSinceDate(startDate) / (DayPeriod.periodDuration * 4))
        
        return days
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    // MARK: UICollectionViewDelegate
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("timePickerCell", forIndexPath: indexPath)
        
        if let cell = cell as? TimePickerCell {
            let period = dayPeriodForIndexPath(indexPath)
            cell.configure(dayPeriod: period)
            
            // Mark our "now" cell
            let now = NSDate()
            if indexPath == indexPathForDate(now) {
                let offset = offsetForDate(now)
                let markOffset = relativeOffset(forOffset: offset, atIndexPath: indexPath)
//                cell.drawNowMark(markOffset)
            }
        }
        
        return cell
    }
    

    override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        userScroll = true
    }
    
    override func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        userScroll = false
    }
    

    
    var userScroll = true
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        let date = dateForOffset(scrollView.contentOffset.x + collectionView!.contentInset.left)

        if userScroll {
            if let date = minimumDate where scrollView.contentOffset.x <= offsetForDate(date) {
                scrollView.contentOffset.x = offsetForDate(date)
            }
            
            if let date = maximumDate where scrollView.contentOffset.x >= offsetForDate(date) {
                scrollView.contentOffset.x = offsetForDate(date)
            }
        }

        selectedDate = date.roundedByTimeInterval(interval)
    }
}

extension NSDate {
    func roundedByTimeInterval(timeInterval: NSTimeInterval) -> NSDate {
        var date = self

        if timeInterval < 60 { // Seconds            

        } else if timeInterval >= 60 && timeInterval < 3600 { // Minutes
            let minutes = Int(timeInterval / 60)
            
            if (self.minute % minutes) < minutes / 2 {
                date = date.dateBySubtractingMinutes(self.minute % minutes)
            } else {
                date = date.dateByAddingMinutes(minutes - (self.minute % minutes))
            }
            
        } else if timeInterval < 86400 { // Hours
            
        }
        
        return date
    }

}
