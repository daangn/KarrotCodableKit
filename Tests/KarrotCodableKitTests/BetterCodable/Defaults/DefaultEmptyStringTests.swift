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
    let jsonData = #"{ "string": null }"#.data(using: .utf8)!
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)
    XCTAssertEqual(fixture.string, "")
  }

  func testDecodingKeyNotPresentDefaultEmptyString() throws {
    let jsonData = #"{}"#.data(using: .utf8)!
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)
    XCTAssertEqual(fixture.string, "")
  }

  func testDecodinSuccessDefaultEmptyString() throws {
    let jsonData = #"{ "string": "hi" }"#.data(using: .utf8)!
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)
    XCTAssertEqual(fixture.string, "hi")
  }
}
