//
//  RFC3339StrategyEncodingTests.swift
//  KarrotCodableKit
//
//  Created by Elon on 7/13/26.
//

import XCTest

import KarrotCodableKit

final class RFC3339StrategyEncodingTests: XCTestCase {
  func testEncodingUTCDateUsesStandardCompliantOffset() throws {
    // given
    let date = Date(timeIntervalSince1970: 1715082540) // 2024-05-07T11:49:00 UTC

    // when
    let result = RFC3339Strategy.encode(date)

    // then
    // RFC 3339 requires the UTC offset to be "Z" (or "+00:00"), not the colon-less "+0000".
    XCTAssertEqual(result, "2024-05-07T11:49:00Z")
  }
}
