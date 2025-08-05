//
//  PolymorphicProjectedValue.swift
//  KarrotCodableKit
//
//  Created by Elon on 2025-07-23.
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

import Foundation

#if DEBUG
/// Common protocol for polymorphic projected values.
public protocol PolymorphicProjectedValueProtocol {
  var outcome: ResilientDecodingOutcome { get }
  var error: Error? { get }
}

/// Default implementation for error extraction.
extension PolymorphicProjectedValueProtocol {
  public var error: Error? {
    switch outcome {
    case .decodedSuccessfully, .keyNotFound, .valueWasNil:
      nil
    case .recoveredFrom(let error, _):
      error
    }
  }
}

/// A generic projected value for polymorphic property wrappers.
///
/// This struct provides common functionality for all polymorphic property wrappers' projected values,
/// including error tracking and resilient decoding outcome information.
public struct PolymorphicProjectedValue: PolymorphicProjectedValueProtocol {
  /// The outcome of the decoding process
  public let outcome: ResilientDecodingOutcome

  public init(outcome: ResilientDecodingOutcome) {
    self.outcome = outcome
  }
}

/// A specialized projected value for lossy array property wrappers that includes element-level results.
///
/// This struct extends the base projected value with additional information about individual
/// element decoding results for lossy array operations.
public struct PolymorphicLossyArrayProjectedValue<T>: PolymorphicProjectedValueProtocol {
  /// The outcome of the decoding process
  public let outcome: ResilientDecodingOutcome

  /// Results of decoding each element in the array
  public let results: [Result<T, Error>]

  public init(outcome: ResilientDecodingOutcome, results: [Result<T, Error>]) {
    self.outcome = outcome
    self.results = results
  }
}
#endif
