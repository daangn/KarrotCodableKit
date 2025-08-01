//
//  PolymorphicEnumDecodableTests.swift
//
//
//  Created by Elon on 10/21/24.
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

import XCTest

import KarrotCodableKit

class PolymorphicEnumDecodableTests: XCTestCase {

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
    let result = try JSONDecoder().decode(DecodableCalloutBadge.self, from: Data(json.utf8))

    // then
    switch result {
    case .callout(let value):
      XCTAssertEqual(value.type, .callout)
    default:
      XCTFail("Invalid type")
    }
  }

  func testPolymorphicEnumDecodableArrayValue() throws {
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
    let result = try JSONDecoder().decode([DecodableCalloutBadge].self, from: Data(json.utf8))

    // then
    if case .callout(let value) = result[0] {
      XCTAssertEqual(value.type, .callout)
    }
    if case .dismissibleCallout(let value) = result[1] {
      XCTAssertEqual(value.type, .dismissibleCallout)
      XCTAssertEqual(value.key, "hi")
    }
    if case .undefinedCallout(let value) = result[2] {
      XCTAssertEqual(value.type, .undefinedCallout)
      XCTAssertEqual(value.description, "test")
    }
  }
}
