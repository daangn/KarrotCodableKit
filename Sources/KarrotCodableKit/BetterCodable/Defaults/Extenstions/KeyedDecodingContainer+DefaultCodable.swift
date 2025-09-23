//
//  KeyedDecodingContainer+DefaultCodable.swift
//  KarrotCodableKit
//
//  Created by elon on 9/23/25.
//

import Foundation

public protocol BoolCodableStrategy: DefaultCodableStrategy where DefaultValue == Bool {}

extension KeyedDecodingContainer {
  /// Default implementation of decoding a DefaultCodable
  ///
  /// Decodes successfully if key is available if not fallback to the default value provided.
  public func decode<P>(_: DefaultCodable<P>.Type, forKey key: Key) throws -> DefaultCodable<P> {
    // Check if key exists
    if !contains(key) {
      #if DEBUG
      return DefaultCodable(wrappedValue: P.defaultValue, outcome: .keyNotFound)
      #else
      return DefaultCodable(wrappedValue: P.defaultValue)
      #endif
    }

    // Check for nil
    if (try? decodeNil(forKey: key)) == true {
      #if DEBUG
      return DefaultCodable(wrappedValue: P.defaultValue, outcome: .valueWasNil)
      #else
      return DefaultCodable(wrappedValue: P.defaultValue)
      #endif
    }

    // Try to decode normally
    if let value = try decodeIfPresent(DefaultCodable<P>.self, forKey: key) {
      return value
    } else {
      #if DEBUG
      return DefaultCodable(wrappedValue: P.defaultValue, outcome: .keyNotFound)
      #else
      return DefaultCodable(wrappedValue: P.defaultValue)
      #endif
    }
  }

  /// Default implementation of decoding a `DefaultCodable` where its strategy is a `BoolCodableStrategy`.
  ///
  /// Tries to initially Decode a `Bool` if available, otherwise tries to decode it as an `Int` or `String`
  /// when there is a `typeMismatch` decoding error. This preserves the actual value of the `Bool` in which
  /// the data provider might be sending the value as different types. If everything fails defaults to
  /// the `defaultValue` provided by the strategy.
  public func decode<P: BoolCodableStrategy>(_: DefaultCodable<P>.Type, forKey key: Key) throws -> DefaultCodable<P> {
    // Check if key exists
    if !contains(key) {
      #if DEBUG
      return DefaultCodable(wrappedValue: P.defaultValue, outcome: .keyNotFound)
      #else
      return DefaultCodable(wrappedValue: P.defaultValue)
      #endif
    }

    // Check for nil first
    if (try? decodeNil(forKey: key)) == true {
      #if DEBUG
      return DefaultCodable(wrappedValue: P.defaultValue, outcome: .valueWasNil)
      #else
      return DefaultCodable(wrappedValue: P.defaultValue)
      #endif
    }

    do {
      let value = try decode(Bool.self, forKey: key)
      return DefaultCodable(wrappedValue: value)
    } catch {
      guard
        let decodingError = error as? DecodingError,
        case .typeMismatch = decodingError
      else {
        // Report error and use default
        #if DEBUG
        let decoder = try? superDecoder(forKey: key)
        decoder?.reportError(error)
        return DefaultCodable(
          wrappedValue: P.defaultValue,
          outcome: .recoveredFrom(error, wasReported: decoder != nil),
        )
        #else
        return DefaultCodable(wrappedValue: P.defaultValue)
        #endif
      }

      if
        let intValue = try? decodeIfPresent(Int.self, forKey: key),
        let bool = Bool(exactly: NSNumber(value: intValue))
      {
        return DefaultCodable(wrappedValue: bool)
      }

      if
        let stringValue = try? decodeIfPresent(String.self, forKey: key),
        let bool = Bool(stringValue)
      {
        return DefaultCodable(wrappedValue: bool)
      }

      // Type mismatch - report error
      #if DEBUG
      let decoder = try? superDecoder(forKey: key)
      decoder?.reportError(decodingError)
      return DefaultCodable(
        wrappedValue: P.defaultValue,
        outcome: .recoveredFrom(decodingError, wasReported: decoder != nil),
      )
      #else
      return DefaultCodable(wrappedValue: P.defaultValue)
      #endif
    }
  }

  /// Decodes a DefaultCodable where the strategy's DefaultValue is RawRepresentable
  ///
  /// This method provides special handling for RawRepresentable types:
  /// - If `isFrozen` is false (default), unknown raw values result in UnknownNovelValueError and use the default value
  /// - If `isFrozen` is true, unknown raw values result in DecodingError and use the default value
  public func decode<P>(_: DefaultCodable<P>.Type, forKey key: Key) throws -> DefaultCodable<P>
    where P.DefaultValue: RawRepresentable, P.DefaultValue.RawValue: Decodable
  {
    // Check if key exists
    if !contains(key) {
      #if DEBUG
      return DefaultCodable(wrappedValue: P.defaultValue, outcome: .keyNotFound)
      #else
      return DefaultCodable(wrappedValue: P.defaultValue)
      #endif
    }

    // Check for nil
    if (try? decodeNil(forKey: key)) == true {
      #if DEBUG
      return DefaultCodable(wrappedValue: P.defaultValue, outcome: .valueWasNil)
      #else
      return DefaultCodable(wrappedValue: P.defaultValue)
      #endif
    }

    // Try to decode the raw value
    do {
      let rawValue = try decode(P.DefaultValue.RawValue.self, forKey: key)

      // Try to create the enum from raw value
      if let value = P.DefaultValue(rawValue: rawValue) {
        return DefaultCodable(wrappedValue: value)
      }

      #if DEBUG
      /// Unknown raw value
      let error = Self.createUnknownRawValueError(
        for: P.DefaultValue.self,
        rawValue: rawValue,
        codingPath: codingPath + [key],
        isFrozen: P.isFrozen,
      )

      let decoder = try? superDecoder(forKey: key)
      decoder?.reportError(error)
      return DefaultCodable(
        wrappedValue: P.defaultValue,
        outcome: .recoveredFrom(error, wasReported: decoder != nil)
      )
      #else
      return DefaultCodable(wrappedValue: P.defaultValue)
      #endif

    } catch {
      #if DEBUG
      /// Decoding the raw value failed (e.g., type mismatch)
      let decoder = try? superDecoder(forKey: key)
      decoder?.reportError(error)
      return DefaultCodable(
        wrappedValue: P.defaultValue,
        outcome: .recoveredFrom(error, wasReported: decoder != nil)
      )
      #else
      return DefaultCodable(wrappedValue: P.defaultValue)
      #endif
    }
  }

  private static func createUnknownRawValueError<T: RawRepresentable>(
    for type: T.Type,
    rawValue: T.RawValue,
    codingPath: [CodingKey],
    isFrozen: Bool,
  ) -> Error {
    guard isFrozen else { return UnknownNovelValueError(novelValue: rawValue) }
    let context = DecodingError.Context(
      codingPath: codingPath,
      debugDescription: "Cannot initialize \(type) from invalid raw value \(rawValue)",
    )
    return DecodingError.dataCorrupted(context)
  }
}
