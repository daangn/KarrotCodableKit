//
//  OptionalLosslessValue.swift
//  KarrotCodableKit
//
//  Created by Elon on 8/1/25.
//

import Foundation

/// Decodes Optional Codable values into their respective preferred types.
///
/// `@OptionalLosslessValueCodable` attempts to decode Optional Codable types into their preferred order while preserving the data in the most lossless format.
/// It handles `null` values and missing fields by setting the wrapped value to `nil`.
///
/// The preferred type order is provided by a generic `LosslessDecodingStrategy` that provides an ordered list of `losslessDecodableTypes`.
@propertyWrapper
public struct OptionalLosslessValueCodable<Strategy: LosslessDecodingStrategy>: Codable {

  private let type: LosslessStringCodable.Type?

  public var wrappedValue: Strategy.Value?

  public let outcome: ResilientDecodingOutcome

  public init(wrappedValue: Strategy.Value?) {
    self.wrappedValue = wrappedValue
    self.type = wrappedValue.map { Swift.type(of: $0) }
    self.outcome = wrappedValue == nil ? .valueWasNil : .decodedSuccessfully
  }

  init(
    wrappedValue: Strategy.Value?,
    outcome: ResilientDecodingOutcome,
    type: LosslessStringCodable.Type?
  ) {
    self.wrappedValue = wrappedValue
    self.outcome = outcome
    self.type = type
  }

  #if DEBUG
  public var projectedValue: ResilientProjectedValue {
    ResilientProjectedValue(outcome: outcome)
  }
  #endif

  public init(from decoder: Decoder) throws {
    do {
      // First, try to decode the value normally
      let value = try Strategy.Value(from: decoder)
      self.wrappedValue = value
      self.type = Strategy.Value.self
      self.outcome = .decodedSuccessfully

    } catch DecodingError.valueNotFound {
      // Handle null value
      self.wrappedValue = nil
      self.type = nil
      self.outcome = .valueWasNil

    } catch DecodingError.keyNotFound {
      // Handle missing key
      self.wrappedValue = nil
      self.type = nil
      self.outcome = .keyNotFound

    } catch {
      // Try to decode using the strategy's lossless decodable types
      if let rawValue = Strategy.losslessDecodableTypes.lazy.compactMap({ $0(decoder) }).first,
         let value = Strategy.Value("\(rawValue)") {
        self.wrappedValue = value
        self.type = Swift.type(of: rawValue)
        self.outcome = .decodedSuccessfully
        return
      }

      // If we still can't decode, check if it's a null value
      let singleValueContainer = try decoder.singleValueContainer()
      guard singleValueContainer.decodeNil() else {
        #if DEBUG
        decoder.reportError(error)
        #endif
        throw error
      }

      self.wrappedValue = nil
      self.type = nil
      self.outcome = .valueWasNil
    }
  }

  public func encode(to encoder: Encoder) throws {
    guard let value = wrappedValue else {
      var container = encoder.singleValueContainer()
      try container.encodeNil()
      return
    }

    let string = String(describing: value)

    if let originalType = type, let original = originalType.init(string) {
      try original.encode(to: encoder)
      return
    }

    // If we don't have the original type, encode the value directly
    try value.encode(to: encoder)
  }
}

extension OptionalLosslessValueCodable: Equatable where Strategy.Value: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.wrappedValue == rhs.wrappedValue
  }
}

extension OptionalLosslessValueCodable: Hashable where Strategy.Value: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(wrappedValue)
  }
}

extension OptionalLosslessValueCodable: Sendable where Strategy.Value: Sendable {}

/// Decodes Optional Codable values into their respective preferred types.
///
/// `@OptionalLosslessValue` attempts to decode Optional Codable types into their respective preferred types while preserving the data.
/// It handles `null` values and missing fields gracefully by returning `nil`.
///
/// This is useful when data may return unpredictable values or null when a consumer is expecting a certain type. For instance,
/// if an API sends SKUs as either an `Int`, `String`, or `null`, then a `@OptionalLosslessValue` can ensure the types are always decoded
/// as `String?` with proper null handling.
///
/// ```
/// struct Product: Codable {
///   @OptionalLosslessValue var sku: String?
///   @OptionalLosslessValue var id: String?
/// }
///
/// // json: { "sku": 87, "id": null }
/// let value = try JSONDecoder().decode(Product.self, from: json)
/// // value.sku == "87"
/// // value.id == nil
/// ```
public typealias OptionalLosslessValue<
  T: LosslessStringCodable
> = OptionalLosslessValueCodable<LosslessDefaultStrategy<T>>

/// Decodes Optional Codable values into their respective preferred types with boolean-specific handling.
///
/// `@OptionalLosslessBoolValue` attempts to decode Optional Codable types into boolean types with special handling for various string representations.
/// It handles common boolean string values like "true", "yes", "1", "y", "t" as true, and their opposites as false.
///
/// ```
/// struct Settings: Codable {
///   @OptionalLosslessBoolValue var enableFeature: Bool?
/// }
///
/// // json: { "enableFeature": "yes" }
/// let value = try JSONDecoder().decode(Settings.self, from: json)
/// // value.enableFeature == true
/// ```
public typealias OptionalLosslessBoolValue<
  T: LosslessStringCodable
> = OptionalLosslessValueCodable<LosslessBooleanStrategy<T>>

/// Extension for KeyedDecodingContainer to handle OptionalLosslessValue
extension KeyedDecodingContainer {
  public func decode<T>(
    _ type: OptionalLosslessValueCodable<T>.Type,
    forKey key: Self.Key
  ) throws -> OptionalLosslessValueCodable<T> where T.Value: Decodable {
    guard contains(key) else {
      return OptionalLosslessValueCodable<T>(wrappedValue: nil, outcome: .keyNotFound, type: nil)
    }

    if let value = try decodeIfPresent(type, forKey: key) {
      return value
    }

    return OptionalLosslessValueCodable<T>(wrappedValue: nil, outcome: .valueWasNil, type: nil)
  }
}
