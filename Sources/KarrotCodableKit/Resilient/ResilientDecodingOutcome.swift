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
#else
struct ResilientDecodingOutcome: Sendable {
  static let decodedSuccessfully = Self()
  static let keyNotFound = Self()
  static let valueWasNil = Self()
  static let recoveredFromDebugOnlyError = Self()
  static func recoveredFrom(_: any Error, wasReported: Bool) -> Self { Self() }
}
#endif