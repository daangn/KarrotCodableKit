//
//  PolymorphicEnumCodableTests.swift
//
//
//  Created by Elon on 10/19/24.
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

import XCTest

import KarrotCodableKit

class PolymorphicEnumCodableTests: XCTestCase {

  func testPolymorphicEnumValue() throws {
    // given
    let json = #"""
    {
      "description" : "test",
      "icon" : "test_icon",
      "type" : "callout"
    }
    """#

    // when
    let result = try JSONDecoder().decode(CalloutBadge.self, from: Data(json.utf8))

    // then
    switch result {
    case .callout(let value):
      XCTAssertEqual(value.type, .callout)
    default:
      XCTFail("Invalid type")
    }

    // when
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    let data = try encoder.encode(result)

    // then
    let expectResult = #"""
    {
      "description" : "test",
      "icon" : "test_icon",
      "type" : "callout"
    }
    """#
    let jsonString = String(decoding: data, as: UTF8.self)
    XCTAssertEqual(jsonString, expectResult)
  }

  func testPolymorphicEnumArrayValue() throws {
    // given
    let json = #"""
    [
      {
        "description" : "test",
        "icon" : "test_icon",
        "type" : "callout"
      },
      {
        "description" : "test",
        "key" : "hi",
        "type" : "dismissible-callout"
      },
      {
        "description" : "test",
        "type" : "unknown-callout-type"
      }
    ]
    """#

    // when
    let result = try JSONDecoder().decode([CalloutBadge].self, from: Data(json.utf8))

    // then
    if case .callout(let value) = result.first {
      XCTAssertEqual(value.type, .callout)
    }
    if case .dismissibleCallout(let value) = result.last {
      XCTAssertEqual(value.type, .dismissibleCallout)
      XCTAssertEqual(value.key, "hi")
    }
    if case .undefinedCallout(let value) = result.last {
      XCTAssertEqual(value.type, .undefinedCallout)
      XCTAssertEqual(value.description, "test")
    }

    // when
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    let data = try encoder.encode(result)

    // then
    let expectResult = #"""
    [
      {
        "description" : "test",
        "icon" : "test_icon",
        "type" : "callout"
      },
      {
        "description" : "test",
        "key" : "hi",
        "type" : "dismissible-callout"
      },
      {
        "description" : "test",
        "type" : "undefined-callout"
      }
    ]
    """#
    let jsonString = String(decoding: data, as: UTF8.self)
    XCTAssertEqual(jsonString, expectResult)
  }
}
