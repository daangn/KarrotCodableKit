//
//  DefaultEmptyArrayTests.swift
//  KarrotCodableKitTests
//
//  Created by Elon on 2023/04/25.
//

import XCTest

import KarrotCodableKit

final class DefaultEmptyArrayTests: XCTestCase {
  struct Fixture: Equatable, Codable {
    struct NestedFixture: Equatable, Codable {
      var one: String
      var two: [String: [String]]
    }

    @DefaultEmptyArray var values: [Int]
    @DefaultEmptyArray var nonPrimitiveValues: [NestedFixture]
  }

  func testDecodingFailableArrayDefaultsToEmptyArray() throws {
    // given
    let jsonData = #"{ "values": null, "nonPrimitiveValues": null }"#.data(using: .utf8)!

    // when
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)

    // then
    XCTAssertEqual(fixture.values, [])
    XCTAssertEqual(fixture.nonPrimitiveValues, [])
  }

  func testDecodingKeyNotPresentDefaultsToEmptyArray() throws {
    // given
    let jsonData = #"{}"#.data(using: .utf8)!

    // when
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)

    // then
    XCTAssertEqual(fixture.values, [])
    XCTAssertEqual(fixture.nonPrimitiveValues, [])
  }

  func testEncodingDecodedFailableArrayDefaultsToEmptyArray() throws {
    // given
    let jsonData = #"{ "values": null, "nonPrimitiveValues": null }"#.data(using: .utf8)!
    var _fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)
    _fixture.values += [1, 2, 3]
    _fixture.nonPrimitiveValues += [Fixture.NestedFixture(one: "a", two: ["b": ["c"]])]

    // when
    let fixtureData = try JSONEncoder().encode(_fixture)
    let fixture = try JSONDecoder().decode(Fixture.self, from: fixtureData)

    // then
    XCTAssertEqual(fixture.values, [1, 2, 3])
    XCTAssertEqual(fixture.nonPrimitiveValues, [Fixture.NestedFixture(one: "a", two: ["b": ["c"]])])
  }

  func testEncodingDecodedFulfillableArrayRetainsContents() throws {
    // given
    let jsonData = #"{ "values": [1, 2], "nonPrimitiveValues": [{ "one": "one", "two": {"key": ["value"]}}] }"#
      .data(using: .utf8)!
    let _fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)

    // when
    let fixtureData = try JSONEncoder().encode(_fixture)
    let fixture = try JSONDecoder().decode(Fixture.self, from: fixtureData)

    // then
    XCTAssertEqual(fixture.values, [1, 2])
    XCTAssertEqual(fixture.nonPrimitiveValues, [Fixture.NestedFixture(one: "one", two: ["key": ["value"]])])
  }
}
