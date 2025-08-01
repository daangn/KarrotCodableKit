//
//  OptionalLosslessValueTests.swift
//  KarrotCodableKitTests
//
//  Created by Elon on 8/1/25.
//

import Foundation
import Testing
@testable import KarrotCodableKit

struct OptionalLosslessValueTests {
  struct Fixture: Equatable, Codable {
    @OptionalLosslessValue var optionalBool: Bool?
    @OptionalLosslessValue var optionalString: String?
    @OptionalLosslessValue var optionalInt: Int?
    @OptionalLosslessValue var optionalDouble: Double?
  }

  @Test
  func decodingNullValues() throws {
    // given
    let json = #"""
    {
      "optionalBool": null,
      "optionalString": null,
      "optionalInt": null,
      "optionalDouble": null
    }
    """#

    // when
    let jsonData = try #require(json.data(using: .utf8))
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)

    // then
    #expect(fixture.optionalBool == nil)
    #expect(fixture.optionalString == nil)
    #expect(fixture.optionalInt == nil)
    #expect(fixture.optionalDouble == nil)
  }

  @Test
  func decodingMissingFields() throws {
    // given
    let json = #"""
    {}
    """#

    // when
    let jsonData = try #require(json.data(using: .utf8))
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)

    // then
    #expect(fixture.optionalBool == nil)
    #expect(fixture.optionalString == nil)
    #expect(fixture.optionalInt == nil)
    #expect(fixture.optionalDouble == nil)
  }

  @Test
  func decodingMisalignedTypesFromJSON() throws {
    // given
    let json = #"""
    {
      "optionalBool": "true",
      "optionalString": 42,
      "optionalInt": "1",
      "optionalDouble": "7.1"
    }
    """#

    // when
    let jsonData = try #require(json.data(using: .utf8))
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)

    // then
    #expect(fixture.optionalBool == true)
    #expect(fixture.optionalString == "42")
    #expect(fixture.optionalInt == 1)
    #expect(fixture.optionalDouble == 7.1)
  }

  @Test("decoding expected types")
  func decodingExpectedTypes() throws {
    // given
    let json = #"""
    {
      "optionalBool": true,
      "optionalString": "42",
      "optionalInt": 7,
      "optionalDouble": 7.1
    }
    """#

    // when
    let jsonData = try #require(json.data(using: .utf8))
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)

    // then
    #expect(fixture.optionalBool == true)
    #expect(fixture.optionalString == "42")
    #expect(fixture.optionalInt == 7)
    #expect(fixture.optionalDouble == 7.1)
  }

  @Test("encoding and decoding with null values")
  func encodingAndDecodingWithNullValues() throws {
    // given
    let fixture = Fixture(
      optionalBool: nil,
      optionalString: nil,
      optionalInt: nil,
      optionalDouble: nil
    )

    // when
    let encodedData = try JSONEncoder().encode(fixture)
    let decodedFixture = try JSONDecoder().decode(Fixture.self, from: encodedData)

    // then
    #expect(fixture == decodedFixture)
  }

  @Test("encoding and decoding with mixed values")
  func encodingAndDecodingWithMixedValues() throws {
    // given
    let fixture = Fixture(
      optionalBool: true,
      optionalString: nil,
      optionalInt: 42,
      optionalDouble: nil
    )

    // when
    let encodedData = try JSONEncoder().encode(fixture)
    let decodedFixture = try JSONDecoder().decode(Fixture.self, from: encodedData)

    // then
    #expect(fixture == decodedFixture)
  }

  @Test("decoding with partial null values")
  func decodingWithPartialNullValues() throws {
    // given
    let json = #"""
    {
      "optionalBool": true,
      "optionalString": null,
      "optionalInt": "42",
      "optionalDouble": 3.14
    }
    """#

    // when
    let jsonData = try #require(json.data(using: .utf8))
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)

    // then
    #expect(fixture.optionalBool == true)
    #expect(fixture.optionalString == nil)
    #expect(fixture.optionalInt == 42)
    #expect(fixture.optionalDouble == 3.14)
  }

  @Test(
    "decoding boolean from various string values",
    arguments: [
      (#"{ "value": "true" }"#, true as Bool?),
      (#"{ "value": "yes" }"#, true as Bool?),
      (#"{ "value": "1" }"#, true as Bool?),
      (#"{ "value": "Y" }"#, true as Bool?),
      (#"{ "value": "t" }"#, true as Bool?),
      (#"{ "value": "false" }"#, false as Bool?),
      (#"{ "value": "0" }"#, false as Bool?),
      (#"{ "value": null }"#, nil as Bool?),
    ]
  )
  func decodingBooleanFromVariousStringValues(json: String, expected: Bool?) throws {
    // given
    struct BoolFixture: Codable {
      @OptionalLosslessValueCodable<LosslessBooleanStrategy<Bool>> var value: Bool?
    }

    // when
    let data = try #require(json.data(using: .utf8))
    let fixture = try JSONDecoder().decode(BoolFixture.self, from: data)

    // then
    #expect(fixture.value == expected)
  }

  @Test("decoding encoded misaligned types with nulls")
  func decodingEncodedMisalignedTypesWithNulls() throws {
    // given
    let json = #"""
    {
      "optionalBool": "true",
      "optionalString": null,
      "optionalInt": "7",
      "optionalDouble": null
    }
    """#

    // when
    let jsonData = try #require(json.data(using: .utf8))
    var fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)
    fixture.optionalBool = false
    fixture.optionalDouble = 3.14

    let fixtureData = try JSONEncoder().encode(fixture)
    let decodedFixture = try JSONDecoder().decode(Fixture.self, from: fixtureData)

    // then
    #expect(decodedFixture.optionalBool == false)
    #expect(decodedFixture.optionalString == nil)
    #expect(decodedFixture.optionalInt == 7)
    #expect(decodedFixture.optionalDouble == 3.14)
  }
}
