//
//  LosslessDecodingStrategy.swift
//  KarrotCodableKit
//
//  Created by Elon on 4/9/25.
//

import Foundation

public typealias LosslessStringCodable = Codable & LosslessStringConvertible

/// Provides an ordered list of types for decoding the lossless value, prioritizing the first type that successfully decodes as the inferred type.
///
/// `LosslessDecodingStrategy` provides a generic strategy that the `LosslessValueCodable` property wrapper can use to provide
/// the ordered list of decodable types in order to maximize preservation for the inferred type.
public protocol LosslessDecodingStrategy {
  associatedtype Value: LosslessStringCodable

  /// An ordered list of decodable scenarios used to infer the encoded type
  static var losslessDecodableTypes: [(Decoder) -> LosslessStringCodable?] { get }
}

/// Decodes Codable values into their respective preferred types.
///
/// `@LosslessValueCodable` attempts to decode Codable types into their preferred order while preserving the data in the most lossless format.
///
/// The preferred type order is provided by a generic `LosslessDecodingStrategy` that provides an ordered list of `losslessDecodableTypes`.
@propertyWrapper
public struct LosslessValueCodable<Strategy: LosslessDecodingStrategy>: Codable {
  private let type: LosslessStringCodable.Type

  public var wrappedValue: Strategy.Value

  public init(wrappedValue: Strategy.Value) {
    self.wrappedValue = wrappedValue
    self.type = Strategy.Value.self
  }

  public init(from decoder: Decoder) throws {
    do {
      self.wrappedValue = try Strategy.Value(from: decoder)
      self.type = Strategy.Value.self
    } catch let error {
      guard let rawValue = Strategy.losslessDecodableTypes.lazy.compactMap({ $0(decoder) }).first,
            let value = Strategy.Value("\(rawValue)")
      else { throw error }

      self.wrappedValue = value
      self.type = Swift.type(of: rawValue)
    }
  }

  public func encode(to encoder: Encoder) throws {
    let string = String(describing: wrappedValue)

    guard let original = type.init(string) else {
      let description = "Unable to encode '\(wrappedValue)' back to source type '\(type)'"
      throw EncodingError.invalidValue(string, .init(codingPath: [], debugDescription: description))
    }

    try original.encode(to: encoder)
  }
}

extension LosslessValueCodable: Equatable where Strategy.Value: Equatable {
  public static func == (lhs: LosslessValueCodable<Strategy>, rhs: LosslessValueCodable<Strategy>) -> Bool {
    lhs.wrappedValue == rhs.wrappedValue
  }
}

extension LosslessValueCodable: Hashable where Strategy.Value: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(wrappedValue)
  }
}

extension LosslessValueCodable: Sendable where Strategy.Value: Sendable {}

public struct LosslessDefaultStrategy<Value: LosslessStringCodable>: LosslessDecodingStrategy {
  public static var losslessDecodableTypes: [(Decoder) -> LosslessStringCodable?] {
    @inline(__always)
    func decode<T: LosslessStringCodable>(_: T.Type) -> (Decoder) -> LosslessStringCodable? {
      { try? T(from: $0) }
    }

    return [
      decode(String.self),
      decode(Bool.self),
      decode(Int.self),
      decode(Int8.self),
      decode(Int16.self),
      decode(Int64.self),
      decode(UInt.self),
      decode(UInt8.self),
      decode(UInt16.self),
      decode(UInt64.self),
      decode(Double.self),
      decode(Float.self),
    ]
  }
}

/// Decodes Codable values into their respective preferred types.
///
/// `@LosslessValue` attempts to decode Codable types into their respective preferred types while preserving the data.
///
/// This is useful when data may return unpredictable values when a consumer is expecting a certain type. For instance,
/// if an API sends SKUs as either an `Int` or `String`, then a `@LosslessValue` can ensure the types are always decoded
/// as `String`s.
///
/// ```
/// struct Product: Codable {
///   @LosslessValue var sku: String
///   @LosslessValue var id: String
/// }
///
/// // json: { "sku": 87, "id": 123 }
/// let value = try JSONDecoder().decode(Product.self, from: json)
/// // value.sku == "87"
/// // value.id == "123"
/// ```
public typealias LosslessValue<
  T: LosslessStringCodable
> = LosslessValueCodable<LosslessDefaultStrategy<T>>


