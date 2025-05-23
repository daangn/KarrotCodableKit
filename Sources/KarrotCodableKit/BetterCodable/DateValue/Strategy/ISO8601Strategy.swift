//
//  ISO8601Strategy.swift
//  KarrotCodableKit
//
//  Created by Elon on 4/9/25.
//

import Foundation

/// Decodes `String` values as an ISO8601 `Date`.
///
/// `@ISO8601Date` relies on an `ISO8601DateFormatter` in order to decode `String` values into `Date`s. Encoding the `Date`
/// will encode the value into the original string value.
///
/// For example, decoding json data with a `String` representation  of `"1996-12-19T16:39:57-08:00"` produces a valid `Date`
/// representing 39 minutes and 57 seconds after the 16th hour of December 19th, 1996 with an offset of -08:00 from UTC
/// (Pacific Standard Time).
public struct ISO8601Strategy: DateValueCodableStrategy {
  public static func decode(_ value: String) throws -> Date {
    guard let date = ISO8601DateFormatter().date(from: value) else {
      throw DecodingError.dataCorrupted(
        DecodingError.Context(
          codingPath: [],
          debugDescription: "\"\(value)\" is invalid date format!"
        )
      )
    }
    return date
  }

  public static func encode(_ date: Date) -> String {
    ISO8601DateFormatter().string(from: date)
  }
}

extension ISO8601Strategy: OptionalDateValueCodableStrategy {
  public static func decode(_ value: String?) throws -> Date? {
    guard let value else { return nil }
    return try decode(value)
  }

  public static func encode(_ date: Date?) -> String? {
    guard let date else { return nil }
    return encode(date)
  }
}
