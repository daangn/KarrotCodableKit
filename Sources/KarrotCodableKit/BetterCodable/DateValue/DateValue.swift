//
//  DateValue.swift
//  KarrotCodableKit
//
//  Created by Elon on 4/9/25.
//

import Foundation

/// A protocol for providing a custom strategy for encoding and decoding dates.
///
/// `DateValueCodableStrategy` provides a generic strategy type that the `DateValue` property wrapper can use to inject
///  custom strategies for encoding and decoding date values.
public protocol DateValueCodableStrategy {
  associatedtype RawValue

  static func decode(_ value: RawValue) throws -> Date
  static func encode(_ date: Date) -> RawValue
}

/// Decodes and encodes dates using a strategy type.
///
/// `@DateValue` decodes dates using a `DateValueCodableStrategy` which provides custom decoding and encoding functionality.
@propertyWrapper
public struct DateValue<Formatter: DateValueCodableStrategy> {
  public var wrappedValue: Date

  public init(wrappedValue: Date) {
    self.wrappedValue = wrappedValue
  }
}

extension DateValue: Decodable where Formatter.RawValue: Decodable {
  public init(from decoder: Decoder) throws {
    let value = try Formatter.RawValue(from: decoder)
    self.wrappedValue = try Formatter.decode(value)
  }
}

extension DateValue: Encodable where Formatter.RawValue: Encodable {
  public func encode(to encoder: Encoder) throws {
    let value = Formatter.encode(wrappedValue)
    try value.encode(to: encoder)
  }
}

extension DateValue: Equatable {
  public static func == (lhs: DateValue<Formatter>, rhs: DateValue<Formatter>) -> Bool {
    lhs.wrappedValue == rhs.wrappedValue
  }
}

extension DateValue: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(wrappedValue)
  }
}

extension DateValue: Sendable where Formatter.RawValue: Sendable {}
