//
//  DefaultNilPolymorphicValueTests.swift
//
//
//  Created by Elon on 10/17/24.
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

import XCTest

import KarrotCodableKit

class DefaultNilPolymorphicValueTests: XCTestCase {

  func testEncodingDefaultNilPolymorphicValue() throws {
    // given
    let response = OptionalDummyResponse(
      notice1: DummyCallout(
        type: .callout,
        title: nil,
        description: "test",
        icon: "test_icon"
      )
    )

    let expectResult = #"""
    {
      "notice1" : {
        "description" : "test",
        "icon" : "test_icon",
        "type" : "callout"
      },
      "notice2" : null
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

  func testDecodingDefaultNilPolymorphicValue() throws {
    // given
    let jsonData = #"""
    {
      "notice2" : {
        "description" : "test",
        "icon" : "test_icon",
        "type" : "callout"
      }
    }
    """#

    // when
    let result = try JSONDecoder().decode(OptionalDummyResponse.self, from: Data(jsonData.utf8))

    // then
    XCTAssertNil(result.notice1)
    XCTAssertEqual(result.notice2?.type, .callout)
  }

  func testDecodingEncodingDefaultNilPolymorphicValue() throws {
    // given
    let json = #"""
    {
      "notice1" : null,
      "notice2" : null
    }
    """#

    // when
    let result = try JSONDecoder().decode(OptionalDummyResponse.self, from: Data(json.utf8))

    // then
    XCTAssertNil(result.notice1)
    XCTAssertNil(result.notice2)

    // when
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    let data = try encoder.encode(result)

    // then
    let expectResult = #"""
    {
      "notice1" : null,
      "notice2" : null
    }
    """#
    let jsonString = String(decoding: data, as: UTF8.self)
    XCTAssertEqual(jsonString, expectResult)
  }
}

extension DefaultNilPolymorphicValueTests {
  func testDecodingOnlyValue() throws {
    // given
    let jsonData = #"""
    {
      "notice2" : {
        "description" : "test",
        "icon" : "test_icon",
        "type" : "callout"
      },
      "notice3" : null
    }
    """#

    // when
    let result = try JSONDecoder().decode(
      OptionalDummyDecodableResponse.self,
      from: Data(jsonData.utf8)
    )

    // thens
    XCTAssertNil(result.notice1)
    XCTAssertEqual(result.notice2?.type, .callout)
    XCTAssertNil(result.notice3)
  }
}

