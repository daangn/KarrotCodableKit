//
//  OptionalDateValue.swift
//  KarrotCodableKit
//
//  Created by Ray on 8/9/24.
//  Copyright © 2024 Danggeun Market Inc. All rights reserved.
//

import Foundation

/// A protocol for providing a custom strategy for encoding and decoding optional dates.
///
/// `OptionalDateValueCodableStrategy` provides a generic strategy type that the `OptionalDateValue` property wrapper can use to inject
///  custom strategies for encoding and decoding optional date values.
public protocol OptionalDateValueCodableStrategy {
  associatedtype RawValue

  static func decode(_ value: RawValue?) throws -> Date?
  static func encode(_ date: Date?) -> RawValue?
}

/// Decodes and encodes optional dates using a strategy type.
///
/// `@OptionalDateValue` decodes dates using a `OptionalDateValueCodableStrategy` which provides custom decoding and encoding functionality.
@propertyWrapper
public struct OptionalDateValue<Formatter: OptionalDateValueCodableStrategy> {
  public var wrappedValue: Date?

  public let outcome: ResilientDecodingOutcome

  public init(wrappedValue: Date?) {
    self.wrappedValue = wrappedValue
    self.outcome = .decodedSuccessfully
  }

  init(wrappedValue: Date?, outcome: ResilientDecodingOutcome) {
    self.wrappedValue = wrappedValue
    self.outcome = outcome
  }

  #if DEBUG
  public var projectedValue: ResilientProjectedValue {
    ResilientProjectedValue(outcome: outcome)
  }
  #endif
}

extension OptionalDateValue: Decodable where Formatter.RawValue: Decodable {
  public init(from decoder: Decoder) throws {
    do {
      let value = try Formatter.RawValue(from: decoder)
      do {
        self.wrappedValue = try Formatter.decode(value)
        self.outcome = .decodedSuccessfully
      } catch {
        decoder.reportError(error)
        throw error
      }
    } catch DecodingError.valueNotFound(let rawType, _) where rawType == Formatter.RawValue.self {
      self.wrappedValue = nil
      self.outcome = .valueWasNil
    } catch {
      decoder.reportError(error)
      throw error
    }
  }
}

extension OptionalDateValue: Encodable where Formatter.RawValue: Encodable {
  public func encode(to encoder: Encoder) throws {
    let value = Formatter.encode(wrappedValue)
    try value.encode(to: encoder)
  }
}

extension OptionalDateValue: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.wrappedValue == rhs.wrappedValue
  }
}

extension OptionalDateValue: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(wrappedValue)
  }
}

extension OptionalDateValue: Sendable where Formatter.RawValue: Sendable {}

extension KeyedDecodingContainer {
  public func decode<T>(
    _ type: OptionalDateValue<T>.Type,
    forKey key: Self.Key
  ) throws -> OptionalDateValue<T> where T.RawValue: Decodable {
    try decodeIfPresent(type, forKey: key) ?? OptionalDateValue<T>(wrappedValue: nil)
  }

  public func decodeIfPresent<T>(
    _ type: OptionalDateValue<T>.Type,
    forKey key: Self.Key
  ) throws -> OptionalDateValue<T> where T.RawValue == String {
    let stringOptionalValue = try decodeIfPresent(String.self, forKey: key)

    guard let stringValue = stringOptionalValue else {
      return .init(wrappedValue: nil)
    }

    let dateValue = try T.decode(stringValue)
    return .init(wrappedValue: dateValue)
  }
}
