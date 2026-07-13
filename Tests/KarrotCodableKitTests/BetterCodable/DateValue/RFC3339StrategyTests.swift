//
//  RFC3339StrategyTests.swift
//  KarrotCodableKit
//
//  Created by Elon on 7/13/26.
//

import Foundation
import Testing

import KarrotCodableKit

struct RFC3339StrategyTests {

  @Test
  func encodesUTCDateWithStandardCompliantOffset() {
    // given
    let date = Date(timeIntervalSince1970: 1715082540) // 2024-05-07T11:49:00 UTC

    // when
    let result = RFC3339Strategy.encode(date)

    // then
    // RFC 3339 requires the UTC offset to be "Z" (or "+00:00"), not the colon-less "+0000".
    #expect(result == "2024-05-07T11:49:00Z")
  }

  @Test(arguments: [
    "2024-05-07T11:49:00Z",
    "2024-05-07T11:49:00+00:00",
    "2024-05-07T11:49:00+0000"
  ])
  func decodesAllUTCOffsetForms(input: String) throws {
    // when
    let date = try RFC3339Strategy.decode(input)

    // then
    // "ZZZZZ" still parses every offset form the old "Z" pattern accepted, including "+0000".
    #expect(date == Date(timeIntervalSince1970: 1715082540))
  }

  @Test(arguments: [
    "1996-12-19T16:39:57-08:00",
    "1996-12-19T16:39:57-0800"
  ])
  func decodesNonUTCOffsetsRegardlessOfColon(input: String) throws {
    // when
    let date = try RFC3339Strategy.decode(input)

    // then
    #expect(date == Date(timeIntervalSince1970: 851042397))
  }
}
