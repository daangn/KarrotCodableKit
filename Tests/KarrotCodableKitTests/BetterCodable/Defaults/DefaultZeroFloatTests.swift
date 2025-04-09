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
    let jsonData = #"{ "floatValue": null }"#.data(using: .utf8)!
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)
    XCTAssertEqual(fixture.floatValue, 0.0)
  }

  func testDecodingKeyNotPresentDefaultZeroFloat() throws {
    let jsonData = #"{}"#.data(using: .utf8)!
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)
    XCTAssertEqual(fixture.floatValue, 0.0)
  }

  func testDecodinSuccessDefaultZeroFloat() throws {
    let jsonData = #"{ "floatValue": 0.001 }"#.data(using: .utf8)!
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)
    XCTAssertEqual(fixture.floatValue, 0.001)
  }
}
