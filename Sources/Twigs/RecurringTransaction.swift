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
    public let end: Date?
    public let amount: Int
    public let categoryId: String?
    public let expense: Bool
    public let createdBy: String
    public let budgetId: String
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

public enum FrequencyUnit: Hashable, CustomStringConvertible {
    case daily
    case weekly(Set<DayOfWeek>)
    case monthly(DayOfMonth)
    case yearly(DayOfYear)
    
    public var description: String {
        switch self {
        case .daily:
            return "D"
        case .weekly(let daysOfWeek):
            return String(format: "W;%s", daysOfWeek.map { $0.rawValue }.joined(separator: ","))
        case .monthly(let dayOfMonth):
            return String(format: "M;%s", dayOfMonth.description)
        case .yearly(let dayOfYear):
            return String(format: "Y;%s", dayOfYear.description)
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
    case positional(Position, DayOfWeek)
    case fixed(Int)
    public init?(position: Position, dayOfWeek: DayOfWeek) {
        if position == .day {
            return nil
        }
        self = .positional(position, dayOfWeek)
    }
    
    public init?(day: Int) {
        if day < 1 || day > 31 {
            return nil
        }
        self = .fixed(day)
    }
    
    public init?(from string: String) {
        let parts = string.split(separator: "-")
        guard let position = Position.init(rawValue: String(parts[0])) else {
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
            self = .positional(position, dayOfWeek)
        }
    }
    
    public var description: String {
        switch self {
        case .positional(let position, let dayOfWeek):
            return "\(position)-\(dayOfWeek)"
        case .fixed(let day):
            return "\(Position.day)-\(day)"
        }
    }
}

public enum Position: String, Hashable {
    case day = "DAY"
    case first = "FIRST"
    case second = "SECOND"
    case third = "THIRD"
    case fourth = "FOURTH"
    case last = "LAST"
}

public enum DayOfWeek: String, Hashable {
    case monday = "MONDAY"
    case tuesday = "TUESDAY"
    case wednesday = "WEDNESDAY"
    case thursday = "THURSDAY"
    case friday = "FRIDAY"
    case saturday = "SATURDAY"
    case sunday = "SUNDAY"
}

public struct DayOfYear: Hashable, CustomStringConvertible {
    public let month: Int
    public let day: Int
    
    public init?(month: Int, day: Int) {
        var maxDay: Int
        switch month {
        case 2:
            maxDay = 29;
            break;
        case 4, 6, 9, 11:
            maxDay = 30;
            break;
        default:
            maxDay = 31;
        }
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
}

public protocol RecurringTransactionsRepository {
    func getRecurringTransactions(budgetId: String) async throws -> [RecurringTransaction]
    func getRecurringTransaction(_ id: String) async throws -> RecurringTransaction
    func createRecurringTransaction(_ transaction: RecurringTransaction) async throws -> RecurringTransaction
    func updateRecurringTransaction(_ transaction: RecurringTransaction) async throws -> RecurringTransaction
    func deleteRecurringTransaction(_ id: String) async throws
}
