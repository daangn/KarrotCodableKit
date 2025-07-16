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
}
