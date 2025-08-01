//
//  OptionalLosslessValueResilientTests.swift
//  KarrotCodableKitTests
//
//  Created by Elon on 8/1/25.
//

import Foundation
import Testing
@testable import KarrotCodableKit

@Suite("OptionalLosslessValue Resilient Decoding")
struct OptionalLosslessValueResilientTests {
  struct Fixture: Decodable {
    @OptionalLosslessValue var optionalStringValue: String?
    @OptionalLosslessValue var optionalIntValue: Int?
    @OptionalLosslessValue var optionalBoolValue: Bool?
    @OptionalLosslessValue var optionalDoubleValue: Double?
  }

  @Test("projected value provides error information for non-null values")
  func projectedValueProvidesErrorInfoForNonNullValues() throws {
    // given
    let json = """
      {
        "optionalStringValue": 123,
        "optionalIntValue": "456",
        "optionalBoolValue": "true",
        "optionalDoubleValue": "3.14"
      }
      """

    // when
    let decoder = JSONDecoder()
    let data = try #require(json.data(using: .utf8))
    let fixture = try decoder.decode(Fixture.self, from: data)

    // then
    // Verify default behavior - all values converted
    #expect(fixture.optionalStringValue == "123")
    #expect(fixture.optionalIntValue == 456)
    #expect(fixture.optionalBoolValue == true)
    #expect(fixture.optionalDoubleValue == 3.14)

    #if DEBUG
    // Access success info through projected value
    #expect(fixture.$optionalStringValue.outcome == .decodedSuccessfully)
    #expect(fixture.$optionalIntValue.outcome == .decodedSuccessfully)
    #expect(fixture.$optionalBoolValue.outcome == .decodedSuccessfully)
    #expect(fixture.$optionalDoubleValue.outcome == .decodedSuccessfully)
    #endif
  }

  @Test("projected value provides info for null values")
  func projectedValueProvidesInfoForNullValues() throws {
    // given
    let json = """
      {
        "optionalStringValue": null,
        "optionalIntValue": null,
        "optionalBoolValue": null,
        "optionalDoubleValue": null
      }
      """

    // when
    let decoder = JSONDecoder()
    let data = try #require(json.data(using: .utf8))
    let fixture = try decoder.decode(Fixture.self, from: data)

    // then
    // Verify all values are nil
    #expect(fixture.optionalStringValue == nil)
    #expect(fixture.optionalIntValue == nil)
    #expect(fixture.optionalBoolValue == nil)
    #expect(fixture.optionalDoubleValue == nil)

    #if DEBUG
    // Access outcome info through projected value
    #expect(fixture.$optionalStringValue.outcome == .valueWasNil)
    #expect(fixture.$optionalIntValue.outcome == .valueWasNil)
    #expect(fixture.$optionalBoolValue.outcome == .valueWasNil)
    #expect(fixture.$optionalDoubleValue.outcome == .valueWasNil)
    #endif
  }

  @Test("projected value provides info for missing fields")
  func projectedValueProvidesInfoForMissingFields() throws {
    // given
    let json = """
      {}
      """

    // when
    let decoder = JSONDecoder()
    let data = try #require(json.data(using: .utf8))
    let fixture = try decoder.decode(Fixture.self, from: data)

    // then
    // Verify all values are nil
    #expect(fixture.optionalStringValue == nil)
    #expect(fixture.optionalIntValue == nil)
    #expect(fixture.optionalBoolValue == nil)
    #expect(fixture.optionalDoubleValue == nil)

    #if DEBUG
    // Access outcome info through projected value
    #expect(fixture.$optionalStringValue.outcome == .keyNotFound)
    #expect(fixture.$optionalIntValue.outcome == .keyNotFound)
    #expect(fixture.$optionalBoolValue.outcome == .keyNotFound)
    #expect(fixture.$optionalDoubleValue.outcome == .keyNotFound)
    #endif
  }

  @Test
  func invalidValue() throws {
    // given
    struct MixedFixture: Decodable {
      @OptionalLosslessValue var optionalStringValue: String?
      @OptionalLosslessValue var optionalIntValue: Int?
      @OptionalLosslessValueCodable<LosslessBooleanStrategy<Bool>> var optionalBoolValue: Bool?
      @OptionalLosslessValue var optionalDoubleValue: Double?
    }

    let json = """
      {
        "optionalStringValue": "hello",
        "optionalIntValue": null,
        "optionalBoolValue": 1,
        "optionalDoubleValue": "invalid"
      }
      """

    // when/then
    let decoder = JSONDecoder()
    let data = try #require(json.data(using: .utf8))
    #expect(throws: DecodingError.self) {
      try decoder.decode(MixedFixture.self, from: data)
    }
  }

  @Test(
    "handles type conversion with bool strategy",
    arguments: [
      (#"{ "value": "true" }"#, true as Bool?, ResilientDecodingOutcome.decodedSuccessfully),
      (#"{ "value": "yes" }"#, true as Bool?, .decodedSuccessfully),
      (#"{ "value": "1" }"#, true as Bool?, .decodedSuccessfully),
      (#"{ "value": 1 }"#, true as Bool?, .decodedSuccessfully),
      (#"{ "value": null }"#, nil as Bool?, .valueWasNil),
      (#"{}"#, nil as Bool?, .keyNotFound),
    ]
  )
  func handlesTypeConversionWithBoolStrategy(
    json: String,
    expected: Bool?,
    outcome: ResilientDecodingOutcome
  ) throws {
    // given
    struct BoolFixture: Decodable {
      @OptionalLosslessValueCodable<LosslessBooleanStrategy<Bool>> var value: Bool?
    }

    // when
    let data = try #require(json.data(using: .utf8))
    let fixture = try JSONDecoder().decode(BoolFixture.self, from: data)

    // then
    #expect(fixture.value == expected)

    #if DEBUG
    #expect(fixture.$value.outcome == outcome)
    #endif
  }
}
