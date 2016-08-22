//
//  DayPeriod.swift
//  Out
//
//  Created by Stephen Silber on 4/22/16.
//  Copyright © 2016 Out. All rights reserved.
//

import Foundation

enum DayPeriod: Int {
    case Morning    = 0
    case Afternoon  = 1
    case Evening    = 2
    case LateNight  = 3
    
    init(hour: Int) {
        if hour >= 4 && hour < 10 {
            self = .Morning
        } else if hour >= 10 && hour < 16 {
            self = .Afternoon
        } else if hour >= 16 && hour < 22 {
            self = .Evening
        } else {
            self = .LateNight
        }
    }
    
    var description: String {
        switch self {
        case .Morning:
            return NSLocalizedString("morning", comment: "Morning").uppercaseString
        case .Afternoon:
            return NSLocalizedString("afternoon", comment: "Afternoon").uppercaseString
        case .Evening:
            return NSLocalizedString("evening", comment: "Evening").uppercaseString
        case .LateNight:
            return NSLocalizedString("late night", comment: "Late Night").uppercaseString
        }
    }
    
    var beginningDate: NSDate {
        let calendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)!
        let components = calendar.components([.Year, .Month, .Day], fromDate: NSDate())
        
        switch self {
        case .Morning:
            components.hour = 4
        case .Afternoon:
            components.hour = 10
        case .Evening:
            components.hour = 16
        case .LateNight:
            components.hour = 22
        }
        
        return NSCalendar.currentCalendar().dateFromComponents(components)!
    }
    
    static var periodDuration: NSTimeInterval {
        return 60 * 60 * 6 // 6 Hours
    }
}