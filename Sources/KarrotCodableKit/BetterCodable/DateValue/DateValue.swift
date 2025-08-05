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

  public let outcome: ResilientDecodingOutcome

  public init(wrappedValue: Date) {
    self.wrappedValue = wrappedValue
    self.outcome = .decodedSuccessfully
  }

  init(wrappedValue: Date, outcome: ResilientDecodingOutcome) {
    self.wrappedValue = wrappedValue
    self.outcome = outcome
  }

  #if DEBUG
  public var projectedValue: ResilientProjectedValue {
    ResilientProjectedValue(outcome: outcome)
  }
  #endif
}

extension DateValue: Decodable where Formatter.RawValue: Decodable {
  public init(from decoder: Decoder) throws {
    do {
      let value = try Formatter.RawValue(from: decoder)
      self.wrappedValue = try Formatter.decode(value)
      self.outcome = .decodedSuccessfully
    } catch {
      decoder.reportError(error)
      throw error
    }
  }
}

extension DateValue: Encodable where Formatter.RawValue: Encodable {
  public func encode(to encoder: Encoder) throws {
    let value = Formatter.encode(wrappedValue)
    try value.encode(to: encoder)
  }
}

extension DateValue: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.wrappedValue == rhs.wrappedValue
  }
}

extension DateValue: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(wrappedValue)
  }
}

extension DateValue: Sendable where Formatter.RawValue: Sendable {}
