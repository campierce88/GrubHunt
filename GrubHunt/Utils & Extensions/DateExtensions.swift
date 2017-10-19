//
//  DateExtensions.swift
//  GrubHunt
//
//  Created by Cameron Pierce on 10/17/17.
//  Copyright © 2017 Cameron Pierce. All rights reserved.
//

import Foundation

extension Date {
    /// Returns the amount of years from another date
    func years(from date: Date) -> Int {
        return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
    }
    /// Returns the amount of months from another date
    func months(from date: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
    }
    /// Returns the amount of weeks from another date
    func weeks(from date: Date) -> Int {
        return Calendar.current.dateComponents([.weekOfYear], from: date, to: self).weekOfYear ?? 0
    }
    /// Returns the amount of days from another date
    func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    /// Returns the amount of hours from another date
    func hours(from date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }
    /// Returns the amount of minutes from another date
    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }
    /// Returns the amount of seconds from another date
    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
    /// Returns the a custom time interval description from another date
    func offset(from date: Date, useLongString: Bool = false) -> String {
        if years(from: date) > 0 {
            let numYears = years(from: date)
            if useLongString {
                return numYears == 1 ? "\(numYears) year ago" : "\(numYears) years ago"
            } else {
                return "\(numYears)y"
            }
        }
        if months(from: date) > 0 {
            let numMonths = months(from: date)
            if useLongString {
                return numMonths == 1 ? "\(numMonths) month ago" : "\(numMonths) months ago"
            } else {
                return "\(numMonths)M"
            }
        }
        if weeks(from: date) > 0 {
            let numWeeks = weeks(from: date)
            if useLongString {
                return numWeeks == 1 ? "\(numWeeks) week ago" : "\(numWeeks) weeks ago"
            } else {
                return "\(numWeeks)w"
            }
        }
        if days(from: date) > 0 {
            let numDays = days(from: date)
            if useLongString {
                return numDays == 1 ? "\(numDays) day ago" : "\(numDays) days ago"
            } else {
                return "\(numDays)d"
            }
        }
        if hours(from: date) > 0 {
            let numHours = hours(from: date)
            if useLongString {
                return numHours == 1 ? "\(numHours) hour ago" : "\(numHours) hours ago"
            } else {
                return "\(numHours)h"
            }
        }
        if minutes(from: date) > 0 {
            let numMinutes = minutes(from: date)
            if useLongString {
                return numMinutes == 1 ? "\(numMinutes) minute ago" : "\(numMinutes) minutes ago"
            } else {
                return "\(numMinutes)m"
            }
        }
        if seconds(from: date) > 0 {
            let numSeconds = seconds(from: date)
            if useLongString {
                return numSeconds == 1 ? "\(numSeconds) second ago" : "\(numSeconds) seconds ago"
            } else {
                return "\(numSeconds)s"
            }
        }
        return ""
    }
}
