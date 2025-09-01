//
//  DefaulEmptyDictionaryTests.swift
//  KarrotCodableKit
//
//  Created by Elon on 2023/04/25.
//

import XCTest

import KarrotCodableKit

final class DefaultEmptyDictionaryTests: XCTestCase {
  struct Fixture: Equatable, Codable {
    @DefaultEmptyDictionary var stringToInt: [String: Int]
  }

  func testDecodingFailableDictionaryDefaultsToEmptyDictionary() throws {
    // given
    let jsonData = #"{ "stringToInt": null }"#.data(using: .utf8)!

    // when
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)

    // then
    XCTAssertEqual(fixture.stringToInt, [:])
  }

  func testDecodingKeyNotPresentDefaultsToEmptyDictionary() throws {
    // given
    let jsonData = #"{}"#.data(using: .utf8)!

    // when
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)

    // then
    XCTAssertEqual(fixture.stringToInt, [:])
  }

  func testEncodingDecodedFailableDictionaryDefaultsToEmptyDictionary() throws {
    // given
    let jsonData = #"{ "stringToInt": null }"#.data(using: .utf8)!
    var _fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)
    _fixture.stringToInt["one"] = 1

    // when
    let fixtureData = try JSONEncoder().encode(_fixture)
    let fixture = try JSONDecoder().decode(Fixture.self, from: fixtureData)

    // then
    XCTAssertEqual(fixture.stringToInt, ["one": 1])
  }

  func testEncodingDecodedFulfillableDictionaryRetainsContents() throws {
    // given
    let jsonData = #"{ "stringToInt": {"one": 1, "two": 2} }"#.data(using: .utf8)!
    let _fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)

    // when
    let fixtureData = try JSONEncoder().encode(_fixture)
    let fixture = try JSONDecoder().decode(Fixture.self, from: fixtureData)

    // then
    XCTAssertEqual(fixture.stringToInt, ["one": 1, "two": 2])
  }
}
