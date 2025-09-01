//
//  LossyArray.swift
//  KarrotCodableKit
//
//  Created by Elon on 4/9/25.
//

import Foundation

/// Decodes Arrays filtering invalid values if applicable
///
/// `@LossyArray` decodes Arrays and filters invalid values if the Decoder is unable to decode the value.
///
/// This is useful if the Array is intended to contain non-optional types.
@propertyWrapper
public struct LossyArray<T> {
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

extension LossyArray: Decodable where T: Decodable {
  private struct AnyDecodableValue: Decodable {}

  public init(from decoder: Decoder) throws {
    do {
      // Check for null first
      let singleValueContainer = try decoder.singleValueContainer()
      if singleValueContainer.decodeNil() {
        #if DEBUG
        let context = DecodingError.Context(
          codingPath: decoder.codingPath,
          debugDescription: "Value was nil but property is non-optional"
        )
        let error = DecodingError.valueNotFound([T].self, context)
        decoder.reportError(error)
        self.init(wrappedValue: [], outcome: .recoveredFrom(error, wasReported: true))
        #else
        self.init(wrappedValue: [])
        #endif
        return
      }
    } catch {
      // Not a single value container, proceed with array decoding
    }

    do {
      var container = try decoder.unkeyedContainer()

      var elements: [T] = []
      #if DEBUG
      var results: [Result<T, Error>] = []
      #endif

      while !container.isAtEnd {
        let elementDecoder = try container.superDecoder()
        do {
          let value = try elementDecoder.singleValueContainer().decode(T.self)
          elements.append(value)
          #if DEBUG
          results.append(.success(value))
          #endif
        } catch {
          #if DEBUG
          elementDecoder.reportError(error)
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
    } catch {
      #if DEBUG
      decoder.reportError(error)
      self.init(wrappedValue: [], outcome: .recoveredFrom(error, wasReported: true))
      #else
      self.init(wrappedValue: [])
      #endif
    }
  }
}

extension LossyArray: Encodable where T: Encodable {
  public func encode(to encoder: Encoder) throws {
    try wrappedValue.encode(to: encoder)
  }
}

extension LossyArray: Equatable where T: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.wrappedValue == rhs.wrappedValue
  }
}

extension LossyArray: Hashable where T: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(wrappedValue)
  }
}

extension LossyArray: Sendable where T: Sendable {}
