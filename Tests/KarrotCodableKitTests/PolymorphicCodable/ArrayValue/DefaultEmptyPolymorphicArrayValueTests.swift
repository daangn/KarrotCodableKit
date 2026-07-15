//
//  DefaultEmptyPolymorphicArrayValueTests.swift
//
//
//  Created by Elon on 10/17/24.
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

import Foundation
import Testing

import KarrotCodableKit

struct DefaultEmptyPolymorphicArrayValueTests {

  @Test
  func `encoding default empty polymorphic array value`() throws {
    // given
    let response = OptionalArrayDummyResponse(
      notices1: [
        DummyCallout(
          type: .callout,
          title: nil,
          description: "test",
          icon: "test_icon",
        )
      ],
      notices2: [],
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
    #expect(jsonString == expectResult)
  }

  @Test
  func `decoding default empty polymorphic array value`() throws {
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
    let result = try JSONDecoder().decode(OptionalArrayDummyResponse.self, from: Data(jsonData.utf8))

    // then
    #expect(result.notices1.count == 1)
    #expect(result.notices1.first?.type == .callout)
    #expect(result.notices2.isEmpty)
  }

  @Test
  func `decoding encoding default empty polymorphic array value`() throws {
    // given
    let json = #"""
      {
        "notices1" : null,
        "notices2" : null
      }
      """#

    // when
    let result = try JSONDecoder().decode(OptionalArrayDummyResponse.self, from: Data(json.utf8))

    // then
    #expect(result.notices1.isEmpty)
    #expect(result.notices2.isEmpty)

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
    #expect(jsonString == expectResult)
  }
}

extension DefaultEmptyPolymorphicArrayValueTests {
  @Test
  func `decoding fail element in default empty polymorphic array value`() throws {
    // given
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
    let result = try JSONDecoder().decode(OptionalArrayDummyResponse.self, from: Data(jsonData.utf8))

    // then
    #expect(result.notices1.isEmpty)
  }
}

extension DefaultEmptyPolymorphicArrayValueTests {
  @Test
  func `decoding only value`() throws {
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
      OptionalAarrayDummyDecodableResponse.self,
      from: Data(jsonData.utf8),
    )

    // then
    #expect(result.notices1.isEmpty)
    #expect(result.notices2.first?.type == .callout)
    #expect(result.notices3.isEmpty)
  }
}
