//
//  TimePickerViewController.swift
//  Out
//
//  Created by Stephen Silber on 4/22/16.
//  Copyright © 2016 Out. All rights reserved.
//

import Foundation
import UIKit

protocol TimePickerDelegate {
    func dateChanged(date: NSDate)
}

class TimePickerViewController: UIViewController {
    var delegate: TimePickerDelegate!
    
    private let dayLabel: UILabel = {
        let label = UILabel()
        
        label.textAlignment = .Center
        label.textColor     = UIColor.whiteColor()
        label.font          = UIFont.boldGothamFontOfSize(18)
        
        return label
        
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        
        label.textAlignment = .Center
        label.textColor     = UIColor.whiteColor()
        label.font          = UIFont.gothamFontOfSize(14)
        
        return label
    }()
    
    private let pickerViewController = TimePickerCollectionViewController()
    private let formatter = NSDateFormatter()
    var selectedDate: NSDate?
    
    init(currentDate: NSDate, minimumDate: NSDate?, maximumDate: NSDate?) {
        super.init(nibName: nil, bundle: nil)

        pickerViewController.delegate = self
        
        
        // TODO: Add support for removing minimumDate/maximumDate
        if let date = minimumDate {
            pickerViewController.minimumDate = date
        }
        
        if let date = maximumDate {
            pickerViewController.maximumDate = date
        }
        
        pickerViewController.scrollToDate(currentDate, animated: false)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        formatter.timeZone = NSCalendar.currentCalendar().timeZone
        
        view.clipsToBounds = true
        pickerViewController.delegate = self
        view.backgroundColor = UIColor.baseColor()
        pickerViewController.view.backgroundColor = view.backgroundColor
        
        view.addSubview(dayLabel)
        view.addSubview(timeLabel)
        bo_addChildViewController(pickerViewController)

        dayLabel.snp_makeConstraints { (make) in
            make.top.equalTo(view)
            make.centerX.equalTo(view)
        }

        timeLabel.snp_makeConstraints { (make) in
            make.centerX.equalTo(view)
            make.top.equalTo(dayLabel.snp_bottom).offset(10)
        }

        pickerViewController.view.snp_makeConstraints { (make) in
            make.top.equalTo(timeLabel.snp_bottom).offset(10)
            make.leading.trailing.equalTo(view)
            make.height.equalTo(100)
//            make.bottom.equalTo(view)
        }

        let marker = UIView()
        marker.backgroundColor = UIColor.whiteColor()
        
        view.addSubview(marker)
        marker.snp_makeConstraints { (make) in
            make.centerX.equalTo(pickerViewController.view).offset(-1)
            make.top.bottom.equalTo(pickerViewController.view)
            make.width.equalTo(2)
        }
    }
    
    func moveToDate(date: NSDate, animated: Bool) {
        pickerViewController.scrollToDate(date, animated: animated)
    }
}

extension TimePickerViewController: TimePickerDateDelegate {
    func dateChanged(date: NSDate) {
        self.delegate?.dateChanged(date)
        
        selectedDate = date
        
        formatter.dateFormat = "h:mm a"
        
        timeLabel.text = formatter.stringFromDate(date)
        
        if date.isToday() {
            dayLabel.text = NSLocalizedString("today", comment: "Today").uppercaseString
        } else if date.isTomorrow() {
            dayLabel.text = NSLocalizedString("tomorrow", comment: "Tomorrow").uppercaseString
        } else {
            formatter.dateFormat = "cccc"
            dayLabel.text = formatter.stringFromDate(date).uppercaseString
        }
    }
}