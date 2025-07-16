//
//  PolymorphicLossyArrayValueTests.swift
//
//
//  Created by Elon on 10/18/24.
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

import XCTest

import KarrotCodableKit

class PolymorphicLossyArrayValueTests: XCTestCase {

  func testEncodingDefaultEmptyPolymorphicArrayValue() throws {
    // given
    let response = OptionalLossyArrayDummyResponse(
      notices1: [
        DummyCallout(
          type: .callout,
          title: nil,
          description: "test",
          icon: "test_icon"
        ),
      ],
      notices2: []
    )

    let expectResult = #"""
    {
      "notices1" : [
        {
          "description" : "test",
          "icon" : "test_icon",
          "type" : "callout"
        }
      ],
      "notices2" : [

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

  func testDecodingDefaultEmptyPolymorphicArrayValue() throws {
    // given
    let jsonData = #"""
    {
      "notices1" : [
        {
          "description" : "test",
          "icon" : "test_icon",
          "type" : "callout"
        }
      ]
    }
    """#

    // when
    let result = try JSONDecoder().decode(OptionalLossyArrayDummyResponse.self, from: Data(jsonData.utf8))

    // then
    XCTAssertEqual(result.notices1.count, 1)
    XCTAssertEqual(result.notices1.first?.type, .callout)
    XCTAssertTrue(result.notices2.isEmpty)
  }

  func testDecodingEncodingDefaultEmptyPolymorphicArrayValue() throws {
    // given
    let json = #"""
    {
      "notices1" : null,
      "notices2" : null
    }
    """#

    // when
    let result = try JSONDecoder().decode(OptionalLossyArrayDummyResponse.self, from: Data(json.utf8))

    // then
    XCTAssertTrue(result.notices1.isEmpty)
    XCTAssertTrue(result.notices2.isEmpty)

    // when
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    let data = try encoder.encode(result)

    // then
    let expectResult = #"""
    {
      "notices1" : [

      ],
      "notices2" : [

      ]
    }
    """#
    let jsonString = String(decoding: data, as: UTF8.self)
    XCTAssertEqual(jsonString, expectResult)
  }
}

extension PolymorphicLossyArrayValueTests {
  func testDecodingFailElementInDefaultEmptyPolymorphicArrayValue() throws {
    // given: An array where one element (notice) is missing the required 'description' parameter.
    let jsonData = #"""
    {
      "notices1" : [
        {
          "icon" : "test_icon",
          "type" : "callout"
        },
        {
          "description" : "test",
          "icon" : "test_icon",
          "type" : "callout"
        }
      ]
    }
    """#

    // when: During decoding.
    let result = try JSONDecoder().decode(OptionalLossyArrayDummyResponse.self, from: Data(jsonData.utf8))

    // then: Returns an array excluding the element that failed decoding.
    XCTAssertEqual(result.notices1.count, 1)
    XCTAssertEqual(result.notices1.first?.description, "test")
  }
}

extension PolymorphicLossyArrayValueTests {
  func testDecodingOnlyValue() throws {
    // given
    let jsonData = #"""
    {
      "notices2" : [
        {
          "description" : "test",
          "icon" : "test_icon",
          "type" : "callout"
        }
      ],
      "notice3" : null
    }
    """#

    // when
    let result = try JSONDecoder().decode(
      OptionalLossyAarrayDummyDecodableResponse.self,
      from: Data(jsonData.utf8)
    )

    // thens
    XCTAssertTrue(result.notices1.isEmpty)
    XCTAssertEqual(result.notices2.first?.type, .callout)
    XCTAssertTrue(result.notices3.isEmpty)
  }
}
