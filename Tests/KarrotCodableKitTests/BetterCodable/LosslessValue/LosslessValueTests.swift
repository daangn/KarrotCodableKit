//
//  LosslessValueTests.swift
//  KarrotCodableKitTests
//
//  Created by Elon on 2023/04/25.
//

import Testing
import Foundation

import KarrotCodableKit

struct LosslessValueTests {
  struct Fixture: Equatable, Codable {
    @LosslessValue var bool: Bool
    @LosslessValue var string: String
    @LosslessValue var int: Int
    @LosslessValue var double: Double
  }

  @Test func testDecodingMisalignedTypesFromJSONTraversesCorrectType() throws {
    // given
    let jsonData = #"{ "bool": "true", "string": 42, "int": "1", "double": "7.1" }"#.data(using: .utf8)!

    // when
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)

    // then
    #expect(fixture.bool == true)
    #expect(fixture.string == "42")
    #expect(fixture.int == 1)
    #expect(fixture.double == 7.1)
  }

  @Test func testDecodingEncodedMisalignedTypesFromJSONDecodesCorrectTypes() throws {
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
    #expect(fixture.bool == false)
    #expect(fixture.string == "42")
    #expect(fixture.int == 7)
    #expect(fixture.double == 3.14)
  }

  @Test func testEncodingAndDecodedExpectedTypes() throws {
    // given
    let jsonData = #"{ "bool": true, "string": "42", "int": 7, "double": 7.1 }"#.data(using: .utf8)!

    // when
    let _fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)
    // when
    let fixtureData = try JSONEncoder().encode(_fixture)
    // when
    let fixture = try JSONDecoder().decode(Fixture.self, from: fixtureData)

    // then
    #expect(fixture.bool == true)
    #expect(fixture.string == "42")
    #expect(fixture.int == 7)
    #expect(fixture.double == 7.1)
  }

  @Test func testDecodingBoolIntValueFromJSONDecodesCorrectly() throws {
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
    #expect(fixture.bool == true)
    #expect(fixture.string == "42")
    #expect(fixture.int == 7)
    #expect(fixture.double == 7.1)
  }

  @Test func testBoolAsIntegerShouldNotConflictWithDefaultStrategy() throws {
    struct Response: Codable {
      @LosslessValue var id: String
      @LosslessBoolValue var bool: Bool
    }

    // given
    let json = #"{ "id": 1, "bool": 1 }"#.data(using: .utf8)!

    // when
    let result = try JSONDecoder().decode(Response.self, from: json)

    // then
    #expect(result.id == "1")
    #expect(result.bool == true)
  }

  @Test func testDecodingBoolAsLogicalString() throws {
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
    #expect(result.a == true)
    #expect(result.b == true)
    #expect(result.c == true)
    #expect(result.d == true)
    #expect(result.e == true)
    #expect(result.f == true)
    #expect(result.g == true)

    // given
    let json2 = #"{ "a": "FALSE", "b": "no", "c": "0", "d": "n", "e": "f","f":"-11", "g":-11  }"#
      .data(using: .utf8)!

    // when
    let result2 = try JSONDecoder().decode(Response.self, from: json2)

    // then
    #expect(result2.a == false)
    #expect(result2.b == false)
    #expect(result2.c == false)
    #expect(result2.d == false)
    #expect(result2.e == false)
    #expect(result2.f == false)
    #expect(result2.g == false)
  }
}
