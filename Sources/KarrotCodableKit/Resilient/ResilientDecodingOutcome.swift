//
//  ResilientDecodingOutcome.swift
//  KarrotCodableKit
//
//  Created by Elon on 7/28/25.
//

import Foundation

#if DEBUG
public enum ResilientDecodingOutcome: Sendable {
  /// A value was decoded successfully
  case decodedSuccessfully
  /// The key was missing, and it was not treated as an error (for instance when decoding an `Optional`)
  case keyNotFound
  /// The value was `nil`, and it was not treated as an error (for instance when decoding an `Optional`)
  case valueWasNil
  /// An error was recovered from during decoding
  /// - parameter `wasReported`: Some errors are not reported, for instance `ArrayDecodingError`
  case recoveredFrom(any Error, wasReported: Bool)
}

extension ResilientDecodingOutcome: Equatable {
  public static func == (lhs: ResilientDecodingOutcome, rhs: ResilientDecodingOutcome) -> Bool {
    switch (lhs, rhs) {
    case (.decodedSuccessfully, .decodedSuccessfully),
         (.keyNotFound, .keyNotFound),
         (.valueWasNil, .valueWasNil):
      true
    case (.recoveredFrom(_, let lhsReported), .recoveredFrom(_, let rhsReported)):
      lhsReported == rhsReported
    default:
      false
    }
  }
}
#else
/// In release, we don't want the decoding outcome mechanism taking up space,
/// so we define an empty struct with `static` properties and functions which match the `enum` above.
/// This reduces the number of places we need to use `#if DEBUG` substantially.
public struct ResilientDecodingOutcome: Sendable {
  public static let decodedSuccessfully = Self()
  public static let keyNotFound = Self()
  public static let valueWasNil = Self()
  public static let recoveredFromDebugOnlyError = Self()
  public static func recoveredFrom(_: any Error, wasReported: Bool) -> Self { Self() }
}
#endif
