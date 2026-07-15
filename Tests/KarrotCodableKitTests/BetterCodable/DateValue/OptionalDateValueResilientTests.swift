//
//  OptionalDateValueResilientTests.swift
//  KarrotCodableKitTests
//
//  Created by Elon on 9/23/25.
//

import Foundation
import KarrotCodableKit
import Testing

@Suite("OptionalDateValue Resilient Decoding")
struct OptionalDateValueResilientTests {
  struct ISO8601Fixture: Decodable {
    @OptionalDateValue<ISO8601Strategy> var dateValue: Date?
  }

  struct TimestampFixture: Decodable {
    @OptionalDateValue<TimestampStrategy> var dateValue: Date?
  }

  // MARK: - ISO8601Strategy Tests

  @Test
  func `ISO8601Strategy: missing key sets outcome to keyNotFound`() throws {
    let json = "{}"

    let decoder = JSONDecoder()
    let data = try #require(json.data(using: .utf8))
    let fixture = try decoder.decode(ISO8601Fixture.self, from: data)

    // Should decode successfully with nil value
    #expect(fixture.dateValue == nil)

    #if DEBUG
    // Outcome should be keyNotFound for missing keys
    #expect(fixture.$dateValue.outcome == .keyNotFound)
    #expect(fixture.$dateValue.error == nil)
    #endif
  }

  @Test
  func `ISO8601Strategy: null value sets outcome to valueWasNil`() throws {
    let json = """
      {
        "dateValue": null
      }
      """

    let decoder = JSONDecoder()
    let data = try #require(json.data(using: .utf8))
    let fixture = try decoder.decode(ISO8601Fixture.self, from: data)

    // Should decode successfully with nil value
    #expect(fixture.dateValue == nil)

    #if DEBUG
    // Outcome should be valueWasNil for null values
    #expect(fixture.$dateValue.outcome == .valueWasNil)
    #expect(fixture.$dateValue.error == nil)
    #endif
  }

  @Test
  func `ISO8601Strategy: valid value sets outcome to decodedSuccessfully`() throws {
    let json = """
      {
        "dateValue": "1996-12-19T16:39:57-08:00"
      }
      """

    let decoder = JSONDecoder()
    let data = try #require(json.data(using: .utf8))
    let fixture = try decoder.decode(ISO8601Fixture.self, from: data)

    // Should decode successfully with expected date
    let expectedDate = Date(timeIntervalSince1970: 851042397)
    #expect(fixture.dateValue == expectedDate)

    #if DEBUG
    // Outcome should be decodedSuccessfully
    #expect(fixture.$dateValue.outcome == .decodedSuccessfully)
    #expect(fixture.$dateValue.error == nil)
    #endif
  }

