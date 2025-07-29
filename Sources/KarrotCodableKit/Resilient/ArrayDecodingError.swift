//
//  ArrayDecodingError.swift
//  KarrotCodableKit
//
//  Created by Elon on 7/28/25.
//

import Foundation

#if DEBUG
extension ResilientDecodingOutcome {
  public struct ArrayDecodingError<Element>: Error {
    public let results: [Result<Element, Error>]
    public var errors: [Error] {
      results.compactMap { result in
        switch result {
        case .success:
          return nil
        case .failure(let error):
          return error
        }
      }
    }
    
    public init(results: [Result<Element, Error>]) {
      self.results = results
    }
  }
  
  func arrayDecodingError<T>() -> ResilientDecodingOutcome.ArrayDecodingError<T> {
    typealias ArrayDecodingError = ResilientDecodingOutcome.ArrayDecodingError<T>
    switch self {
    case .decodedSuccessfully, .keyNotFound, .valueWasNil:
      return .init(results: [])
    case let .recoveredFrom(error as ArrayDecodingError, wasReported):
      assert(!wasReported)
      return error
    case .recoveredFrom(let error, _):
      return .init(results: [.failure(error)])
    }
  }
}
#endif
