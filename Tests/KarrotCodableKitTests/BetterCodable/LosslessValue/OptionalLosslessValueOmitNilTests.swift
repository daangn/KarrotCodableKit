//
//  OptionalLosslessValueOmitNilTests.swift
//  KarrotCodableKit
//
//  Created by Elon on 6/26/26.
//  Copyright © 2026 Danggeun Market Inc. All rights reserved.
//

import Foundation
import Testing

import KarrotCodableKit

struct OptionalLosslessValueOmitNilTests {
  private struct Fixture: Codable {
    @OptionalLosslessValue var optionalString: String?
    @OptionalLosslessValue var optionalInt: Int?
  }

  @Test
  func `encoding nil omits key`() throws {
    // given
    let fixture = Fixture(optionalString: nil, optionalInt: nil)

    // when
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    let data = try encoder.encode(fixture)

    // then - all nil values are omitted, producing an empty object
    let jsonString = try #require(String(bytes: data, encoding: .utf8))
    #expect(jsonString == "{\n\n}")
  }

  @Test
  func `encoding partial nil omits only nil keys`() throws {
    // given
    let fixture = Fixture(optionalString: "hello", optionalInt: nil)

    // when
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    let data = try encoder.encode(fixture)

    // then - only optionalInt (nil) is omitted
    let expectResult = #"""
      {
        "optionalString" : "hello"
      }
      """#
    let jsonString = try #require(String(bytes: data, encoding: .utf8))
    #expect(jsonString == expectResult)
  }

  @Test
  func `encoding decoding nil round trip`() throws {
    // given
    let fixture = Fixture(optionalString: nil, optionalInt: nil)

    // when
    let data = try JSONEncoder().encode(fixture)
    let decoded = try JSONDecoder().decode(Fixture.self, from: data)

    // then - nil values are restored from the omitted keys
    #expect(decoded.optionalString == nil)
    #expect(decoded.optionalInt == nil)
  }
}
