//
//  ArrayDecodingError.swift
//  KarrotCodableKit
//
//  Created by Elon on 7/28/25.
//

import Foundation

#if DEBUG
extension ResilientDecodingOutcome {
  /// A type representing some number of errors encountered while decoding an array
  public struct ArrayDecodingError<Element>: Error {
    public let results: [Result<Element, Error>]
    public var errors: [Error] {
      results.compactMap(\.failure)
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

    case .recoveredFrom(let error as ArrayDecodingError, let wasReported):
      /// `ArrayDecodingError` should not be reported
      assert(!wasReported)
      return error

    case .recoveredFrom(let error, _):
      /// When recovering from a top level error, we can provide the error value in the array,
      /// instead of returning an empty array. We believe this is a win for usability.
      return .init(results: [.failure(error)])
    }
  }
}
#endif
