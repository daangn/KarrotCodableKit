//
//  DefaultCodable.swift
//  KarrotCodableKit
//
//  Created by Elon on 4/9/25.
//

import Foundation

/// Provides a default value for missing `Decodable` data.
///
/// `DefaultCodableStrategy` provides a generic strategy type that the `DefaultCodable` property wrapper can use to provide
/// a reasonable default value for missing Decodable data.
public protocol DefaultCodableStrategy {
  associatedtype DefaultValue: Decodable

  /// The fallback value used when decoding fails
  static var defaultValue: DefaultValue { get }

  /// When true, unknown raw values for RawRepresentable types will be reported as errors.
  /// When false, unknown raw values will use the defaultValue without reporting an error.
  /// Defaults to false.
  static var isFrozen: Bool { get }
}

/// Default implementation
extension DefaultCodableStrategy {
  public static var isFrozen: Bool { false }
}

/// Decodes values with a reasonable default value
///
/// `@Defaultable` attempts to decode a value and falls back to a default type provided by the generic
/// `DefaultCodableStrategy`.
@propertyWrapper
public struct DefaultCodable<Default: DefaultCodableStrategy> {
  public var wrappedValue: Default.DefaultValue

  public let outcome: ResilientDecodingOutcome

  public init(wrappedValue: Default.DefaultValue) {
    self.wrappedValue = wrappedValue
    self.outcome = .decodedSuccessfully
  }

  init(wrappedValue: Default.DefaultValue, outcome: ResilientDecodingOutcome) {
    self.wrappedValue = wrappedValue
    self.outcome = outcome
  }

  #if DEBUG
  public var projectedValue: ResilientProjectedValue {
    ResilientProjectedValue(outcome: outcome)
  }
  #endif
}

extension DefaultCodable where Default.Type == Default.DefaultValue.Type {
  public init(wrappedValue: Default) {
    self.wrappedValue = wrappedValue
    self.outcome = .decodedSuccessfully
  }
}

extension DefaultCodable: Decodable {
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()

    // Check for nil first
    if container.decodeNil() {
      #if DEBUG
      self.init(wrappedValue: Default.defaultValue, outcome: .valueWasNil)
      #else
      self.init(wrappedValue: Default.defaultValue)
      #endif
      return
    }

    do {
      let value = try container.decode(Default.DefaultValue.self)
      self.init(wrappedValue: value)
    } catch {
      #if DEBUG
      decoder.reportError(error)
      self.init(wrappedValue: Default.defaultValue, outcome: .recoveredFrom(error, wasReported: true))
      #else
      self.init(wrappedValue: Default.defaultValue)
      #endif
    }
  }
}

extension DefaultCodable: Encodable where Default.DefaultValue: Encodable {
  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(wrappedValue)
  }
}

extension DefaultCodable: Equatable where Default.DefaultValue: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.wrappedValue == rhs.wrappedValue
  }
}

extension DefaultCodable: Hashable where Default.DefaultValue: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(wrappedValue)
  }
}

extension DefaultCodable: Sendable where Default.DefaultValue: Sendable {}
