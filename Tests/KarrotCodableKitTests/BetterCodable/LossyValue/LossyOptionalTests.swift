//
//  LossyOptionalTests.swift
//  KarrotCodableKitTests
//
//  Created by Elon on 2023/04/25.
//

import XCTest

import KarrotCodableKit

final class DefaultNilTests: XCTestCase {
  /// This test demonstrates the problem that `@LossyOptional` solves. When decoding
  /// optional types, it often the case that we end up with an error instead of
  /// defaulting back to `nil`.
  func testDecodingBadUrlAsOptionalWithoutDefaultNil() {
    // given
    struct Fixture: Codable {
      var a: URL?
    }
    let jsonData = #"{"a":"https://example .com"}"#.data(using: .utf8)!

    // when/then
    XCTAssertThrowsError(try JSONDecoder().decode(Fixture.self, from: jsonData))
  }

  func testDecodingWithUrlConversions() throws {
    // given
    struct Fixture: Codable {
      @LossyOptional var a: URL?
      @LossyOptional var b: URL?
    }
    let badUrlString = "https://example .com"
    let goodUrlString = "https://example.com"
    let jsonData = #"{"a":"\#(badUrlString)", "b":"\#(goodUrlString)"}"#.data(using: .utf8)!

    // when
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)

    // then
    XCTAssertNil(fixture.a)
    XCTAssertEqual(fixture.b, URL(string: goodUrlString))
  }

  func testDecodingWithIntegerConversions() throws {
    // given
    struct Fixture: Codable {
      @LossyOptional var a: Int?
      @LossyOptional var b: Int?
    }
    let jsonData = #"{ "a": 3.14, "b": 3 }"#.data(using: .utf8)!

    // when
    let _fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)
    let fixtureData = try JSONEncoder().encode(_fixture)
    let fixture = try JSONDecoder().decode(Fixture.self, from: fixtureData)

    // then
    XCTAssertNil(fixture.a)
    XCTAssertEqual(fixture.b, 3)
  }

  func testDecodingWithNullValue() throws {
    // given
    struct Fixture: Codable {
      @LossyOptional var a: String?
    }
    let jsonData = #"{"a":null}"#.data(using: .utf8)!

    // when
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)

    // then
    XCTAssertNil(fixture.a)
  }

  func testDecodingWithMissingKey() throws {
    // given
    struct Fixture: Codable {
      @LossyOptional var a: String?
    }
    let jsonData = "{}".data(using: .utf8)!

    // when
    let _fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)
    let fixtureData = try JSONEncoder().encode(_fixture)
    let fixture = try JSONDecoder().decode(Fixture.self, from: fixtureData)

    // then
    XCTAssertNil(fixture.a)
  }
}
