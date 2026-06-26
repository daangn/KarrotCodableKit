//
//  OptionalPolymorphicValueTests.swift
//  KarrotCodableKit
//
//  Created by elon on 7/16/25.
//

import Foundation
import Testing

import KarrotCodableKit

struct OptionalPolymorphicValueTests {

  func testDecodingOptionalPolymorphicValue() throws {
    // given
    let jsonData = #"""
    {
      "notice2" : {
        "description" : "test",
        "icon" : "test_icon",
        "type" : "callout"
      },
      "notice3": null
    }
    """#

    // when
    let result = try JSONDecoder().decode(OptionalDummyResponse.self, from: Data(jsonData.utf8))

    // then
    #expect(result.notice1 == nil)
    let notice2 = try #require(result.notice2 as? DummyCallout)
    #expect(notice2.description == "test")
    #expect(notice2.icon == "test_icon")
    #expect(notice2.type == .callout)
    #expect(result.notice3 == nil)
  }

  @Test
  func decodingOptionalPolymorphicValueWhenEmptyObject() throws {
    // given
    let jsonData = #"""
    {
      "notice1" : {}
    }
    """#

    // when & then
    #expect(throws: DecodingError.self) {
      _ = try JSONDecoder().decode(OptionalDummyResponse.self, from: Data(jsonData.utf8))
    }
  }

  @Test
  func decodingOptionalPolymorphicValueWhenMissingRequiredProperty() throws {
    // given
    let jsonData = #"""
    {
      "notice1" : {
        "type" : "callout"
      }
    }
    """#

    // when & then
    #expect(throws: DecodingError.self) {
      _ = try JSONDecoder().decode(OptionalDummyResponse.self, from: Data(jsonData.utf8))
    }
  }

  @Test
  func encodingOptionalPolymorphicValueOmitsNilFields() throws {
    // given
    let response = OptionalDummyResponse(
      notice1: DummyCallout(
        type: .callout,
        title: nil,
        description: "test",
        icon: "test_icon"
      ),
      notice2: nil,
      notice3: nil
    )

    // when
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    let data = try encoder.encode(response)

    // then - nil fields (notice2, notice3) are omitted, matching Apple's default Codable behavior
    let expectResult = #"""
    {
      "notice1" : {
        "description" : "test",
        "icon" : "test_icon",
        "type" : "callout"
      }
    }
    """#
    let jsonString = try #require(String(bytes: data, encoding: .utf8))
    #expect(jsonString == expectResult)
  }

  @Test
  func encodingDecodingOptionalPolymorphicValueRoundTrip() throws {
    // given
    let response = OptionalDummyResponse(notice1: nil, notice2: nil, notice3: nil)

    // when - encode (all nil -> empty object, no explicit null)
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    let data = try encoder.encode(response)

    // then - empty object
    let jsonString = try #require(String(bytes: data, encoding: .utf8))
    #expect(jsonString == "{\n\n}")

    // when - decode back
    let decoded = try JSONDecoder().decode(OptionalDummyResponse.self, from: data)

    // then - nil values are restored (round-trip)
    #expect(decoded.notice1 == nil)
    #expect(decoded.notice2 == nil)
    #expect(decoded.notice3 == nil)
  }
}
