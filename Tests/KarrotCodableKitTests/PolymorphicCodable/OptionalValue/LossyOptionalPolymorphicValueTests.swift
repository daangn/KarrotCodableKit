//
//  LossyOptionalPolymorphicValueTests.swift
//
//
//  Created by Elon on 10/17/24.
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

import Foundation
import Testing

import KarrotCodableKit

struct LossyOptionalPolymorphicValueTests {

  @Test
  func `encoding lossy optional polymorphic value`() throws {
    // given
    let response = LossyOptionalDummyResponse(
      notice1: DummyCallout(
        type: .callout,
        title: nil,
        description: "test",
        icon: "test_icon",
      )
    )

    let expectResult = #"""
      {
        "notice1" : {
          "description" : "test",
          "icon" : "test_icon",
          "type" : "callout"
        }
      }
      """#

    // when
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    let data = try encoder.encode(response)

    // then - notice2 (nil) is omitted, matching Apple's default Codable behavior
    let jsonString = try #require(String(bytes: data, encoding: .utf8))
    #expect(jsonString == expectResult)
  }

  @Test
  func `decoding lossy optional polymorphic value`() throws {
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
    let result = try JSONDecoder().decode(LossyOptionalDummyResponse.self, from: Data(jsonData.utf8))

    // then
    #expect(result.notice1 == nil)
    #expect(result.notice2?.type == .callout)
  }

  @Test
  func `decoding encoding lossy optional polymorphic value`() throws {
    // given
    let json = #"""
      {
        "notice1" : null,
        "notice2" : null
      }
      """#

    // when
    let result = try JSONDecoder().decode(LossyOptionalDummyResponse.self, from: Data(json.utf8))

    // then
    #expect(result.notice1 == nil)
    #expect(result.notice2 == nil)

    // when
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    let data = try encoder.encode(result)

    // then - all nil values are omitted, producing an empty object
    let expectResult = "{\n\n}"
    let jsonString = try #require(String(bytes: data, encoding: .utf8))
    #expect(jsonString == expectResult)
  }
}

extension LossyOptionalPolymorphicValueTests {
  @Test
  func `decoding only value`() throws {
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
      from: Data(jsonData.utf8),
    )

    // then
    #expect(result.notice1 == nil)
    #expect(result.notice2?.type == .callout)
    #expect(result.notice3 == nil)
  }
}
