//
//  ResilientDecodingOutcome.swift
//  KarrotCodableKit
//
//  Created by Elon on 4/9/25.
//

import Foundation

#if DEBUG
public enum ResilientDecodingOutcome {
  case decodedSuccessfully
  case keyNotFound
  case valueWasNil
  case recoveredFrom(Error, wasReported: Bool)
}
#else
struct ResilientDecodingOutcome {
  static let decodedSuccessfully = Self()
  static let keyNotFound = Self()
  static let valueWasNil = Self()
  static let recoveredFromDebugOnlyError = Self()
  static func recoveredFrom(_: Error, wasReported: Bool) -> Self { Self() }
}
#endif