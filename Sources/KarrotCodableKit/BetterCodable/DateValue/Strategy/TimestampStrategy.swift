//
//  TimestampStrategy.swift
//  KarrotCodableKit
//
//  Created by Elon on 4/9/25.
//

import Foundation

/// Decodes `TimeInterval` values as a `Date`.
///
/// `@TimestampDate` decodes `Double`s of a unix epoch into `Date`s. Encoding the `Date` will encode the value into the
/// original `TimeInterval` value.
///
/// For example, decoding json data with a unix timestamp of `978307200.0` produces a valid `Date` representing January
/// 1, 2001.
public struct TimestampStrategy: DateValueCodableStrategy {
  public static func decode(_ value: TimeInterval) throws -> Date {
    Date(timeIntervalSince1970: value)
  }

  public static func encode(_ date: Date) -> TimeInterval {
    date.timeIntervalSince1970
  }
}

extension TimestampStrategy: OptionalDateValueCodableStrategy {
  public static func decode(_ value: TimeInterval?) throws -> Date? {
    guard let value else { return nil }
    return try decode(value)
  }

  public static func encode(_ date: Date?) -> TimeInterval? {
    guard let date else { return nil }
    return encode(date)
  }
}
