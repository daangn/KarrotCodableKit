//
//  DefaultTrueTests.swift
//  KarrotCodableKit
//
//  Created by Elon on 2023/04/25.
//

import XCTest

import KarrotCodableKit

final class DefaultTrueTests: XCTestCase {
  struct Fixture: Equatable, Codable {
    @DefaultTrue var truthy: Bool
  }

  func testDecodingFailableArrayDefaultsToFalse() throws {
    let jsonData = #"{ "truthy": null }"#.data(using: .utf8)!
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)
    XCTAssertEqual(fixture.truthy, true)
  }

  func testDecodingKeyNotPresentDefaultsToFalse() throws {
    let jsonData = #"{}"#.data(using: .utf8)!
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)
    XCTAssertEqual(fixture.truthy, true)
  }

  func testEncodingDecodedFailableArrayDefaultsToFalse() throws {
    let jsonData = #"{ "truthy": null }"#.data(using: .utf8)!
    var _fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)

    _fixture.truthy = false

    let fixtureData = try JSONEncoder().encode(_fixture)
    let fixture = try JSONDecoder().decode(Fixture.self, from: fixtureData)
    XCTAssertEqual(fixture.truthy, false)
  }

  func testEncodingDecodedFulfillableBoolRetainsValue() throws {
    let jsonData = #"{ "truthy": true }"#.data(using: .utf8)!
    let _fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)
    let fixtureData = try JSONEncoder().encode(_fixture)
    let fixture = try JSONDecoder().decode(Fixture.self, from: fixtureData)

    XCTAssertEqual(fixture.truthy, true)
  }

  func testDecodingMisalignedBoolIntValueDecodesCorrectBoolValue() throws {
    let jsonData = #"{ "truthy": 1 }"#.data(using: .utf8)!
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)
    XCTAssertEqual(fixture.truthy, true)

    let jsonData2 = #"{ "truthy": 0 }"#.data(using: .utf8)!
    let fixture2 = try JSONDecoder().decode(Fixture.self, from: jsonData2)
    XCTAssertEqual(fixture2.truthy, false)
  }

  func testDecodingInvalidValueDecodesToDefaultValue() throws {
    let jsonData = #"{ "truthy": "invalidValue" }"#.data(using: .utf8)!
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)
    XCTAssertEqual(
      fixture.truthy,
      true,
      "Should fall in to the else block and return default value"
    )
  }

  func testDecodingMisalignedBoolStringValueDecodesCorrectBoolValue() throws {
    let jsonData = #"{ "truthy": "true" }"#.data(using: .utf8)!
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)
    XCTAssertEqual(fixture.truthy, true)

    let jsonData2 = #"{ "truthy": "false" }"#.data(using: .utf8)!
    let fixture2 = try JSONDecoder().decode(Fixture.self, from: jsonData2)
    XCTAssertEqual(fixture2.truthy, false)
  }
}
