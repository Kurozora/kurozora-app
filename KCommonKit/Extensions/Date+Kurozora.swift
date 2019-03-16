//
//  Date+Kurozora.swift
//  KCommonKit
//
//  Created by Khoren Katklian on 02/05/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import Foundation

extension Date {
    var mediumFormatter: DateFormatter {
        struct Static {
            static let instance : DateFormatter = {
                let formatter = DateFormatter()
                formatter.dateStyle = DateFormatter.Style.medium
                return formatter
            }()
        }
        return Static.instance
    }
    
    var mediumDateTimeFormatter: DateFormatter {
        struct Static {
            static let instance : DateFormatter = {
                let formatter = DateFormatter()
                formatter.dateStyle = DateFormatter.Style.medium
                formatter.timeStyle = DateFormatter.Style.medium
                return formatter
            }()
        }
        return Static.instance
    }
    
    public func mediumDate() -> String {
        return mediumFormatter.string(from: self as Date)
    }
    
    public func mediumDateTime() -> String {
        return mediumDateTimeFormatter.string(from: self as Date)
    }
    
    public func timeAgo() -> String {
        
        let timeInterval = Int(-timeIntervalSince(Date()))
        
        if let weeksAgo = timeInterval / (7*24*60*60) as Int?, weeksAgo > 0 {
            return "\(weeksAgo) " + (weeksAgo == 1 ? "week" : "weeks")
        } else if let daysAgo = timeInterval / (60*60*24) as Int?, daysAgo > 0 {
            return "\(daysAgo) " + (daysAgo == 1 ? "day" : "days")
        } else if let hoursAgo = timeInterval / (60*60) as Int?, hoursAgo > 0 {
            return "\(hoursAgo) " + (hoursAgo == 1 ? "hr" : "hrs")
        } else if let minutesAgo = timeInterval / 60 as Int?, minutesAgo > 0 {
            return "\(minutesAgo) " + (minutesAgo == 1 ? "min" : "mins")
        } else {
            return "Just now"
        }
    }
    
    public func etaForDate() -> (days: Int?, hours: Int?, minutes: Int?) {
        let now = Date()
        let cal = Calendar.current
        let unitFlags = Set<Calendar.Component>([.day, .hour, .minute])
        let components = cal.dateComponents(unitFlags, from: now, to: self)
        
        return (components.day, components.hour, components.minute)
    }
    
    public func etaStringForDate(short: Bool = false) -> String {
        return etaForDateWithString(short: short).etaString
    }
    
    public func etaForDateWithString(short: Bool = false) -> (days: Int?, hours: Int?, minutes: Int?, etaString: String) {
        let (days, hours, minutes) = etaForDate()
        
        var etaTime = ""
        if days != 0 {
            etaTime = short ? "\(String(describing: days))d \(String(describing: hours))h" : "\(String(describing: days))d \(String(describing: hours))h \(String(describing: minutes))m"
        } else if hours != 0 {
            etaTime = "\(String(describing: hours))h \(String(describing: minutes))m"
        } else {
            etaTime = "\(String(describing: minutes))m"
        }
        
        return (days, hours, minutes, etaTime)
    }
}
