//
//  DefaultEmptyStringTests.swift
//  KarrotCodableKitTests
//
//  Created by Elon on 2023/04/27.
//  Copyright © 2023 Danggeun Market Inc. All rights reserved.
//

import XCTest

import KarrotCodableKit

final class DefaultEmptyStringTests: XCTestCase {
  struct Fixture: Equatable, Codable {
    @DefaultEmptyString var string: String
  }

  func testDecodingFailableStringDefaultEmptyString() throws {
    // given
    let jsonData = #"{ "string": null }"#.data(using: .utf8)!

    // when
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)

    // then
    XCTAssertEqual(fixture.string, "")
  }

  func testDecodingKeyNotPresentDefaultEmptyString() throws {
    // given
    let jsonData = #"{}"#.data(using: .utf8)!

    // when
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)

    // then
    XCTAssertEqual(fixture.string, "")
  }

  func testDecodinSuccessDefaultEmptyString() throws {
    // given
    let jsonData = #"{ "string": "hi" }"#.data(using: .utf8)!

    // when
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)

    // then
    XCTAssertEqual(fixture.string, "hi")
  }
}
