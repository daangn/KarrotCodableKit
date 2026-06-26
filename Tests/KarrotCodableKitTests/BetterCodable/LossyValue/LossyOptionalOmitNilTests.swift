//
//  LossyOptionalOmitNilTests.swift
//  KarrotCodableKit
//
//  Created by Elon on 6/26/26.
//  Copyright © 2026 Danggeun Market Inc. All rights reserved.
//

import Foundation
import Testing

import KarrotCodableKit

struct LossyOptionalOmitNilTests {
  private struct Fixture: Codable {
    @LossyOptional var url: URL?
    @LossyOptional var name: String?
  }

  @Test
  func encodingNilOmitsKey() throws {
    // given
    let fixture = Fixture(url: nil, name: nil)

    // when
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    let data = try encoder.encode(fixture)

    // then - all nil values are omitted, producing an empty object
    let json = try #require(String(bytes: data, encoding: .utf8))
    #expect(json == "{\n\n}")
  }

  @Test
  func encodingPartialNilOmitsOnlyNilKeys() throws {
    // given
    let fixture = Fixture(url: nil, name: "hello")

    // when
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    let data = try encoder.encode(fixture)

    // then - only url (nil) is omitted
    let expectResult = #"""
    {
      "name" : "hello"
    }
    """#
    let json = try #require(String(bytes: data, encoding: .utf8))
    #expect(json == expectResult)
  }

  @Test
  func encodingDecodingNilRoundTrip() throws {
    // given
    let fixture = Fixture(url: nil, name: nil)

    // when
    let data = try JSONEncoder().encode(fixture)
    let decoded = try JSONDecoder().decode(Fixture.self, from: data)

    // then - nil values are restored from the omitted keys
    #expect(decoded.url == nil)
    #expect(decoded.name == nil)
  }
}
