//
//  LosslessValueTests.swift
//  KarrotCodableKitTests
//
//  Created by Elon on 2023/04/25.
//

import XCTest

import KarrotCodableKit

final class LosslessValueTests: XCTestCase {
  struct Fixture: Equatable, Codable {
    @LosslessValue var bool: Bool
    @LosslessValue var string: String
    @LosslessValue var int: Int
    @LosslessValue var double: Double
  }

  func testDecodingMisalignedTypesFromJSONTraversesCorrectType() throws {
    // given
    let jsonData = #"{ "bool": "true", "string": 42, "int": "1", "double": "7.1" }"#.data(using: .utf8)!

    // when
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)

    // then
    XCTAssertEqual(fixture.bool, true)
    XCTAssertEqual(fixture.string, "42")
    XCTAssertEqual(fixture.int, 1)
    XCTAssertEqual(fixture.double, 7.1)
  }

  func testDecodingEncodedMisalignedTypesFromJSONDecodesCorrectTypes() throws {
    // given
    let jsonData = #"{ "bool": "true", "string": 42, "int": "7", "double": "7.1" }"#.data(using: .utf8)!

    // when
    var _fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)

    _fixture.bool = false
    _fixture.double = 3.14

    // when
    let fixtureData = try JSONEncoder().encode(_fixture)
    // when
    let fixture = try JSONDecoder().decode(Fixture.self, from: fixtureData)

    // then
    XCTAssertEqual(fixture.bool, false)
    XCTAssertEqual(fixture.string, "42")
    XCTAssertEqual(fixture.int, 7)
    XCTAssertEqual(fixture.double, 3.14)
  }

  func testEncodingAndDecodedExpectedTypes() throws {
    // given
    let jsonData = #"{ "bool": true, "string": "42", "int": 7, "double": 7.1 }"#.data(using: .utf8)!

    // when
    let _fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)
    // when
    let fixtureData = try JSONEncoder().encode(_fixture)
    // when
    let fixture = try JSONDecoder().decode(Fixture.self, from: fixtureData)

    // then
    XCTAssertEqual(fixture.bool, true)
    XCTAssertEqual(fixture.string, "42")
    XCTAssertEqual(fixture.int, 7)
    XCTAssertEqual(fixture.double, 7.1)
  }

  func testDecodingBoolIntValueFromJSONDecodesCorrectly() throws {
    struct FixtureWithBooleanAsInteger: Equatable, Codable {
      @LosslessBoolValue var bool: Bool
      @LosslessValue var string: String
      @LosslessValue var int: Int
      @LosslessValue var double: Double
    }

    // given
    let jsonData = #"{ "bool": 1, "string": "42", "int": 7, "double": 7.1 }"#.data(using: .utf8)!

    // when
    let _fixture = try JSONDecoder().decode(FixtureWithBooleanAsInteger.self, from: jsonData)
    // when
    let fixtureData = try JSONEncoder().encode(_fixture)
    // when
    let fixture = try JSONDecoder().decode(FixtureWithBooleanAsInteger.self, from: fixtureData)

    // then
    XCTAssertEqual(fixture.bool, true)
    XCTAssertEqual(fixture.string, "42")
    XCTAssertEqual(fixture.int, 7)
    XCTAssertEqual(fixture.double, 7.1)
  }

  func testBoolAsIntegerShouldNotConflictWithDefaultStrategy() throws {
    struct Response: Codable {
      @LosslessValue var id: String
      @LosslessBoolValue var bool: Bool
    }

    // given
    let json = #"{ "id": 1, "bool": 1 }"#.data(using: .utf8)!

    // when
    let result = try JSONDecoder().decode(Response.self, from: json)

    // then
    XCTAssertEqual(result.id, "1")
    XCTAssertEqual(result.bool, true)
  }

  func testDecodingBoolAsLogicalString() throws {
    struct Response: Codable {
      @LosslessBoolValue var a: Bool
      @LosslessBoolValue var b: Bool
      @LosslessBoolValue var c: Bool
      @LosslessBoolValue var d: Bool
      @LosslessBoolValue var e: Bool
      @LosslessBoolValue var f: Bool
      @LosslessBoolValue var g: Bool
    }

    // given
    let json = #"{ "a": "TRUE", "b": "yes", "c": "1", "d": "y", "e": "t","f":"11", "g":11 }"#
      .data(using: .utf8)!

    // when
    let result = try JSONDecoder().decode(Response.self, from: json)

    // then
    XCTAssertEqual(result.a, true)
    XCTAssertEqual(result.b, true)
    XCTAssertEqual(result.c, true)
    XCTAssertEqual(result.d, true)
    XCTAssertEqual(result.e, true)
    XCTAssertEqual(result.f, true)
    XCTAssertEqual(result.g, true)

    // given
    let json2 = #"{ "a": "FALSE", "b": "no", "c": "0", "d": "n", "e": "f","f":"-11", "g":-11  }"#
      .data(using: .utf8)!

    // when
    let result2 = try JSONDecoder().decode(Response.self, from: json2)

    // then
    XCTAssertEqual(result2.a, false)
    XCTAssertEqual(result2.b, false)
    XCTAssertEqual(result2.c, false)
    XCTAssertEqual(result2.d, false)
    XCTAssertEqual(result2.e, false)
    XCTAssertEqual(result2.f, false)
    XCTAssertEqual(result2.g, false)
  }
}