  @Test
  func `ISO8601Strategy: invalid format throws error`() throws {
    let json = """
      {
        "dateValue": "invalid-date-format"
      }
      """

    let decoder = JSONDecoder()
    let data = try #require(json.data(using: .utf8))

    // Should throw error for invalid format
    #expect(throws: DecodingError.self) {
      try decoder.decode(ISO8601Fixture.self, from: data)
    }
  }

  @Test
  func `ISO8601Strategy: type mismatch throws error`() throws {
    let json = """
      {
        "dateValue": 123456789
      }
      """

    let decoder = JSONDecoder()
    let data = try #require(json.data(using: .utf8))

    // Should throw error for type mismatch
    #expect(throws: DecodingError.self) {
      try decoder.decode(ISO8601Fixture.self, from: data)
    }
  }

  // MARK: - TimestampStrategy Tests

  @Test
  func `TimestampStrategy: missing key sets outcome to keyNotFound`() throws {
    let json = "{}"

    let decoder = JSONDecoder()
    let data = try #require(json.data(using: .utf8))
    let fixture = try decoder.decode(TimestampFixture.self, from: data)

    // Should decode successfully with nil value
    #expect(fixture.dateValue == nil)

    #if DEBUG
    // Outcome should be keyNotFound for missing keys
    #expect(fixture.$dateValue.outcome == .keyNotFound)
    #expect(fixture.$dateValue.error == nil)
    #endif
  }

  @Test
  func `TimestampStrategy: null value sets outcome to valueWasNil`() throws {
    let json = """
      {
        "dateValue": null
      }
      """

    let decoder = JSONDecoder()
    let data = try #require(json.data(using: .utf8))
    let fixture = try decoder.decode(TimestampFixture.self, from: data)

    // Should decode successfully with nil value
    #expect(fixture.dateValue == nil)

    #if DEBUG
    // Outcome should be valueWasNil for null values
    #expect(fixture.$dateValue.outcome == .valueWasNil)
    #expect(fixture.$dateValue.error == nil)
    #endif
  }

  @Test
  func `TimestampStrategy: valid value sets outcome to decodedSuccessfully`() throws {
    let json = """
      {
        "dateValue": 851042397.0
      }
      """

    let decoder = JSONDecoder()
    let data = try #require(json.data(using: .utf8))
    let fixture = try decoder.decode(TimestampFixture.self, from: data)

    // Should decode successfully with expected date
    let expectedDate = Date(timeIntervalSince1970: 851042397.0)
    #expect(fixture.dateValue == expectedDate)

    #if DEBUG
    // Outcome should be decodedSuccessfully
    #expect(fixture.$dateValue.outcome == .decodedSuccessfully)
    #expect(fixture.$dateValue.error == nil)
    #endif
  }

  @Test
  func `TimestampStrategy: integer timestamp works`() throws {
    let json = """
      {
        "dateValue": 851042397
      }
      """

    let decoder = JSONDecoder()
    let data = try #require(json.data(using: .utf8))
    let fixture = try decoder.decode(TimestampFixture.self, from: data)

    // Should decode successfully with expected date
    let expectedDate = Date(timeIntervalSince1970: 851042397.0)
    #expect(fixture.dateValue == expectedDate)

    #if DEBUG
    // Outcome should be decodedSuccessfully
    #expect(fixture.$dateValue.outcome == .decodedSuccessfully)
    #expect(fixture.$dateValue.error == nil)
    #endif
  }

  @Test
  func `TimestampStrategy: type mismatch throws error`() throws {
    let json = """
      {
        "dateValue": "not-a-number"
      }
      """

    let decoder = JSONDecoder()
    let data = try #require(json.data(using: .utf8))

    // Should throw error for type mismatch
    #expect(throws: DecodingError.self) {
      try decoder.decode(TimestampFixture.self, from: data)
    }
  }

  // MARK: - Direct Decoder Tests (Resilient Behavior Works)

  @Test
  func `Direct single value decoding with nil works correctly`() throws {
    // When decoding directly from a single value container, resilient behavior works
    let json = "null"
    let decoder = JSONDecoder()
    let data = try #require(json.data(using: .utf8))

    let dateValue = try decoder.decode(OptionalDateValue<ISO8601Strategy>.self, from: data)

    #expect(dateValue.wrappedValue == nil)

    #if DEBUG
    // Direct decoding properly sets .valueWasNil for null values
    #expect(dateValue.outcome == .valueWasNil)
    #expect(dateValue.projectedValue.error == nil)
    #endif
  }

  @Test
  func `Direct single value decoding with missing key throws error`() throws {
    // When a key is truly missing in single value context, it throws
    let json = "{}"
    let decoder = JSONDecoder()
    let data = try #require(json.data(using: .utf8))

    #expect(throws: DecodingError.self) {
      _ = try decoder.decode(OptionalDateValue<ISO8601Strategy>.self, from: data)
    }
  }

  // MARK: - Mixed Strategy Tests

  @Test
  func `Combined strategies work correctly in same fixture`() throws {
    struct CombinedFixture: Decodable {
      @OptionalDateValue<ISO8601Strategy> var isoDate: Date?
      @OptionalDateValue<TimestampStrategy> var timestampDate: Date?
    }

    let json = """
      {
        "isoDate": "1996-12-19T16:39:57-08:00",
        "timestampDate": null
      }
      """

    let decoder = JSONDecoder()
    let data = try #require(json.data(using: .utf8))
    let fixture = try decoder.decode(CombinedFixture.self, from: data)

    // Should decode ISO date successfully and timestamp as nil
    let expectedDate = Date(timeIntervalSince1970: 851042397)
    #expect(fixture.isoDate == expectedDate)
    #expect(fixture.timestampDate == nil)

    #if DEBUG
    // Outcomes should be correct for each strategy
    #expect(fixture.$isoDate.outcome == .decodedSuccessfully)
    // Null values should set .valueWasNil
    #expect(fixture.$timestampDate.outcome == .valueWasNil)
    #expect(fixture.$isoDate.error == nil)
    #expect(fixture.$timestampDate.error == nil)
    #endif
  }

  @Test
  func `All missing keys scenario`() throws {
    struct CombinedFixture: Decodable {
      @OptionalDateValue<ISO8601Strategy> var isoDate: Date?
      @OptionalDateValue<TimestampStrategy> var timestampDate: Date?
    }

    let json = "{}"

    let decoder = JSONDecoder()
    let data = try #require(json.data(using: .utf8))
    let fixture = try decoder.decode(CombinedFixture.self, from: data)

    // Both should be nil
    #expect(fixture.isoDate == nil)
    #expect(fixture.timestampDate == nil)

    #if DEBUG
    // Missing keys should set .keyNotFound for both
    #expect(fixture.$isoDate.outcome == .keyNotFound)
    #expect(fixture.$timestampDate.outcome == .keyNotFound)
    #expect(fixture.$isoDate.error == nil)
    #expect(fixture.$timestampDate.error == nil)
    #endif
  }
}
