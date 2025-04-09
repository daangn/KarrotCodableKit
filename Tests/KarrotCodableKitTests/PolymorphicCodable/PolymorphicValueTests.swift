//
//  PolymorphicValueTests.swift
//
//
//  Created by Elon on 10/14/24.
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

import XCTest

import KarrotCodableKit

class PolymorphicValueTests: XCTestCase {

  func testEncodingPolymorphicValue() throws {
    // given
    let response = DummyResponse(
      notice: DummyCallout(type: .callout, title: nil, description: "test", icon: "test_icon"),
      notices: [
        DummyActionableCallout(
          type: .actionableCallout,
          title: nil,
          description: "test",
          action: URL(string: "https://daangn.com")!
        ),
        DummyDismissibleCallout(
          type: .dismissibleCallout,
          title: "test_title",
          description: "test",
          key: "key"
        )
      ]
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
    XCTAssertEqual(jsonString, expectResult)
  }

  func testDecodingPolymorphicValue() throws {
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
    XCTAssertEqual(result.notice.type, .callout)
    XCTAssertEqual(result.notices.count, 3)
    XCTAssertEqual(result.notices[0].type, .actionableCallout)
    XCTAssertEqual(result.notices[1].type, .dismissibleCallout)
    XCTAssertEqual(result.notices[2].type, .undefindCallout)
  }

  func testDecodingUndefinedPolymorphicValue() throws {
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
    XCTAssertEqual(result.notice.type, .undefindCallout)
    XCTAssertEqual(result.notices.count, 1)
    XCTAssertEqual(result.notices[0].type, .undefindCallout)
  }
}

extension PolymorphicValueTests {
  func testDecodingOnlyValue() throws {
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
    XCTAssertEqual(result.notice.type, .callout)
    XCTAssertEqual(result.notices.count, 3)
    XCTAssertEqual(result.notices[0].type, .actionableCallout)
    XCTAssertEqual(result.notices[1].type, .dismissibleCallout)
    XCTAssertEqual(result.notices[2].type, .undefindCallout)
  }
}

