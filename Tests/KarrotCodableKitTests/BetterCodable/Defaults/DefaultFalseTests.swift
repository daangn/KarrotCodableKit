//
//  DataValueTests.swift
//  KarrotCodableKit
//
//  Created by Elon on 2023/04/25.
//  Copyright © 2023 Danggeun Market Inc. All rights reserved.
//

import XCTest

import KarrotCodableKit

final class DefaultFalseTests: XCTestCase {
  struct Fixture: Equatable, Codable {
    @DefaultFalse var truthy: Bool
  }

  func testDecodingFailableArrayDefaultsToFalse() throws {
    // given
    let jsonData = #"{ "truthy": null }"#.data(using: .utf8)!

    // when
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)

    // then
    XCTAssertEqual(fixture.truthy, false)
  }

  func testDecodingKeyNotPresentDefaultsToFalse() throws {
    // given
    let jsonData = #"{}"#.data(using: .utf8)!

    // when
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)

    // then
    XCTAssertEqual(fixture.truthy, false)
  }

  func testEncodingDecodedFailableArrayDefaultsToFalse() throws {
    // given
    let jsonData = #"{ "truthy": null }"#.data(using: .utf8)!
    var _fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)
    _fixture.truthy = true

    // when
    let fixtureData = try JSONEncoder().encode(_fixture)
    let fixture = try JSONDecoder().decode(Fixture.self, from: fixtureData)

    // then
    XCTAssertEqual(fixture.truthy, true)
  }

  func testEncodingDecodedFulfillableBoolRetainsValue() throws {
    // given
    let jsonData = #"{ "truthy": true }"#.data(using: .utf8)!
    let _fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)

    // when
    let fixtureData = try JSONEncoder().encode(_fixture)
    let fixture = try JSONDecoder().decode(Fixture.self, from: fixtureData)

    // then
    XCTAssertEqual(fixture.truthy, true)
  }

  func testDecodingMisalignedBoolIntValueDecodesCorrectBoolValue() throws {
    // given
    let jsonData = #"{ "truthy": 1 }"#.data(using: .utf8)!
    let jsonData2 = #"{ "truthy": 0 }"#.data(using: .utf8)!

    // when
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)
    let fixture2 = try JSONDecoder().decode(Fixture.self, from: jsonData2)

    // then
    XCTAssertEqual(fixture.truthy, true)
    XCTAssertEqual(fixture2.truthy, false)
  }

  func testDecodingMisalignedBoolStringValueDecodesCorrectBoolValue() throws {
    // given
    let jsonData = #"{ "truthy": "true" }"#.data(using: .utf8)!
    let jsonData2 = #"{ "truthy": "false" }"#.data(using: .utf8)!

    // when
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)
    let fixture2 = try JSONDecoder().decode(Fixture.self, from: jsonData2)

    // then
    XCTAssertEqual(fixture.truthy, true)
    XCTAssertEqual(fixture2.truthy, false)
  }

  func testDecodingInvalidValueDecodesToDefaultValue() throws {
    // given
    let jsonData = #"{ "truthy": "invalidValue" }"#.data(using: .utf8)!

    // when
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)

    // then
    XCTAssertEqual(
      fixture.truthy,
      false,
      "Should fall in to the else block and return default value"
    )
  }
}
