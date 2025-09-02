//
//  DefaultZeroFloatTests.swift
//  KarrotCodableKitTests
//
//  Created by daniel on 2023/10/11.
//  Copyright © 2023 Danggeun Market Inc. All rights reserved.
//

import XCTest

import KarrotCodableKit

final class DefaultZeroFloatTests: XCTestCase {
  struct Fixture: Equatable, Codable {
    @DefaultZeroFloat var floatValue: Float
  }

  func testDecodingFailableFloatDefaultZeroFloat() throws {
    // given
    let jsonData = #"{ "floatValue": null }"#.data(using: .utf8)!

    // when
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)

    // then
    XCTAssertEqual(fixture.floatValue, 0.0)
  }

  func testDecodingKeyNotPresentDefaultZeroFloat() throws {
    // given
    let jsonData = #"{}"#.data(using: .utf8)!

    // when
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)

    // then
    XCTAssertEqual(fixture.floatValue, 0.0)
  }

  func testDecodinSuccessDefaultZeroFloat() throws {
    // given
    let jsonData = #"{ "floatValue": 0.001 }"#.data(using: .utf8)!

    // when
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)

    // then
    XCTAssertEqual(fixture.floatValue, 0.001)
  }
}
