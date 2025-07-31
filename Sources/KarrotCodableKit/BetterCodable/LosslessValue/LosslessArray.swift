//
//  LosslessArray.swift
//  KarrotCodableKit
//
//  Created by Elon on 4/9/25.
//


import Foundation

/// Decodes Arrays by attempting to decode its elements into their preferred types.
///
/// `@LosslessArray` attempts to decode Arrays and their elements into their preferred types while preserving the data.
///
/// This is useful when data may return unpredictable values when a consumer is expecting a certain type. For instance,
/// if an API sends an array of SKUs as either `Int`s or `String`s, then a `@LosslessArray` can ensure the elements are
/// always decoded as `String`s.
@propertyWrapper
public struct LosslessArray<T: LosslessStringCodable> {
  public var wrappedValue: [T]
  
  public let outcome: ResilientDecodingOutcome

  public init(wrappedValue: [T]) {
    self.wrappedValue = wrappedValue
    self.outcome = .decodedSuccessfully
  }
  
  init(wrappedValue: [T], outcome: ResilientDecodingOutcome) {
    self.wrappedValue = wrappedValue
    self.outcome = outcome
  }
  
  #if DEBUG
  public var projectedValue: ResilientArrayProjectedValue<T> {
    ResilientArrayProjectedValue(outcome: outcome)
  }
  #endif
}

extension LosslessArray: Decodable where T: Decodable {
  private struct AnyDecodableValue: Decodable {}

  public init(from decoder: Decoder) throws {
    var container = try decoder.unkeyedContainer()

    var elements: [T] = []
    #if DEBUG
    var results: [Result<T, Error>] = []
    #endif
    
    while !container.isAtEnd {
      do {
        let value = try container.decode(LosslessValue<T>.self).wrappedValue
        elements.append(value)
        #if DEBUG
        results.append(.success(value))
        #endif
      } catch {
        _ = try? container.decode(AnyDecodableValue.self)
        decoder.reportError(error)
        #if DEBUG
        results.append(.failure(error))
        #endif
      }
    }

    #if DEBUG
    if elements.count == results.count {
      self.init(wrappedValue: elements, outcome: .decodedSuccessfully)
    } else {
      let error = ResilientDecodingOutcome.ArrayDecodingError(results: results)
      self.init(wrappedValue: elements, outcome: .recoveredFrom(error, wasReported: false))
    }
    #else
    self.init(wrappedValue: elements)
    #endif
  }
}

extension LosslessArray: Encodable where T: Encodable {
  public func encode(to encoder: Encoder) throws {
    try wrappedValue.encode(to: encoder)
  }
}

extension LosslessArray: Equatable where T: Equatable {
  public static func ==(lhs: Self, rhs: Self) -> Bool {
    lhs.wrappedValue == rhs.wrappedValue
  }
}

extension LosslessArray: Hashable where T: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(wrappedValue)
  }
}

extension LosslessArray: Sendable where T: Sendable {}
