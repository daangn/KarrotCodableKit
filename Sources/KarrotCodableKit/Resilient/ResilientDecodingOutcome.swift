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
      true
    case (.recoveredFrom(_, let lhsReported), .recoveredFrom(_, let rhsReported)):
      lhsReported == rhsReported
    default:
      false
    }
  }
}
#else
public struct ResilientDecodingOutcome: Sendable {
  public static let decodedSuccessfully = Self()
  public static let keyNotFound = Self()
  public static let valueWasNil = Self()
  public static let recoveredFromDebugOnlyError = Self()
  public static func recoveredFrom(_: any Error, wasReported: Bool) -> Self { Self() }
}
#endif
