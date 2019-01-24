//
//  Date+extension.swift
//  declo-2017-diwork-ios
//
//  Created by roy on 6/2/17.
//  Copyright © 2017 Larvata. All rights reserved.
//

import UIKit

extension Date {
  func year() -> Int {
    return Calendar.current.component(.year, from: self)
  }

  func month() -> Int {
    return Calendar.current.component(.month, from: self)
  }

  func day() -> Int {
    return Calendar.current.component(.day, from: self)
  }

  func weekday() -> Int {
    return Calendar.current.component(.weekday, from: self)
  }

  func hour() -> Int {
    return Calendar.current.component(.hour, from: self)
  }

  func minute() -> Int {
    return Calendar.current.component(.minute, from: self)
  }

  func second() -> Int {
    return Calendar.current.component(.second, from: self)
  }

  func nanosecond() -> Int {
    return Calendar.current.component(.nanosecond, from: self)
  }

  func startOfDay() -> Date {
    return Calendar.current.startOfDay(for: self)
  }

  func endOfDay() -> Date {
    let calendar = Calendar.current
    var components = DateComponents()
    components.day = 1
    components.nanosecond = -1000
    return calendar.date(byAdding: components, to: self)!
  }

  func added(_ component: Calendar.Component, by value: Int) -> Date {
    if let date = Calendar.current.date(byAdding: component, value: value, to: self) {
      return date
    } else {
      print("❗️Error: Failed adding date.")
      return Date.dummy()
    }
  }

  func isSameDayAs(_ date: Date) -> Bool {
    let calendar = Calendar.current
    return calendar.component(.year, from: self) == calendar.component(.year, from: date) &&
      calendar.component(.month, from: self) == calendar.component(.month, from: date) &&
      calendar.component(.day, from: self) == calendar.component(.day, from: date)
  }

  func isSameYearAs(_ date: Date) -> Bool {
    let calendar = Calendar.current
    return calendar.component(.year, from: self) == calendar.component(.year, from: date)
  }

  func stringWithFormat(_ format: String) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = format
    return formatter.string(from: self)
  }

  static func getDate(any: Any?) -> Date? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    guard let string = any as? String else {
      return nil
    }
    return dateFormatter.date(from: string)
  }

  static func getString(any: Any?) -> String? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    guard let date = any as? Date else {
      return nil
    }
    return dateFormatter.string(from: date)
  }

  static func dateWithString(_ string: String, format: String?) -> Date {
    let formatter = DateFormatter()
    formatter.dateFormat = format ?? "yyyy-MM-dd HH:mm:ss"
    if let date = formatter.date(from: string) {
      return date
    } else {
      print("❗️Error: Failed creating date \"\(string)\" with format \"\(format)\"")
      return Date()
    }
  }

  func shortWeekdaySymbol() -> String {
    return stringWithFormat("EEE")
  }

  static func dummy() -> Date {
    return Date(timeIntervalSinceReferenceDate: 0)
  }

  static var date1970: Date = Date(timeIntervalSince1970: 0)

  static var now: Date = Date()
}

class DateRange {
  var beginDate: Date
  var endDate: Date

  init(from beginDate: Date, to endDate: Date) {
    self.beginDate = beginDate
    self.endDate = endDate
  }

  class func forever() -> DateRange {
    let beginDate = Date(timeIntervalSinceReferenceDate: 0)
    let endDate = Date.dateWithString("9999/12/31", format: "yyyy/MM/dd")
    return DateRange(from: beginDate, to: endDate)
  }

  func added(_ component: Calendar.Component, by value: Int) -> DateRange {
    return DateRange(from: beginDate.added(component, by: value), to: endDate.added(component, by: value))
  }

  func dateExtendedToWholeDay() -> DateRange {
    return DateRange(from: beginDate.startOfDay(), to: endDate.endOfDay())
  }

  func contains(_ date: Date) -> Bool {
    return beginDate <= date && date <= endDate
  }

  func contains(_ date: Date, resolution component: Calendar.Component) -> Bool {
    var components = DateComponents()
    var beginComponents = DateComponents()
    var endComponents = DateComponents()

    switch component {
    case .year:
      components.year = date.year()
      beginComponents.year = beginDate.year()
      endComponents.year = endDate.year()
    case .month:
      components.year = date.year()
      beginComponents.year = beginDate.year()
      endComponents.year = endDate.year()
      components.month = date.month()
      beginComponents.month = beginDate.month()
      endComponents.month = endDate.month()
    case .day:
      components.year = date.year()
      beginComponents.year = beginDate.year()
      endComponents.year = endDate.year()
      components.month = date.month()
      beginComponents.month = beginDate.month()
      endComponents.month = endDate.month()
      components.day = date.day()
      beginComponents.day = beginDate.day()
      endComponents.day = endDate.day()
    case .hour:
      components.year = date.year()
      beginComponents.year = beginDate.year()
      endComponents.year = endDate.year()
      components.month = date.month()
      beginComponents.month = beginDate.month()
      endComponents.month = endDate.month()
      components.day = date.day()
      beginComponents.day = beginDate.day()
      endComponents.day = endDate.day()
      components.hour = date.hour()
      beginComponents.hour = beginDate.hour()
      endComponents.hour = endDate.hour()
    case .minute:
      components.year = date.year()
      beginComponents.year = beginDate.year()
      endComponents.year = endDate.year()
      components.month = date.month()
      beginComponents.month = beginDate.month()
      endComponents.month = endDate.month()
      components.day = date.day()
      beginComponents.day = beginDate.day()
      endComponents.day = endDate.day()
      components.hour = date.hour()
      beginComponents.hour = beginDate.hour()
      endComponents.hour = endDate.hour()
      components.minute = date.minute()
      beginComponents.minute = beginDate.minute()
      endComponents.minute = endDate.minute()
    default:
      print("⚠️Warning: Unimplemented case in conatinsDate(:resolution:)")
      return false
    }

    if let resolved = Calendar.current.date(from: components),
      let resolvedBegin = Calendar.current.date(from: beginComponents),
      let resolvedEnd = Calendar.current.date(from: endComponents) {
      return resolvedBegin <= resolved && resolved <= resolvedEnd
    }
    print("⚠️Warning: Failed to resolve in conatinsDate(:resolution:)")
    return false
  }

  func intersectsRange(_ range: DateRange) -> Bool {
    return contains(range.beginDate) ||
      contains(range.endDate) ||
      range.contains(beginDate)
  }

  func intersectsRange(_ range: DateRange, resolution component: Calendar.Component) -> Bool {
    return contains(range.beginDate, resolution: component) ||
      contains(range.endDate, resolution: component) ||
      range.contains(beginDate, resolution: component)
  }

  static func dummy() -> DateRange {
    return DateRange(from: Date.dummy(), to: Date.dummy())
  }
}
