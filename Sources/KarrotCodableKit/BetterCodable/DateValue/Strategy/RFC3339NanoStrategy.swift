//
//  RFC3339NanoStrategy.swift
//  KarrotCodableKit
//
//  Created by Elon on 4/9/25.
//

import Foundation

/// Decodes `String` values as an RFC 3339 Nano `Date`.
///
/// `@RFC3339NanoDate` decodes RFC 3339 Nano date strings into `Date`s. Encoding the `Date` will encode the value back into the
/// original string value.
///
/// For example, decoding json data with a `String` representation of `"2024-07-10T05:22:29.481633-08:00"` produces a valid
/// `Date` representing 22 minutes, 29 seconds, 481 milliseconds, and 633 microseconds after the 5th hour of July 10th,
/// 2024 with an offset of -08:00 from UTC (Pacific Standard Time).
public struct RFC3339NanoStrategy: DateValueCodableStrategy {

  private static let rfc3339NanoDateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZZZZZ"
    return dateFormatter
  }()

  private static let rfc3339DateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
    return dateFormatter
  }()

  public static func decode(_ value: String) throws -> Date {
    if let date = RFC3339NanoStrategy.rfc3339NanoDateFormatter.date(from: value) {
      return date
    }

    if let date = RFC3339NanoStrategy.rfc3339DateFormatter.date(from: value) {
      return date
    }

    throw DecodingError.dataCorrupted(
      DecodingError.Context(
        codingPath: [],
        debugDescription: "\"\(value)\" is invalid date format!"
      )
    )
  }

  public static func encode(_ date: Date) -> String {
    RFC3339NanoStrategy.rfc3339NanoDateFormatter.string(from: date)
  }
}

extension RFC3339NanoStrategy: OptionalDateValueCodableStrategy {
  public static func decode(_ value: String?) throws -> Date? {
    guard let value else { return nil }
    return try decode(value)
  }

  public static func encode(_ date: Date?) -> String? {
    guard let date else { return nil }
    return encode(date)
  }
}
