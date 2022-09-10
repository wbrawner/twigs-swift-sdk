//
//  File.swift
//  
//
//  Created by William Brawner on 12/22/21.
//

import Foundation

public struct RecurringTransaction: Identifiable, Hashable, Codable {
    public let id: String
    public let title: String
    public let description: String?
    public let frequency: Frequency
    public let start: Date
    public let finish: Date?
    public let amount: Int
    public let categoryId: String?
    public let expense: Bool
    public let createdBy: String
    public let budgetId: String
    
    public init(
        id: String = "",
        title: String = "",
        description: String? = nil,
        frequency: Frequency = Frequency(unit: FrequencyUnit.daily, count: 1, time: Time(hours: 9, minutes: 0, seconds: 0)!)!,
        start: Date = Date(),
        finish: Date? = nil,
        amount: Int = 0,
        categoryId: String? = nil,
        expense: Bool = true,
        createdBy: String,
        budgetId: String
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.frequency = frequency
        self.start = start
        self.finish = finish
        self.amount = amount
        self.categoryId = categoryId
        self.expense = expense
        self.createdBy = createdBy
        self.budgetId = budgetId
    }
}

extension Date {
    var startOfMonth: Date {
        get {
            return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: self)))!
        }
    }
    var endOfMonth: Date {
        get {
            return Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: self.startOfMonth)!
        }
    }
}

extension RecurringTransaction {
    public var type: TransactionType {
        if (self.expense) {
            return .expense
        } else {
            return .income
        }
    }
    
    public var amountString: String {
        return self.amount > 0 ? String(format: "%.02f", Double(self.amount) / 100.0) : ""
    }
    
    public var isThisMonth: Bool {
        switch self.frequency.unit {
        case .daily:
            return true // TODO: this isn't quite accurate, there are edge cases to account for
        case .weekly(_):
            return true // TODO: also not quite accurate. e.g. a transaction that occurs every 6 weeks may or may not be this month
        case .monthly(_):
            // TODO: the backend needs to expose the last run time in order to be able to check this
            return self.frequency.count == 1
        case .yearly(let dayOfYear):
            // TODO: the backend needs to expose the last run time in order to be able to check this
            let currentMonth = Calendar.current.dateComponents([.month], from: Date()).month!
            return dayOfYear.month == currentMonth
        }
    }
    
    public var isExpired: Bool {
        guard let finish = self.finish else {
            return false
        }
        return finish < Date().startOfMonth
    }
}

public struct Frequency: Hashable, Codable, CustomStringConvertible {
    public let unit: FrequencyUnit
    public let count: Int
    public let time: Time
    
    public init?(unit: FrequencyUnit, count: Int, time: Time) {
        if count < 1 {
            return nil
        }
        self.unit = unit
        self.count = count
        self.time = time
    }
    
    public init?(from string: String) {
        let parts = string.split(separator: ";")
        guard let count = Int(parts[1]) else {
            return nil
        }
        var timeIndex = 3
        switch parts[0] {
        case "D":
            self.unit = .daily
            timeIndex = 2
        case "W":
            let daysOfWeek = parts[2].split(separator: ",").compactMap { dayOfWeek in
                DayOfWeek(rawValue: String(dayOfWeek))
            }
            if daysOfWeek.isEmpty {
                return nil
            }
            self.unit = .weekly(Set(daysOfWeek))
        case "M":
            guard let dayOfMonth = DayOfMonth(from: String(parts[2])) else {
                return nil
            }
            self.unit = .monthly(dayOfMonth)
        case "Y":
            guard let dayOfYear = DayOfYear(from: String(parts[2])) else {
                return nil
            }
            self.unit = .yearly(dayOfYear)
        default:
            return nil
        }
        guard let time = Time(from: String(parts[timeIndex])) else {
            return nil
        }
        self.time = time
        self.count = count
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let frequencyString = try container.decode(String.self)
        self.init(from: frequencyString)!
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(description)
    }
    
    public var description: String {
        // TODO: Make the backend representation of this more sensible and then use this
        // return [unit.description, count.description, time.description].joined(separator: ";")
        let unitParts = "\(unit)".split(separator: ";")
        if unitParts.count == 1 {
            return [unitParts[0].description, count.description, time.description].joined(separator: ";")
        } else{
            return [unitParts[0].description, count.description, unitParts[1].description, time.description].joined(separator: ";")
        }
    }
    
    public var naturalDescription: String {
        return unit.format(count: count, time: time)
    }
}

public enum FrequencyUnit: Identifiable, Hashable, CustomStringConvertible, CaseIterable {
    public var id: String {
        return self.baseName
    }
    
    public static var allCases: [FrequencyUnit] = [
        .daily,
        .weekly(Set()),
        .monthly(.fixed(1)),
        .yearly(DayOfYear(month: 1, day: 1)!),
    ]
    
    case daily
    case weekly(Set<DayOfWeek>)
    case monthly(DayOfMonth)
    case yearly(DayOfYear)
    
