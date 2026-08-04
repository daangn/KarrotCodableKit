//
//  HandWrittenStrategyDummy.swift
//  KarrotCodableKit
//
//  Created by Elon on 8/4/26.
//  Copyright © 2026 Danggeun Market Inc. All rights reserved.
//

import Foundation

import KarrotCodableKit

/// A strategy written by hand, deliberately conforming to `PolymorphicCodableStrategy` only.
///
/// `PolymorphicMatchingTypesProviding` refines `PolymorphicCodableStrategy` instead of adding
/// requirements to it, so strategies like this one keep working untouched. This double guards that
/// promise — if the requirements ever move onto the base protocol, this file stops compiling.
struct HandWrittenNoticeCodableStrategy: PolymorphicCodableStrategy {
  enum PolymorphicMetaCodingKey: CodingKey {
    case type
  }

  static var polymorphicMetaCodingKey: CodingKey {
    PolymorphicMetaCodingKey.type
  }

  static func decode(from decoder: Decoder) throws -> any DummyNotice {
    try decoder.decode(
      codingKey: Self.polymorphicMetaCodingKey,
      matchingTypes: [
        DummyCallout.self,
        DummyActionableCallout.self,
      ],
      fallbackType: DummyUndefinedCallout.self,
    )
  }
}

@CustomCodable(codingKeyStyle: .snakeCase)
struct HandWrittenStrategyDummyResponse {

  @PolymorphicValue<HandWrittenNoticeCodableStrategy>
  var notice: any DummyNotice
}
