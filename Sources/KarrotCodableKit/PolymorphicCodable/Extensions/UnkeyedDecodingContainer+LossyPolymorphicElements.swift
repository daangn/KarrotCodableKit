//
//  UnkeyedDecodingContainer+LossyPolymorphicElements.swift
//  KarrotCodableKit
//
//  Created by Elon on 7/15/26.
//  Copyright © 2026 Danggeun Market Inc. All rights reserved.
//

import Foundation

extension UnkeyedDecodingContainer {
  /// Decodes every element with the polymorphic `strategy`, capturing each element's result
  /// instead of throwing, so lossy array wrappers can keep valid elements and record failures.
  mutating func decodeLossyPolymorphicElementResults<Strategy: PolymorphicCodableStrategy>(
    of strategy: Strategy.Type
  ) throws -> [Result<Strategy.ExpectedType, Error>] {
    var results = [Result<Strategy.ExpectedType, Error>]()

    while !isAtEnd {
      // Decoding through the element's super decoder always advances the container,
      // even when the element fails to decode.
      let elementDecoder = try superDecoder()
      do {
        try results.append(.success(PolymorphicValue<Strategy>(from: elementDecoder).wrappedValue))
      } catch {
        #if DEBUG
        elementDecoder.reportError(error)
        #endif
        results.append(.failure(error))
      }
    }

    return results
  }
}
