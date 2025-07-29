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
      results.compactMapValues { result in
        switch result {
        case .success:
          return nil
        case .failure(let error):
          return error
        }
      }
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
    case let .recoveredFrom(error as DictionaryDecodingError, wasReported):
      assert(!wasReported)
      return error
    case .recoveredFrom(_, _):
      return .init(results: [:])
    }
  }
}
#endif
