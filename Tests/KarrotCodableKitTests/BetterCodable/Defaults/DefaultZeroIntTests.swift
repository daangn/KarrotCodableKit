//
//  DefaultZeroIntTests.swift
//  KarrotCodableKitTests
//
//  Created by Elon on 2023/04/27.
//

import XCTest

import KarrotCodableKit

final class DefaultZeroIntTests: XCTestCase {
  struct Fixture: Equatable, Codable {
    @DefaultZeroInt var intValue: Int
  }

  func testDecodingFailableIntDefaultZeroInt() throws {
    // given
    let jsonData = #"{ "intValue": null }"#.data(using: .utf8)!

    // when
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)

    // then
    XCTAssertEqual(fixture.intValue, 0)
  }

  func testDecodingKeyNotPresentDefaultZeroInt() throws {
    // given
    let jsonData = #"{}"#.data(using: .utf8)!

    // when
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)

    // then
    XCTAssertEqual(fixture.intValue, 0)
  }

  func testDecodinSuccessDefaultZeroInt() throws {
    // given
    let jsonData = #"{ "intValue": 999 }"#.data(using: .utf8)!

    // when
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)

    // then
    XCTAssertEqual(fixture.intValue, 999)
  }
}
