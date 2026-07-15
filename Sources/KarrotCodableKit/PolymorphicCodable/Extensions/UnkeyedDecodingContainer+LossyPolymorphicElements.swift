//
//  UnkeyedDecodingContainer+LossyPolymorphicElements.swift
//  KarrotCodableKit
//
//  Created by Elon on 7/15/26.
//  Copyright © 2026 Danggeun Market Inc. All rights reserved.
//

import Foundation

/// The outcome of a lossy polymorphic array pass. Per-element results are retained only in
/// DEBUG builds, so release builds allocate a single element array and no `Result` storage.
struct LossyPolymorphicElements<Element> {
  let elements: [Element]
  #if DEBUG
  let results: [Result<Element, Error>]
  #endif
}

extension UnkeyedDecodingContainer {
  /// Decodes every element with the polymorphic `strategy`, skipping elements that fail to
  /// decode instead of throwing, so lossy array wrappers can keep the valid elements.
  /// In DEBUG builds each element's `Result` is also captured for resilient decoding outcomes.
  mutating func decodeLossyPolymorphicElements<Strategy: PolymorphicCodableStrategy>(
    of strategy: Strategy.Type
  ) throws -> LossyPolymorphicElements<Strategy.ExpectedType> {
    var elements = [Strategy.ExpectedType]()
    #if DEBUG
    var results = [Result<Strategy.ExpectedType, Error>]()
    #endif

    while !isAtEnd {
      // Decoding through the element's super decoder always advances the container,
      // even when the element fails to decode.
      let elementDecoder = try superDecoder()
      do {
        let value = try PolymorphicValue<Strategy>(from: elementDecoder).wrappedValue
        elements.append(value)
        #if DEBUG
        results.append(.success(value))
        #endif
      } catch {
        #if DEBUG
        elementDecoder.reportError(error)
        results.append(.failure(error))
        #endif
      }
    }

    #if DEBUG
    return LossyPolymorphicElements(elements: elements, results: results)
    #else
    return LossyPolymorphicElements(elements: elements)
    #endif
  }
}
