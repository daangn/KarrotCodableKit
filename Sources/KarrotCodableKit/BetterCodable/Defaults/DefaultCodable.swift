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
}

/// Decodes values with a reasonable default value
///
/// `@Defaultable` attempts to decode a value and falls back to a default type provided by the generic
/// `DefaultCodableStrategy`.
@propertyWrapper
public struct DefaultCodable<Default: DefaultCodableStrategy> {
  public var wrappedValue: Default.DefaultValue
  
  let outcome: ResilientDecodingOutcome

  public init(wrappedValue: Default.DefaultValue) {
    self.wrappedValue = wrappedValue
    self.outcome = .decodedSuccessfully
  }
  
  init(wrappedValue: Default.DefaultValue, outcome: ResilientDecodingOutcome) {
    self.wrappedValue = wrappedValue
    self.outcome = outcome
  }
  
  #if DEBUG
  public struct ProjectedValue {
    public let outcome: ResilientDecodingOutcome
    
    public var error: Error? {
      switch outcome {
      case .decodedSuccessfully, .keyNotFound, .valueWasNil:
        return nil
      case .recoveredFrom(let error, _):
        return error
      }
    }
  }
  
  public var projectedValue: ProjectedValue { ProjectedValue(outcome: outcome) }
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
      decoder.reportError(error)
      #if DEBUG
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
  public static func ==(lhs: Self, rhs: Self) -> Bool {
    lhs.wrappedValue == rhs.wrappedValue
  }
}

extension DefaultCodable: Hashable where Default.DefaultValue: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(wrappedValue)
  }
}

extension DefaultCodable: Sendable where Default.DefaultValue: Sendable {}

// MARK: - KeyedDecodingContainer
public protocol BoolCodableStrategy: DefaultCodableStrategy where DefaultValue == Bool {}

extension KeyedDecodingContainer {

  /// Default implementation of decoding a DefaultCodable
  ///
  /// Decodes successfully if key is available if not fallsback to the default value provided.
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
    } catch let error {
      guard let decodingError = error as? DecodingError,
            case .typeMismatch = decodingError else {
        // Report error and use default
        let decoder = try superDecoder(forKey: key)
        decoder.reportError(error)
        #if DEBUG
        return DefaultCodable(wrappedValue: P.defaultValue, outcome: .recoveredFrom(error, wasReported: true))
        #else
        return DefaultCodable(wrappedValue: P.defaultValue)
        #endif
      }
      if let intValue = try? decodeIfPresent(Int.self, forKey: key),
         let bool = Bool(exactly: NSNumber(value: intValue)) {
        return DefaultCodable(wrappedValue: bool)
      } else if let stringValue = try? decodeIfPresent(String.self, forKey: key),
                let bool = Bool(stringValue) {
        return DefaultCodable(wrappedValue: bool)
      } else {
        // Type mismatch - report error
        let decoder = try superDecoder(forKey: key)
        decoder.reportError(decodingError)
        #if DEBUG
        return DefaultCodable(wrappedValue: P.defaultValue, outcome: .recoveredFrom(decodingError, wasReported: true))
        #else
        return DefaultCodable(wrappedValue: P.defaultValue)
        #endif
      }
    }
  }
}
