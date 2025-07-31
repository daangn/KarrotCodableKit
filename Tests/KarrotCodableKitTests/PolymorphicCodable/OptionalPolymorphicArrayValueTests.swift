//
//  OptionalPolymorphicArrayValueTests.swift
//  KarrotCodableKit
//
//  Created by elon on 7/28/25.
//

import Foundation
import Testing

import KarrotCodableKit

struct OptionalPolymorphicArrayValueTests {

  @Test
  func decodingOptionalPolymorphicArrayValue() throws {
    // given
    let jsonData = #"""
    {
      "notices1" : [
        {
          "description" : "test1",
          "icon" : "test_icon1",
          "type" : "callout"
        },
        {
          "description" : "test2",
          "action" : "https://example.com",
          "type" : "actionable-callout"
        }
      ],
      "notices2" : null
    }
    """#

    // when
    let result = try JSONDecoder().decode(OptionalPolymorphicArrayDummyResponse.self, from: Data(jsonData.utf8))

    // then
    let notices1 = try #require(result.notices1)
    #expect(notices1.count == 2)

    let firstNotice = try #require(notices1[0] as? DummyCallout)
    #expect(firstNotice.description == "test1")
    #expect(firstNotice.icon == "test_icon1")
    #expect(firstNotice.type == .callout)

    let secondNotice = try #require(notices1[1] as? DummyActionableCallout)
    #expect(secondNotice.description == "test2")
    #expect(secondNotice.action == URL(string: "https://example.com"))
    #expect(secondNotice.type == .actionableCallout)

    #expect(result.notices2 == nil)
  }

  @Test
  func encodingOptionalPolymorphicArrayValue() throws {
    // given
    let response = OptionalPolymorphicArrayDummyResponse(
      notices1: [
        DummyCallout(
          type: .callout,
          title: nil,
          description: "test",
          icon: "test_icon"
        ),
      ],
      notices2: nil
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
      "notices2" : null
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
  func decodingOptionalPolymorphicArrayValueWithEmptyArray() throws {
    // given
    let jsonData = #"""
    {
      "notices1" : [],
      "notices2" : null
    }
    """#

    // when
    let result = try JSONDecoder().decode(OptionalPolymorphicArrayDummyResponse.self, from: Data(jsonData.utf8))

    // then
    let notices1 = try #require(result.notices1)
    #expect(notices1.isEmpty)
    #expect(result.notices2 == nil)
  }

  @Test
  func decodingOptionalPolymorphicArrayValueWithMissingKey() throws {
    // given
    let jsonData = #"""
    {
      "notices2" : [
        {
          "description" : "test",
          "icon" : "test_icon",
          "type" : "callout"
        }
      ]
    }
    """#

    // when
    let result = try JSONDecoder().decode(OptionalPolymorphicArrayDummyResponse.self, from: Data(jsonData.utf8))

    // then
    #expect(result.notices1 == nil)

    let notices2 = try #require(result.notices2)
    #expect(notices2.count == 1)
    let notice = try #require(notices2[0] as? DummyCallout)
    #expect(notice.description == "test")
  }

  @Test
  func decodingOptionalPolymorphicArrayValueWithInvalidElement() throws {
    // given - Array with one invalid element (missing required 'description' property)
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

    // when & then - Should throw error, not return nil or empty array
    #expect(throws: DecodingError.self) {
      _ = try JSONDecoder().decode(OptionalPolymorphicArrayDummyResponse.self, from: Data(jsonData.utf8))
    }
  }

  @Test
  func decodingOptionalPolymorphicArrayValueWhenNotArray() throws {
    // given - Value is not an array
    let jsonData = #"""
    {
      "notices1" : {
        "description" : "test",
        "icon" : "test_icon",  
        "type" : "callout"
      }
    }
    """#

    // when & then - Should throw error
    #expect(throws: DecodingError.self) {
      _ = try JSONDecoder().decode(OptionalPolymorphicArrayDummyResponse.self, from: Data(jsonData.utf8))
    }
  }

  @Test
  func encodingDecodingNilValues() throws {
    // given
    let response = OptionalPolymorphicArrayDummyResponse(
      notices1: nil,
      notices2: nil
    )

    // when - encode
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    let data = try encoder.encode(response)

    // then - verify encoded JSON
    let expectResult = #"""
    {
      "notices1" : null,
      "notices2" : null
    }
    """#
    let jsonString = String(decoding: data, as: UTF8.self)
    #expect(jsonString == expectResult)

    // when - decode back
    let decodedResponse = try JSONDecoder().decode(OptionalPolymorphicArrayDummyResponse.self, from: data)

    // then - verify decoded values
    #expect(decodedResponse.notices1 == nil)
    #expect(decodedResponse.notices2 == nil)
  }
}
