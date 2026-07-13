//
//  RFC3339StrategyTests.swift
//  KarrotCodableKit
//
//  Created by Elon on 7/13/26.
//

import XCTest

import KarrotCodableKit

final class RFC3339StrategyTests: XCTestCase {
  func testEncodingUTCDateUsesStandardCompliantOffset() throws {
    // given
    let date = Date(timeIntervalSince1970: 1715082540) // 2024-05-07T11:49:00 UTC

    // when
    let result = RFC3339Strategy.encode(date)

    // then
    // RFC 3339 requires the UTC offset to be "Z" (or "+00:00"), not the colon-less "+0000".
    XCTAssertEqual(result, "2024-05-07T11:49:00Z")
  }

  func testDecodingAcceptsAllUTCOffsetForms() throws {
    // The "ZZZZZ" pattern must still decode every UTC offset form the previous "Z"
    // pattern accepted, including the colon-less RFC 822 style "+0000".
    let inputs = [
      "2024-05-07T11:49:00Z",
      "2024-05-07T11:49:00+00:00",
      "2024-05-07T11:49:00+0000"
    ]

    for input in inputs {
      // when
      let date = try RFC3339Strategy.decode(input)

      // then
      XCTAssertEqual(date, Date(timeIntervalSince1970: 1715082540), "failed to decode \(input)")
    }
  }

  func testDecodingAcceptsAllNonUTCOffsetForms() throws {
    // Both the extended "-08:00" and the colon-less "-0800" forms must decode.
    let inputs = [
      "1996-12-19T16:39:57-08:00",
      "1996-12-19T16:39:57-0800"
    ]

    for input in inputs {
      // when
      let date = try RFC3339Strategy.decode(input)

      // then
      XCTAssertEqual(date, Date(timeIntervalSince1970: 851042397), "failed to decode \(input)")
    }
  }
}
