//
//  PolymorphicMatchingTypesProvidingTests.swift
//  KarrotCodableKit
//
//  Created by Elon on 8/4/26.
//  Copyright © 2026 Danggeun Market Inc. All rights reserved.
//

import Foundation
import Testing

import KarrotCodableKit

struct PolymorphicMatchingTypesProvidingTests {

  @Test
  func `generated strategy exposes its matching types in declaration order`() {
    // given
    // DummyNotice declares DummyCallout, DummyActionableCallout and DummyDismissibleCallout.

    // when
    let identifiers = DummyNoticeCodableStrategy.matchingTypes.map { $0.polymorphicIdentifier }

    // then
    #expect(identifiers == ["callout", "actionable-callout", "dismissible-callout"])
  }

  @Test
  func `generated strategy exposes its fallback type`() throws {
    // given
    // DummyNotice declares DummyUndefinedCallout as its fallback.

    // when
    let fallbackType = try #require(DummyNoticeCodableStrategy.fallbackType)

    // then
    #expect(fallbackType.polymorphicIdentifier == "undefined-callout")
  }

  @Test
  func `strategy declared without a fallback type exposes nil`() {
    // given
    // ViewItem declares matching types only, with no fallbackType argument.

    // when
    let fallbackType = ViewItemCodableStrategy.fallbackType

    // then
    #expect(fallbackType == nil)
    #expect(ViewItemCodableStrategy.matchingTypes.isEmpty == false)
  }

  @Test
  func `exposed matching types describe what decoding actually resolves`() throws {
    // given
    let jsonData = #"""
      {
        "notice" : {
          "description" : "Your listing is under review",
          "key" : "listing-under-review",
          "title" : "Under review",
          "type" : "dismissible-callout"
        },
        "notices" : [
          {
            "description" : "A notice type this client does not know yet",
            "title" : "Sponsored",
            "type" : "sponsored-callout"
          }
        ]
      }
      """#

    let declaredIdentifiers = DummyNoticeCodableStrategy.matchingTypes.map { $0.polymorphicIdentifier }
    let fallbackIdentifier = try #require(DummyNoticeCodableStrategy.fallbackType).polymorphicIdentifier

    // when
    let response = try JSONDecoder().decode(DummyResponse.self, from: Data(jsonData.utf8))

    // then
    // A declared identifier resolves to the declared type.
    #expect(declaredIdentifiers.contains("dismissible-callout"))
    let notice = try #require(response.notice as? DummyDismissibleCallout)
    #expect(notice.key == "listing-under-review")

    // An identifier outside the exposed list resolves to the exposed fallback type.
    #expect(declaredIdentifiers.contains("sponsored-callout") == false)
    #expect(fallbackIdentifier == "undefined-callout")
    let unknownNotice = try #require(response.notices.first as? DummyUndefinedCallout)
    #expect(unknownNotice.description == "A notice type this client does not know yet")
  }

  @Test
  func `a generic helper can enumerate any conforming strategy`() {
    // given
    // A caller that only knows the protocol, mirroring an exhaustiveness check in a consumer.

    // when
    let noticeIdentifiers = polymorphicIdentifiers(declaredIn: DummyNoticeCodableStrategy.self)
    let viewItemIdentifiers = polymorphicIdentifiers(declaredIn: ViewItemCodableStrategy.self)

    // then
    #expect(noticeIdentifiers == ["callout", "actionable-callout", "dismissible-callout"])
    #expect(viewItemIdentifiers.contains("TITLE_VIEW_ITEM"))
  }

  @Test
  func `a hand-written strategy keeps decoding without adopting the new protocol`() throws {
    // given
    let jsonData = #"""
      {
        "notice" : {
          "description" : "Welcome to Karrot",
          "icon" : "waving_hand",
          "type" : "callout"
        }
      }
      """#

    // when
    let response = try JSONDecoder().decode(
      HandWrittenStrategyDummyResponse.self,
      from: Data(jsonData.utf8),
    )

    // then
    let notice = try #require(response.notice as? DummyCallout)
    #expect(notice.description == "Welcome to Karrot")
    #expect(notice.icon == "waving_hand")
  }
}

private func polymorphicIdentifiers<Strategy: PolymorphicMatchingTypesProviding>(
  declaredIn _: Strategy.Type
) -> [String] {
  Strategy.matchingTypes.map { $0.polymorphicIdentifier }
}
