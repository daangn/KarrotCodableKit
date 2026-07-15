//
//  RFC3339StrategyTests.swift
//  KarrotCodableKit
//
//  Created by Elon on 7/13/26.
//

import Foundation
import Testing

import KarrotCodableKit

@Suite("RFC3339Strategy")
struct RFC3339StrategyTests {

  private struct Fixture: Codable {
    @DateValue<RFC3339Strategy> var date: Date
  }
}

// MARK: - Encoding a Date

extension RFC3339StrategyTests {

  @Test
  func `encodes UTC date with Z offset instead of RFC 822 offset`() {
    // given
    let date = Date(timeIntervalSince1970: 1715082540) // 2024-05-07T11:49:00 UTC

    // when
    let result = RFC3339Strategy.encode(date)

    // then
    // RFC 3339 allows only "Z" or "+00:00" for UTC, never the colon-less "+0000".
    #expect(result == "2024-05-07T11:49:00Z")
  }

  @Test
  func `serializes UTC date with Z offset via JSON encoder`() throws {
    // given
    let date = Date(timeIntervalSince1970: 1715082540) // 2024-05-07T11:49:00 UTC
    let fixture = Fixture(date: date)

    // when
    let data = try JSONEncoder().encode(fixture)
    let json = try #require(String(bytes: data, encoding: .utf8))

    // then
    #expect(json.contains("\"2024-05-07T11:49:00Z\""))
    #expect(!json.contains("+0000"))
  }
}

// MARK: - Decoding an RFC 3339 string

extension RFC3339StrategyTests {

  @Test(arguments: [
    "2024-05-07T11:49:00Z",
    "2024-05-07T11:49:00+00:00",
    "2024-05-07T11:49:00+0000",
  ])
  func `decodes every UTC offset form to same instant`(input: String) throws {
    // when
    let date = try RFC3339Strategy.decode(input)

    // then
    // "ZZZZZ" still parses every offset form the old "Z" pattern accepted.
    #expect(date == Date(timeIntervalSince1970: 1715082540))
  }

  @Test(arguments: [
    "1996-12-19T16:39:57-08:00",
    "1996-12-19T16:39:57-0800",
  ])
  func `decodes non UTC offsets with or without colon`(input: String) throws {
    // when
    let date = try RFC3339Strategy.decode(input)

    // then
    #expect(date == Date(timeIntervalSince1970: 851042397))
  }
}

// MARK: - Decoding a malformed string

extension RFC3339StrategyTests {

  @Test
  func `throws data corrupted error for malformed string`() {
    // when / then
    #expect {
      try RFC3339Strategy.decode("not-a-valid-date")
    } throws: { error in
      guard case DecodingError.dataCorrupted = error else { return false }
      return true
    }
  }
}
