//
//  LossyOptionalTests.swift
//  KarrotCodableKitTests
//
//  Created by Elon on 2023/04/25.
//

import Testing
import Foundation

import KarrotCodableKit

struct DefaultNilTests {
  /// This test demonstrates the problem that `@LossyOptional` solves. When decoding
  /// optional types, it often the case that we end up with an error instead of
  /// defaulting back to `nil`.
  @Test func testDecodingBadUrlAsOptionalWithoutDefaultNil() {
    // given
    struct Fixture: Codable {
      var a: URL?
    }
    let jsonData = #"{"a":"https://example .com"}"#.data(using: .utf8)!

    // when/then
    #expect(throws: (any Error).self) { try JSONDecoder().decode(Fixture.self, from: jsonData) }
  }

  @Test func testDecodingWithUrlConversions() throws {
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
    #expect(fixture.a == nil)
    #expect(fixture.b == URL(string: goodUrlString))
  }

  @Test func testDecodingWithIntegerConversions() throws {
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
    #expect(fixture.a == nil)
    #expect(fixture.b == 3)
  }

  @Test func testDecodingWithNullValue() throws {
    // given
    struct Fixture: Codable {
      @LossyOptional var a: String?
    }
    let jsonData = #"{"a":null}"#.data(using: .utf8)!

    // when
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)

    // then
    #expect(fixture.a == nil)
  }

  @Test func testDecodingWithMissingKey() throws {
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
    #expect(fixture.a == nil)
  }
}
