//
//  OptionalPolymorphicLossyArrayValueTests.swift
//  KarrotCodableKit
//
//  Created by KYHyeon on 4/6/26.
//  Copyright © 2026 Danggeun Market Inc. All rights reserved.
//

import Foundation
import Testing

import KarrotCodableKit

struct OptionalPolymorphicLossyArrayValueTests {

  @Test
  func decodingValidArray() throws {
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
    let result = try JSONDecoder().decode(
      OptionalPolymorphicLossyArrayDummyResponse.self,
      from: Data(jsonData.utf8)
    )

    // then
    let notices1 = try #require(result.notices1)
    #expect(notices1.count == 2)

    let firstNotice = try #require(notices1[0] as? DummyCallout)
    #expect(firstNotice.description == "test1")
    #expect(firstNotice.icon == "test_icon1")

    let secondNotice = try #require(notices1[1] as? DummyActionableCallout)
    #expect(secondNotice.description == "test2")

    #expect(result.notices2 == nil)
  }

  @Test
  func decodingNullValue() throws {
    // given
    let jsonData = #"""
    {
      "notices1" : null,
      "notices2" : null
    }
    """#

    // when
    let result = try JSONDecoder().decode(
      OptionalPolymorphicLossyArrayDummyResponse.self,
      from: Data(jsonData.utf8)
    )

    // then
    #expect(result.notices1 == nil)
    #expect(result.notices2 == nil)
  }

  @Test
  func decodingMissingKey() throws {
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
    let result = try JSONDecoder().decode(
      OptionalPolymorphicLossyArrayDummyResponse.self,
      from: Data(jsonData.utf8)
    )

    // then
    #expect(result.notices1 == nil)

    let notices2 = try #require(result.notices2)
    #expect(notices2.count == 1)
  }

  @Test
  func decodingEmptyArray() throws {
    // given
    let jsonData = #"""
    {
      "notices1" : [],
      "notices2" : null
    }
    """#

    // when
    let result = try JSONDecoder().decode(
      OptionalPolymorphicLossyArrayDummyResponse.self,
      from: Data(jsonData.utf8)
    )

    // then
    let notices1 = try #require(result.notices1)
    #expect(notices1.isEmpty)
    #expect(result.notices2 == nil)
  }

  @Test
  func decodingWithInvalidElementSkipsIt() throws {
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

    // when
    let result = try JSONDecoder().decode(
      OptionalPolymorphicLossyArrayDummyResponse.self,
      from: Data(jsonData.utf8)
    )

    // then - Invalid element is skipped, valid element is kept
    let notices1 = try #require(result.notices1)
    #expect(notices1.count == 1)

    let notice = try #require(notices1[0] as? DummyCallout)
    #expect(notice.description == "test")
  }

  @Test
  func decodingWithAllInvalidElementsReturnsEmptyArray() throws {
    // given - Array where all elements are invalid
    let jsonData = #"""
    {
      "notices1" : [
        {
          "icon" : "test_icon1",
          "type" : "callout"
        },
        {
          "type" : "actionable-callout"
        }
      ]
    }
    """#

    // when
    let result = try JSONDecoder().decode(
      OptionalPolymorphicLossyArrayDummyResponse.self,
      from: Data(jsonData.utf8)
    )

    // then - All elements are invalid, so the array is empty (not nil)
    let notices1 = try #require(result.notices1)
    #expect(notices1.isEmpty)
  }

  @Test
  func encoding() throws {
    // given
    let response = OptionalPolymorphicLossyArrayDummyResponse(
      notices1: [
        DummyCallout(
          type: .callout,
          title: nil,
          description: "test",
          icon: "test_icon"
        )
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
      ]
    }
    """#

    // when
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    let data = try encoder.encode(response)

    // then - notices2 (nil) is omitted, matching Apple's default Codable behavior
    let jsonString = try #require(String(bytes: data, encoding: .utf8))
    #expect(jsonString == expectResult)
  }

  @Test
  func encodingDecodingRoundTrip() throws {
    // given
    let response = OptionalPolymorphicLossyArrayDummyResponse(
      notices1: nil,
      notices2: nil
    )

    // when - encode
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    let data = try encoder.encode(response)

    // then - all nil values are omitted, producing an empty object
    let jsonString = try #require(String(bytes: data, encoding: .utf8))
    #expect(jsonString == "{\n\n}")

    // when - decode back
    let decodedResponse = try JSONDecoder().decode(
      OptionalPolymorphicLossyArrayDummyResponse.self,
      from: data
    )

    // then
    #expect(decodedResponse.notices1 == nil)
    #expect(decodedResponse.notices2 == nil)
  }

  @Test
  func encodingEmptyArrayIsKeptNotOmitted() throws {
    // given - an empty array ([]) is non-nil and must be kept, not omitted like nil
    let response = OptionalPolymorphicLossyArrayDummyResponse(notices1: [], notices2: nil)

    // when
    let encoder = JSONEncoder()
    encoder.outputFormatting = .sortedKeys
    let data = try encoder.encode(response)

    // then - notices1 stays as [], only notices2 (nil) is omitted
    let jsonString = try #require(String(bytes: data, encoding: .utf8))
    #expect(jsonString == #"{"notices1":[]}"#)

    // round-trip - [] preserved, nil restored
    let decoded = try JSONDecoder().decode(OptionalPolymorphicLossyArrayDummyResponse.self, from: data)
    #expect(decoded.notices1?.isEmpty == true)
    #expect(decoded.notices2 == nil)
  }
}
