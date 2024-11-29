//
//  Utilities.swift
//  SwiftSPICE
//
//  Created by Joe Rupertus on 11/24/24.
//

import Foundation

extension Date {
    static var j2000: Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let components = DateComponents(year: 2000, month: 1, day: 1, hour: 12, minute: 0, second: 0)
        return calendar.date(from: components) ?? Date()
    }
}
