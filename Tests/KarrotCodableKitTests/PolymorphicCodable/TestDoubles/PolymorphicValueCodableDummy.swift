//
//  PolymorphicValueDummy.swift
//
//
//  Created by Elon on 10/14/24.
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

import Foundation

import KarrotCodableKit

@PolymorphicEnumCodable(fallbackCaseName: "undefinedCallout")
enum CalloutBadge {
  case callout(_ a: DummyCallout)
  case actionableCallout(DummyActionableCallout)
  case dismissibleCallout(value: DummyDismissibleCallout)
  case undefinedCallout(DummyUndefinedCallout)
}

@CustomCodable(codingKeyStyle: .snakeCase)
struct DummyResponse {

  @PolymorphicValue<DummyNoticeCodableStrategy>
  var notice: DummyNotice

  @PolymorphicArrayValue<DummyNoticeCodableStrategy>
  var notices: [DummyNotice]
}

@CustomCodable(codingKeyStyle: .snakeCase)
struct OptionalDummyResponse {

  @DefaultNilPolymorphicValue<DummyNoticeCodableStrategy>
  var notice1: DummyNotice?

  @DefaultNilPolymorphicValue<DummyNoticeCodableStrategy>
  var notice2: DummyNotice?
}

@CustomCodable(codingKeyStyle: .snakeCase)
struct OptionalArrayDummyResponse {

  @DefaultEmptyPolymorphicArrayValue<DummyNoticeCodableStrategy>
  var notices1: [DummyNotice]

  @DefaultEmptyPolymorphicArrayValue<DummyNoticeCodableStrategy>
  var notices2: [DummyNotice]
}

@CustomCodable(codingKeyStyle: .snakeCase)
struct OptionalLossyArrayDummyResponse {

  @DefaultEmptyPolymorphicLossyArrayValue<DummyNoticeCodableStrategy>
  var notices1: [DummyNotice]

  @DefaultEmptyPolymorphicLossyArrayValue<DummyNoticeCodableStrategy>
  var notices2: [DummyNotice]
}

@PolymorphicCodableStrategyProviding(
  identifierCodingKey: "type",
  matchingTypes: [
    DummyCallout.self,
    DummyActionableCallout.self,
    DummyDismissibleCallout.self,
  ],
  fallbackType: DummyUndefinedCallout.self
)
public protocol DummyNotice: Codable {
  var type: DummyNoticeType { get }
  var title: String? { get }
  var description: String { get }
}

public enum DummyNoticeType: String, Codable, DefaultCodableStrategy {

  public static let defaultValue = DummyNoticeType.undefinedCallout

  case callout
  case actionableCallout = "actionable-callout"
  case dismissibleCallout = "dismissible-callout"
  case undefinedCallout = "undefined-callout"
}

@PolymorphicCodable(identifier: "callout", codingKeyStyle: .snakeCase)
struct DummyCallout: DummyNotice {
  let type: DummyNoticeType
  let title: String?
  let description: String
  let icon: String?
}

@PolymorphicCodable(identifier: "actionable-callout", codingKeyStyle: .snakeCase)
struct DummyActionableCallout: DummyNotice {
  let type: DummyNoticeType
  let title: String?
  let description: String
  let action: URL
}

@PolymorphicCodable(identifier: "dismissible-callout", codingKeyStyle: .snakeCase)
struct DummyDismissibleCallout: DummyNotice {
  let type: DummyNoticeType
  let title: String?
  let description: String
  let key: String
}

@PolymorphicCodable(identifier: "undefined-callout", codingKeyStyle: .snakeCase)
struct DummyUndefinedCallout: DummyNotice {
  @DefaultCodable
  var type = DummyNoticeType.undefinedCallout
  let title: String?
  let description: String
}
