//
//  PolymorphicValueTests.swift
//
//
//  Created by Elon on 10/14/24.
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

import Foundation
import Testing

import KarrotCodableKit

struct PolymorphicValueTests {

  @Test
  func `encoding polymorphic value`() throws {
    // given
    let response = DummyResponse(
      notice: DummyCallout(type: .callout, title: nil, description: "test", icon: "test_icon"),
      notices: [
        DummyActionableCallout(
          type: .actionableCallout,
          title: nil,
          description: "test",
          action: try #require(URL(string: "https://daangn.com")),
        ),
        DummyDismissibleCallout(
          type: .dismissibleCallout,
          title: "test_title",
          description: "test",
          key: "key",
        ),
      ],
    )

    let expectResult = #"""
      {
        "notice" : {
          "description" : "test",
          "icon" : "test_icon",
          "type" : "callout"
        },
        "notices" : [
          {
            "action" : "https:\/\/daangn.com",
            "description" : "test",
            "type" : "actionable-callout"
          },
          {
            "description" : "test",
            "key" : "key",
            "title" : "test_title",
            "type" : "dismissible-callout"
          }
        ]
      }
      """#

    // when
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    let data = try encoder.encode(response)

    // then
    let jsonString = String(decoding: data, as: UTF8.self)
    #expect(jsonString == expectResult)
  }

  @Test
  func `decoding polymorphic value`() throws {
    // given
    let jsonData = #"""
      {
        "notice" : {
          "description" : "test",
          "icon" : "test_icon",
          "type" : "callout"
        },
        "notices" : [
          {
            "action" : "https:\/\/daangn.com",
            "description" : "test",
            "type" : "actionable-callout"
          },
          {
            "description" : "test",
            "key" : "key",
            "title" : "test_title",
            "type" : "dismissible-callout"
          },
          {
            "description" : "test",
            "title" : "test_title",
            "type" : "unknown-callout-type"
          }
        ]
      }
      """#

    // when
    let result = try JSONDecoder().decode(DummyResponse.self, from: Data(jsonData.utf8))

    // then
    #expect(result.notice.type == .callout)
    #expect(result.notices.count == 3)
    #expect(result.notices[0].type == .actionableCallout)
    #expect(result.notices[1].type == .dismissibleCallout)
    #expect(result.notices[2].type == .undefinedCallout)
  }

  @Test
  func `decoding undefined polymorphic value`() throws {
    // given
    let jsonData = #"""
      {
        "notice" : {
          "description" : "test1",
          "icon" : "test_icon",
          "type" : "unknown-callout-type"
        },
        "notices": [
          {
            "description" : "test2",
            "type" : "unknown-type"
          }
        ]
      }
      """#

    // when
    let result = try JSONDecoder().decode(DummyResponse.self, from: Data(jsonData.utf8))

    // then
    #expect(result.notice.type == .undefinedCallout)
    #expect(result.notices.count == 1)
    #expect(result.notices[0].type == .undefinedCallout)
  }
}

extension PolymorphicValueTests {
  @Test
  func `decoding only value`() throws {
    // given
    let jsonData = #"""
      {
        "notice" : {
          "description" : "test",
          "icon" : "test_icon",
          "type" : "callout"
        },
        "notices" : [
          {
            "action" : "https:\/\/daangn.com",
            "description" : "test",
            "type" : "actionable-callout"
          },
          {
            "description" : "test",
            "key" : "key",
            "title" : "test_title",
            "type" : "dismissible-callout"
          },
          {
            "description" : "test",
            "title" : "test_title",
            "type" : "unknown-callout-type"
          }
        ]
      }
      """#

    // when
    let result = try JSONDecoder().decode(DummyDecodableResponse.self, from: Data(jsonData.utf8))

    // then
    #expect(result.notice.type == .callout)
    #expect(result.notices.count == 3)
    #expect(result.notices[0].type == .actionableCallout)
    #expect(result.notices[1].type == .dismissibleCallout)
    #expect(result.notices[2].type == .undefinedCallout)
  }
}
