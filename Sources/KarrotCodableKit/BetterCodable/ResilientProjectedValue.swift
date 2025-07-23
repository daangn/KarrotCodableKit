//
//  ResilientProjectedValue.swift
//  KarrotCodableKit
//
//  Created by Elon on 4/9/25.
//

import Foundation

#if DEBUG
/// A base implementation for property wrapper projected values that track decoding outcomes.
///
/// This struct provides common functionality for all BetterCodable property wrappers' projected values,
/// including error tracking and resilient decoding outcome information.
public struct ResilientProjectedValue {
  public let outcome: ResilientDecodingOutcome
  
  public var error: Error? {
    switch outcome {
    case .decodedSuccessfully, .keyNotFound, .valueWasNil:
      return nil
    case .recoveredFrom(let error, _):
      return error
    }
  }
  
  public init(outcome: ResilientDecodingOutcome) {
    self.outcome = outcome
  }
}

/// A dynamic member lookup extension for array-based property wrappers.
///
/// This struct extends the base projected value with dynamic member lookup capabilities
/// for accessing detailed array decoding errors.
@dynamicMemberLookup
public struct ResilientArrayProjectedValue<Element> {
  public let outcome: ResilientDecodingOutcome
  
  public var error: Error? {
    switch outcome {
    case .decodedSuccessfully, .keyNotFound, .valueWasNil:
      return nil
    case .recoveredFrom(let error, _):
      return error
    }
  }
  
  public init(outcome: ResilientDecodingOutcome) {
    self.outcome = outcome
  }
  
  public subscript<U>(
    dynamicMember keyPath: KeyPath<ResilientDecodingOutcome.ArrayDecodingError<Element>, U>
  ) -> U {
    outcome.arrayDecodingError()[keyPath: keyPath]
  }
}

/// A dynamic member lookup extension for dictionary-based property wrappers.
///
/// This struct extends the base projected value with dynamic member lookup capabilities
/// for accessing detailed dictionary decoding errors.
@dynamicMemberLookup
public struct ResilientDictionaryProjectedValue<Key: Hashable, Value> {
  public let outcome: ResilientDecodingOutcome
  
  public var error: Error? {
    switch outcome {
    case .decodedSuccessfully, .keyNotFound, .valueWasNil:
      return nil
    case .recoveredFrom(let error, _):
      return error
    }
  }
  
  public init(outcome: ResilientDecodingOutcome) {
    self.outcome = outcome
  }
  
  public subscript<U>(
    dynamicMember keyPath: KeyPath<ResilientDecodingOutcome.DictionaryDecodingError<Key, Value>, U>
  ) -> U {
    outcome.dictionaryDecodingError()[keyPath: keyPath]
  }
}
#endif