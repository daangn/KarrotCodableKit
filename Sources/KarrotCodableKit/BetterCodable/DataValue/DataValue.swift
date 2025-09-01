//
//  DataValue.swift
//  KarrotCodableKit
//
//  Created by Elon on 4/9/25.
//

import Foundation

/// A protocol for providing a custom strategy for encoding and decoding data as strings.
///
/// `DataValueCodableStrategy` provides a generic strategy type that the `DataValue` property wrapper can use to inject
///  custom strategies for encoding and decoding data values.
///
public protocol DataValueCodableStrategy {
  associatedtype DataType: MutableDataProtocol
  static func decode(_ value: String) throws -> DataType
  static func encode(_ data: DataType) -> String
}

/// Decodes and encodes data using a strategy type.
///
/// `@DataValue` decodes data using a `DataValueCodableStrategy` which provides custom decoding and encoding functionality.
@propertyWrapper
public struct DataValue<Coder: DataValueCodableStrategy> {
  public var wrappedValue: Coder.DataType

  public let outcome: ResilientDecodingOutcome

  public init(wrappedValue: Coder.DataType) {
    self.wrappedValue = wrappedValue
    self.outcome = .decodedSuccessfully
  }

  init(wrappedValue: Coder.DataType, outcome: ResilientDecodingOutcome) {
    self.wrappedValue = wrappedValue
    self.outcome = outcome
  }

  #if DEBUG
  public var projectedValue: ResilientProjectedValue {
    ResilientProjectedValue(outcome: outcome)
  }
  #endif
}

extension DataValue: Decodable {
  public init(from decoder: Decoder) throws {
    do {
      let stringValue = try String(from: decoder)
      self.wrappedValue = try Coder.decode(stringValue)
      self.outcome = .decodedSuccessfully
    } catch {
      #if DEBUG
      decoder.reportError(error)
      #endif
      throw error
    }
  }
}

extension DataValue: Encodable {
  public func encode(to encoder: Encoder) throws {
    try Coder.encode(wrappedValue).encode(to: encoder)
  }
}

extension DataValue: Equatable where Coder.DataType: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.wrappedValue == rhs.wrappedValue
  }
}

extension DataValue: Hashable where Coder.DataType: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(wrappedValue)
  }
}

extension DataValue: Sendable where Coder.DataType: Sendable {}
