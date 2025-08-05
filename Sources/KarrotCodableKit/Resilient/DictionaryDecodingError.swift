//
//  DictionaryDecodingError.swift
//  KarrotCodableKit
//
//  Created by Elon on 7/28/25.
//

import Foundation

#if DEBUG
extension ResilientDecodingOutcome {
  public struct DictionaryDecodingError<Key: Hashable, Value>: Error {
    public let results: [Key: Result<Value, Error>]
    public var errors: [Key: Error] {
      results.compactMapValues(\.failure)
    }

    public init(results: [Key: Result<Value, Error>]) {
      self.results = results
    }
  }

  func dictionaryDecodingError<K: Hashable, V>() -> ResilientDecodingOutcome.DictionaryDecodingError<K, V> {
    typealias DictionaryDecodingError = ResilientDecodingOutcome.DictionaryDecodingError<K, V>
    switch self {
    case .decodedSuccessfully, .keyNotFound, .valueWasNil:
      return .init(results: [:])

    case .recoveredFrom(let error as DictionaryDecodingError, let wasReported):
      /// `DictionaryDecodingError` should not be reported
      assert(!wasReported)
      return error

    case .recoveredFrom:
      /// Unlike array, we chose not to provide the top level error in the dictionary since there isn't a good way to choose an appropriate key.
      return .init(results: [:])
    }
  }
}
#endif
