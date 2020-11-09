//
//  MonthFormatter.swift
//  CalendarView
//
//  Created by Amber Spadafora on 11/8/20.
//  Copyright © 2020 Amber Spadafora. All rights reserved.
//

import Foundation

class MonthFormatter: ObservableObject {
    
    static let calendar = Calendar(identifier: .gregorian)
    
    @Published var displayMonth: [[Day]]
    
    @Published var baseDate: Date = Date() {
        didSet {
            self.displayMonth = MonthFormatter.generateDisplayMonth(for: baseDate)
            print(self.displayMonth)
        }
    }
    
    init(baseDate: Date) {
        self.displayMonth = MonthFormatter.generateDisplayMonth(for: baseDate)
    }
    
    static func generateDisplayMonth(for date: Date) -> [[Day]] {
        let month = MonthFormatter.generateDaysInMonth(for: date)
        
        var weeks: [[Day]] = []
        let _ = stride(from: 0, to: month.count, by: 7).map {
            let count = Int(min($0 + 7, month.count))
            weeks.append(Array(month[$0..<count]))
        }
        
        return weeks
    }
    
    static func monthMetaData(for date: Date) throws -> MonthMetaData {
        guard let numberOfDaysInMonth = calendar.range(of: .day, in: .month, for: date)?.count,
            let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date)) else {
                throw CalendarDataError.metaDataGeneration
        }
        let firstDayWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        return MonthMetaData(numberOfDays: numberOfDaysInMonth, firstDay: firstDayOfMonth, firstDayWeekday: firstDayWeekday)
        
        
    }
    
    static func generateDaysInMonth(for date: Date) -> [Day] {
        guard let metaData = try? monthMetaData(for: date) else {
            fatalError("An error occurred when generating the meta data for \(date)")
        }
        
        let numberOfDaysInMonth = metaData.numberOfDays
        let offSetInFirstRow = metaData.firstDayWeekday
        let firstDayOfMonth = metaData.firstDay
        
        var days: [Day] = (1..<(numberOfDaysInMonth + offSetInFirstRow)).map { day in
            // if day is less than offset than it is not in current month
            let isWithinDisplayedMonth = (day >= offSetInFirstRow)
            let dayOffset = isWithinDisplayedMonth ? day - offSetInFirstRow : -(offSetInFirstRow - day)
            return generateDay(offsetBy: dayOffset, for: firstDayOfMonth, isWithinDisplayedMonth: isWithinDisplayedMonth)
            
        }
        days += generateStartOfNextMonth(using: firstDayOfMonth)
        return days
    }
    
    static func generateDay(offsetBy dayOffset: Int, for baseDate: Date, isWithinDisplayedMonth: Bool) -> Day {
        let date = calendar.date(byAdding: .day, value: dayOffset, to: baseDate) ?? baseDate
        return Day(date: date, number: DateFormatter().string(from: date), isSelected: calendar.isDateInToday(date), isWithinDisplayedMonth: isWithinDisplayedMonth)
    }
    
    static func generateStartOfNextMonth(using firstDayOfDisplayedMonth: Date) -> [Day] {
        guard let lastDayInMonth = calendar.date(
            byAdding: DateComponents(month: 1, day: -1),
            to: firstDayOfDisplayedMonth)
            else {
                return []
        }
        
        let additionalDays = 7 - calendar.component(.weekday, from: lastDayInMonth)
        guard additionalDays > 0 else {
            return []
        }
        let days: [Day] = (1...additionalDays)
            .map {
                generateDay(
                    offsetBy: $0,
                    for: lastDayInMonth,
                    isWithinDisplayedMonth: false)
        }
        return days
    }
    
    enum CalendarDataError: Error {
        case metaDataGeneration
    }
    
}
