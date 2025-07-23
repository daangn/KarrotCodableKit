//
//  ResilientDecodingOutcome.swift
//  KarrotCodableKit
//
//  Created by Elon on 4/9/25.
//

import Foundation

#if DEBUG
public enum ResilientDecodingOutcome: Sendable {
  case decodedSuccessfully
  case keyNotFound
  case valueWasNil
  case recoveredFrom(any Error, wasReported: Bool)
}

extension ResilientDecodingOutcome: Equatable {
  public static func == (lhs: ResilientDecodingOutcome, rhs: ResilientDecodingOutcome) -> Bool {
    switch (lhs, rhs) {
    case (.decodedSuccessfully, .decodedSuccessfully),
         (.keyNotFound, .keyNotFound),
         (.valueWasNil, .valueWasNil):
      return true
    case (.recoveredFrom(_, let lhsReported), .recoveredFrom(_, let rhsReported)):
      return lhsReported == rhsReported
    default:
      return false
    }
  }
}
#else
struct ResilientDecodingOutcome: Sendable {
  static let decodedSuccessfully = Self()
  static let keyNotFound = Self()
  static let valueWasNil = Self()
  static let recoveredFromDebugOnlyError = Self()
  static func recoveredFrom(_: any Error, wasReported: Bool) -> Self { Self() }
}
#endif