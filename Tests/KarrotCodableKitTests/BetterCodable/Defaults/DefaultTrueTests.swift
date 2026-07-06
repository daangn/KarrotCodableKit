//
//  DefaultTrueTests.swift
//  KarrotCodableKit
//
//  Created by Elon on 2023/04/25.
//

import Testing
import Foundation

import KarrotCodableKit

struct DefaultTrueTests {
  struct Fixture: Equatable, Codable {
    @DefaultTrue var truthy: Bool
  }

  @Test func testDecodingFailableArrayDefaultsToFalse() throws {
    // given
    let jsonData = #"{ "truthy": null }"#.data(using: .utf8)!

    // when
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)

    // then
    #expect(fixture.truthy == true)
  }

  @Test func testDecodingKeyNotPresentDefaultsToFalse() throws {
    // given
    let jsonData = #"{}"#.data(using: .utf8)!

    // when
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)

    // then
    #expect(fixture.truthy == true)
  }

  @Test func testEncodingDecodedFailableArrayDefaultsToFalse() throws {
    // given
    let jsonData = #"{ "truthy": null }"#.data(using: .utf8)!
    var _fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)
    _fixture.truthy = false

    // when
    let fixtureData = try JSONEncoder().encode(_fixture)
    let fixture = try JSONDecoder().decode(Fixture.self, from: fixtureData)

    // then
    #expect(fixture.truthy == false)
  }

  @Test func testEncodingDecodedFulfillableBoolRetainsValue() throws {
    // given
    let jsonData = #"{ "truthy": true }"#.data(using: .utf8)!
    let _fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)

    // when
    let fixtureData = try JSONEncoder().encode(_fixture)
    let fixture = try JSONDecoder().decode(Fixture.self, from: fixtureData)

    // then
    #expect(fixture.truthy == true)
  }

  @Test func testDecodingMisalignedBoolIntValueDecodesCorrectBoolValue() throws {
    // given
    let jsonData = #"{ "truthy": 1 }"#.data(using: .utf8)!
    let jsonData2 = #"{ "truthy": 0 }"#.data(using: .utf8)!

    // when
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)
    let fixture2 = try JSONDecoder().decode(Fixture.self, from: jsonData2)

    // then
    #expect(fixture.truthy == true)
    #expect(fixture2.truthy == false)
  }

  @Test func testDecodingInvalidValueDecodesToDefaultValue() throws {
    // given
    let jsonData = #"{ "truthy": "invalidValue" }"#.data(using: .utf8)!

    // when
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)

    // then
    #expect(fixture.truthy == true, "Should fall in to the else block and return default value")
  }

  @Test func testDecodingMisalignedBoolStringValueDecodesCorrectBoolValue() throws {
    // given
    let jsonData = #"{ "truthy": "true" }"#.data(using: .utf8)!
    let jsonData2 = #"{ "truthy": "false" }"#.data(using: .utf8)!

    // when
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)
    let fixture2 = try JSONDecoder().decode(Fixture.self, from: jsonData2)

    // then
    #expect(fixture.truthy == true)
    #expect(fixture2.truthy == false)
  }
}
