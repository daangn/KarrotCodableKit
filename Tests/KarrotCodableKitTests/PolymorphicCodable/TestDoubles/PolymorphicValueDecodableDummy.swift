//
//  PolymorphicValueDecodableDummy.swift
//  KarrotCodableKit
//
//  Created by Elon on 6/10/25.
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

import Foundation

import KarrotCodableKit

// MARK: - PolymorphicEnumDecodable

@PolymorphicEnumDecodable(fallbackCaseName: "undefinedCallout")
enum DecodableCalloutBadge {
  case callout(_ a: DummyDecodableCallout)
  case actionableCallout(DummyActionableDecodableCallout)
  case dismissibleCallout(value: DummyDismissibleDecodableCallout)
  case undefinedCallout(DummyUndefinedDecodableCallout)
}

@CustomDecodable(codingKeyStyle: .snakeCase)
struct DummyDecodableResponse {

  @PolymorphicValue<DummyDecodableNoticeCodableStrategy>
  var notice: DummyDecodableNotice

  @PolymorphicArrayValue<DummyDecodableNoticeCodableStrategy>
  var notices: [DummyDecodableNotice]
}

@CustomDecodable(codingKeyStyle: .snakeCase)
struct OptionalDummyDecodableResponse {

  @DefaultNilPolymorphicValue<DummyDecodableNoticeCodableStrategy>
  var notice1: DummyDecodableNotice?

  @DefaultNilPolymorphicValue<DummyDecodableNoticeCodableStrategy>
  var notice2: DummyDecodableNotice?

  @DefaultNilPolymorphicValue<DummyDecodableNoticeCodableStrategy>
  var notice3: DummyDecodableNotice?
}

@CustomDecodable(codingKeyStyle: .snakeCase)
struct OptionalAarrayDummyDecodableResponse {

  @DefaultEmptyPolymorphicArrayValue<DummyDecodableNoticeCodableStrategy>
  var notices1: [DummyDecodableNotice]

  @DefaultEmptyPolymorphicArrayValue<DummyDecodableNoticeCodableStrategy>
  var notices2: [DummyDecodableNotice]

  @DefaultEmptyPolymorphicArrayValue<DummyDecodableNoticeCodableStrategy>
  var notices3: [DummyDecodableNotice]
}

@CustomDecodable(codingKeyStyle: .snakeCase)
struct OptionalLossyAarrayDummyDecodableResponse {

  @DefaultEmptyPolymorphicLossyArrayValue<DummyDecodableNoticeCodableStrategy>
  var notices1: [DummyDecodableNotice]

  @DefaultEmptyPolymorphicLossyArrayValue<DummyDecodableNoticeCodableStrategy>
  var notices2: [DummyDecodableNotice]

  @DefaultEmptyPolymorphicLossyArrayValue<DummyDecodableNoticeCodableStrategy>
  var notices3: [DummyDecodableNotice]
}

// MARK: - PolymorphicDecodable

@PolymorphicCodableStrategyProviding(
  identifierCodingKey: "type",
  matchingTypes: [
    DummyDecodableCallout.self,
    DummyActionableDecodableCallout.self,
    DummyDismissibleDecodableCallout.self,
  ],
  fallbackType: DummyUndefinedDecodableCallout.self
)
protocol DummyDecodableNotice: Decodable {
  var type: DummyDecodableNoticeType { get }
  var title: String? { get }
  var description: String { get }
}

enum DummyDecodableNoticeType: String, Decodable, DefaultCodableStrategy {

  static let defaultValue = DummyDecodableNoticeType.undefinedCallout

  case callout
  case actionableCallout = "actionable-callout"
  case dismissibleCallout = "dismissible-callout"
  case undefinedCallout = "undefined-callout"
}

@PolymorphicDecodable(identifier: "callout", codingKeyStyle: .snakeCase)
struct DummyDecodableCallout: DummyDecodableNotice {
  let type: DummyDecodableNoticeType
  let title: String?
  let description: String
  let icon: String?
}

@PolymorphicDecodable(identifier: "actionable-callout", codingKeyStyle: .snakeCase)
struct DummyActionableDecodableCallout: DummyDecodableNotice {
  let type: DummyDecodableNoticeType
  let title: String?
  let description: String
  let action: URL
}

@PolymorphicDecodable(identifier: "dismissible-callout", codingKeyStyle: .snakeCase)
struct DummyDismissibleDecodableCallout: DummyDecodableNotice {
  let type: DummyDecodableNoticeType
  let title: String?
  let description: String
  let key: String
}

@PolymorphicDecodable(identifier: "undefined-callout", codingKeyStyle: .snakeCase)
struct DummyUndefinedDecodableCallout: DummyDecodableNotice {
  @DefaultCodable
  var type = DummyDecodableNoticeType.undefinedCallout
  let title: String?
  let description: String
}
