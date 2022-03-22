//
//  Extension+Date.swift
//  钱条
//
//  Created by Lakr Aream on 2022/3/22.
//

import Foundation

extension Date {
    var dayAfter: Date { Calendar.current.date(byAdding: .day, value: 1, to: noon)! }
    var noon: Date { Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)! }
    var startOfDay: Date { Calendar.current.startOfDay(for: self) }
    var endOfDay: Date { Calendar.current.date(byAdding: .init(second: -1), to: dayAfter.startOfDay)! }
    var minSinceMidnight: Double {
        let calendar = Calendar.current
        return Double(calendar.component(.hour, from: self) * 60
            + calendar.component(.minute, from: self))
    }

    var movedToTodayAndKeepHMS: Date {
        let calendar = Calendar.current
        let nowDate = Date()
        let newDate = DateComponents(
            calendar: calendar,
            year: calendar.component(.year, from: nowDate),
            month: calendar.component(.month, from: nowDate),
            day: calendar.component(.day, from: nowDate),
            hour: calendar.component(.hour, from: self),
            minute: calendar.component(.minute, from: self),
            second: 0
        ).date
        #if DEBUG
            return newDate!
        #else
            return newDate ?? .init()
        #endif
    }
}
