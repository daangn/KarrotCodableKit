//
//  PolymorphicValueDummy.swift
//  KarrotCodableKit
//
//  Created by Elon on 6/10/25.
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

import Foundation

import KarrotCodableKit

// MARK: - PolymorphicEnumCodable

@PolymorphicEnumCodable(fallbackCaseName: "undefinedCallout")
enum CalloutBadge {
  case callout(_ a: DummyCallout)
  case actionableCallout(DummyActionableCallout)
  case dismissibleCallout(value: DummyDismissibleCallout)
  case undefinedCallout(DummyUndefinedCallout)
}

@CustomCodable(codingKeyStyle: .snakeCase)
struct DummyResponse {

  @DummyNotice.Polymorphic
  var notice: any DummyNotice

  @DummyNotice.PolymorphicArray
  var notices: [any DummyNotice]
}

@CustomCodable(codingKeyStyle: .snakeCase)
struct LossyOptionalDummyResponse {

  @DummyNotice.LossyOptionalPolymorphic
  var notice1: (any DummyNotice)?

  @DummyNotice.LossyOptionalPolymorphic
  var notice2: (any DummyNotice)?
}

@CustomCodable(codingKeyStyle: .snakeCase)
struct OptionalDummyResponse {

  @DummyNotice.OptionalPolymorphic
  var notice1: (any DummyNotice)?

  @DummyNotice.OptionalPolymorphic
  var notice2: (any DummyNotice)?

  @DummyNotice.OptionalPolymorphic
  var notice3: (any DummyNotice)?
}

@CustomCodable(codingKeyStyle: .snakeCase)
struct OptionalArrayDummyResponse {

  @DummyNotice.DefaultEmptyPolymorphicArray
  var notices1: [any DummyNotice]

  @DummyNotice.DefaultEmptyPolymorphicArray
  var notices2: [any DummyNotice]
}

@CustomCodable(codingKeyStyle: .snakeCase)
struct OptionalLossyArrayDummyResponse {

  @DummyNotice.PolymorphicLossyArray
  var notices1: [any DummyNotice]

  @DummyNotice.PolymorphicLossyArray
  var notices2: [any DummyNotice]
}

// MARK: - PolymorphicCodable

@PolymorphicCodableStrategyProviding(
  identifierCodingKey: "type",
  matchingTypes: [
    DummyCallout.self,
    DummyActionableCallout.self,
    DummyDismissibleCallout.self,
  ],
  fallbackType: DummyUndefinedCallout.self
)
public protocol DummyNotice: Codable, Equatable {
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