    public var description: String {
        switch self {
        case .daily:
            return "D"
        case .weekly(let daysOfWeek):
            return "W;\(daysOfWeek.map { $0.rawValue }.joined(separator: ","))"
        case .monthly(let dayOfMonth):
            return "M;\(dayOfMonth.description)"
        case .yearly(let dayOfYear):
            return "Y;\(dayOfYear.description)"
        }
    }
    
    func format(count: Int, time: Time) -> String {
        switch self {
        case .daily:
            return String(localized: "Every \(count) day(s) at \(time.description)")
        case .weekly(let daysOfWeek):
            return String(localized: "Every \(count) week(s) on \(daysOfWeek.description) at \(time.description)")
        case .monthly(let dayOfMonth):
            return String(localized: "Every \(count) month(s) on the \(dayOfMonth.description) at \(time.description)")
        case .yearly(let dayOfYear):
            return String(localized: "Every \(count) year(s) on \(dayOfYear.description) at \(time.description)")
        }
    }
    
    public var baseName: String {
        switch self {
        case .daily:
            return "day"
        case .weekly(_):
            return "week"
        case .monthly(_):
            return "month"
        case .yearly(_):
            return "year"
        }
    }
}

public struct Time: Hashable, CustomStringConvertible {
    public let hours: Int
    public let minutes: Int
    public let seconds: Int
    
    public init?(hours: Int, minutes: Int, seconds: Int) {
        if hours < 0 || hours > 23 {
            return nil
        }
        if minutes < 0 || minutes > 59 {
            return nil
        }
        if seconds < 0 || seconds > 59 {
            return nil
        }
        self.hours = hours
        self.minutes = minutes
        self.seconds = seconds
    }
    
    public init?(from string: String) {
        let parts = string.split(separator: ":").compactMap {
            Int($0)
        }
        if parts.count != 3 {
            return nil
        }
        self.init(hours: parts[0], minutes: parts[1], seconds: parts[2])
    }
    
    public var description: String {
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

public enum DayOfMonth: Hashable, CustomStringConvertible {
    case ordinal(Ordinal, DayOfWeek)
    case fixed(Int)
    public init?(ordinal: Ordinal, dayOfWeek: DayOfWeek) {
        if ordinal == .day {
            return nil
        }
        self = .ordinal(ordinal, dayOfWeek)
    }
    
    public init?(day: Int) {
        if day < 1 || day > 31 {
            return nil
        }
        self = .fixed(day)
    }
    
    public init?(from string: String) {
        let parts = string.split(separator: "-")
        guard let position = Ordinal.init(rawValue: String(parts[0])) else {
            return nil
        }
        if position == .day {
            guard let day = Int(parts[1]) else {
                return nil
            }
            self = .fixed(day)
        } else {
            guard let dayOfWeek = DayOfWeek(rawValue: String(parts[1])) else {
                return nil
            }
            self = .ordinal(position, dayOfWeek)
        }
    }
    
    public var description: String {
        switch self {
        case .ordinal(let position, let dayOfWeek):
            return "\(position.rawValue)-\(dayOfWeek)"
        case .fixed(let day):
            return "\(Ordinal.day.rawValue)-\(day)"
        }
    }
}

public enum Ordinal: String, Hashable, CaseIterable {
    case day = "DAY"
    case first = "FIRST"
    case second = "SECOND"
    case third = "THIRD"
    case fourth = "FOURTH"
    case last = "LAST"
}

public enum DayOfWeek: String, Hashable, CaseIterable, Identifiable {
    public var id: String {
        return self.rawValue
    }
    
    case sunday = "SUNDAY"
    case monday = "MONDAY"
    case tuesday = "TUESDAY"
    case wednesday = "WEDNESDAY"
    case thursday = "THURSDAY"
    case friday = "FRIDAY"
    case saturday = "SATURDAY"
}

public struct DayOfYear: Hashable, CustomStringConvertible {
    public let month: Int
    public let day: Int
    
    public init?(month: Int, day: Int) {
        let maxDay = DayOfYear.maxDays(inMonth: month)
        if day < 1 || day > maxDay {
            return nil
        }
        if month < 1 || month > 12 {
            return nil
        }
        self.day = day
        self.month = month
    }
    
    public init?(from string: String) {
        let parts = string.split(separator: "-").compactMap {
            Int($0)
        }
        if parts.count < 2 {
            return nil
        }
        self.init(month: parts[0], day: parts[1])
    }
    
    public var description: String {
        return String(format: "%02d-%02d", self.month, self.day)
    }
    
    public static func maxDays(inMonth month: Int) -> Int {
        switch month {
        case 2:
            return 29;
        case 4, 6, 9, 11:
            return 30;
        default:
            return 31;
        }
    }
}

public protocol RecurringTransactionsRepository {
    func getRecurringTransactions(_ budgetId: String) async throws -> [RecurringTransaction]
    func getRecurringTransaction(_ id: String) async throws -> RecurringTransaction
    func createRecurringTransaction(_ transaction: RecurringTransaction) async throws -> RecurringTransaction
    func updateRecurringTransaction(_ transaction: RecurringTransaction) async throws -> RecurringTransaction
    func deleteRecurringTransaction(_ id: String) async throws
}
