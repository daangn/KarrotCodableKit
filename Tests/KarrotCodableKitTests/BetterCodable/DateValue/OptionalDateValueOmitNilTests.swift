//
//  OptionalDateValueOmitNilTests.swift
//  KarrotCodableKit
//
//  Created by Elon on 6/26/26.
//  Copyright © 2026 Danggeun Market Inc. All rights reserved.
//

import Foundation
import Testing

import KarrotCodableKit

struct OptionalDateValueOmitNilTests {
  private struct Fixture: Codable {
    @OptionalDateValue<ISO8601Strategy> var iso8601: Date?
  }

  @Test
  func encodingNilOmitsKey() throws {
    // given
    let fixture = Fixture(iso8601: nil)

    // when
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    let data = try encoder.encode(fixture)

    // then - nil value is omitted, matching Apple's default Codable behavior
    let jsonString = try #require(String(bytes: data, encoding: .utf8))
    #expect(jsonString == "{\n\n}")
  }

  @Test
  func encodingValuePreservesKey() throws {
    // given
    let fixture = Fixture(iso8601: Date(timeIntervalSince1970: 851042397))

    // when
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    let data = try encoder.encode(fixture)

    // then - a present value is still encoded under its key
    let expectResult = #"""
    {
      "iso8601" : "1996-12-20T00:39:57Z"
    }
    """#
    let jsonString = try #require(String(bytes: data, encoding: .utf8))
    #expect(jsonString == expectResult)
  }

  @Test
  func encodingDecodingNilRoundTrip() throws {
    // given
    let fixture = Fixture(iso8601: nil)

    // when
    let data = try JSONEncoder().encode(fixture)
    let decoded = try JSONDecoder().decode(Fixture.self, from: data)

    // then - nil is restored from the omitted key
    #expect(decoded.iso8601 == nil)
  }
}
