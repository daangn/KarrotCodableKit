//
//  RFC3339Strategy.swift
//  KarrotCodableKit
//
//  Created by Elon on 4/9/25.
//

import Foundation

/// Decodes `String` values as an RFC 3339 `Date`.
///
/// `@RFC3339Date` decodes RFC 3339 date strings into `Date`s. Encoding the `Date` will encode the value back into the
/// original string value.
///
/// For example, decoding json data with a `String` representation of `"1996-12-19T16:39:57-08:00"` produces a valid
/// `Date` representing 39 minutes and 57 seconds after the 16th hour of December 19th, 1996 with an offset of -08:00
/// from UTC (Pacific Standard Time).
public struct RFC3339Strategy: DateValueCodableStrategy {
  private static let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
    return dateFormatter
  }()

  public static func decode(_ value: String) throws -> Date {
    if let date = RFC3339Strategy.dateFormatter.date(from: value) {
      return date
    } else {
      throw DecodingError.dataCorrupted(
        DecodingError.Context(
          codingPath: [],
          debugDescription: "\"\(value)\" is invalid date format!"
        )
      )
    }
  }

  public static func encode(_ date: Date) -> String {
    RFC3339Strategy.dateFormatter.string(from: date)
  }
}

extension RFC3339Strategy: OptionalDateValueCodableStrategy {
  public static func decode(_ value: String?) throws -> Date? {
    guard let value else { return nil }
    return try decode(value)
  }

  public static func encode(_ date: Date?) -> String? {
    guard let date else { return nil }
    return encode(date)
  }
}
