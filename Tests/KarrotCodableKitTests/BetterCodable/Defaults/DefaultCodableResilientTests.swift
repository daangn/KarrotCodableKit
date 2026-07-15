//
//  DefaultCodableResilientTests.swift
//  KarrotCodableKitTests
//
//  Created by Elon on 4/9/25.
//

import Foundation
import KarrotCodableKit
import Testing

@Suite("DefaultCodable Resilient Decoding")
struct DefaultCodableResilientTests {
  struct Fixture: Decodable {
    @DefaultZeroInt var intValue: Int
    @DefaultEmptyString var stringValue: String
    @DefaultFalse var boolValue: Bool
    @DefaultEmptyArray var arrayValue: [String]
    @DefaultEmptyDictionary var dictValue: [String: Int]
  }

  @Test
  func `projected value provides error information for failed decoding`() throws {
    let json = """
      {
        "intValue": "not a number",
        "stringValue": 123,
        "boolValue": "not a bool",
        "arrayValue": "not an array",
        "dictValue": "not a dict"
      }
      """

    let decoder = JSONDecoder()
    let data = try #require(json.data(using: .utf8))
    let fixture = try decoder.decode(Fixture.self, from: data)

    // Verify default behavior - use default value on decoding failure
    #expect(fixture.intValue == 0)
    #expect(fixture.stringValue == "")
    #expect(fixture.boolValue == false)
    #expect(fixture.arrayValue == [])
    #expect(fixture.dictValue == [:])

    #if DEBUG
    // Access error info through projected value
    #expect(fixture.$intValue.error != nil)
    #expect(fixture.$stringValue.error != nil)
    #expect(fixture.$boolValue.error != nil)
    #expect(fixture.$arrayValue.error != nil)
    #expect(fixture.$dictValue.error != nil)

    /// Check error type
    let error = try #require(fixture.$intValue.error as? DecodingError)
    switch error {
    case .typeMismatch:
      // Expected
      break
    default:
      Issue.record("Expected typeMismatch error")
    }
    #endif
  }

  @Test
  func `missing keys use default values without error`() throws {
    let json = "{}"

    let decoder = JSONDecoder()
    let data = try #require(json.data(using: .utf8))
    let fixture = try decoder.decode(Fixture.self, from: data)

    // Check default values
    #expect(fixture.intValue == 0)
    #expect(fixture.stringValue == "")
    #expect(fixture.boolValue == false)
    #expect(fixture.arrayValue == [])
    #expect(fixture.dictValue == [:])

    #if DEBUG
    // No error when key is missing (default behavior)
    #expect(fixture.$intValue.error == nil)
    #expect(fixture.$stringValue.error == nil)
    #expect(fixture.$boolValue.error == nil)
    #expect(fixture.$arrayValue.error == nil)
    #expect(fixture.$dictValue.error == nil)
    #endif
  }

  @Test
  func `valid values decode successfully`() throws {
    let json = """
      {
        "intValue": 42,
        "stringValue": "hello",
        "boolValue": true,
        "arrayValue": ["a", "b", "c"],
        "dictValue": {"key": 123}
      }
      """

    let decoder = JSONDecoder()
    let data = try #require(json.data(using: .utf8))
    let fixture = try decoder.decode(Fixture.self, from: data)

    // Check normal values
    #expect(fixture.intValue == 42)
    #expect(fixture.stringValue == "hello")
    #expect(fixture.boolValue == true)
    #expect(fixture.arrayValue == ["a", "b", "c"])
    #expect(fixture.dictValue == ["key": 123])

    #if DEBUG
    // No error when successfully decoded
    #expect(fixture.$intValue.error == nil)
    #expect(fixture.$stringValue.error == nil)
    #expect(fixture.$boolValue.error == nil)
    #expect(fixture.$arrayValue.error == nil)
    #expect(fixture.$dictValue.error == nil)
    #endif
  }

  @Test
  func `null values use default values`() throws {
    let json = """
      {
        "intValue": null,
        "stringValue": null,
        "boolValue": null,
        "arrayValue": null,
        "dictValue": null
      }
      """

    let decoder = JSONDecoder()
    let data = try #require(json.data(using: .utf8))
    let fixture = try decoder.decode(Fixture.self, from: data)

    // Use default value for null
    #expect(fixture.intValue == 0)
    #expect(fixture.stringValue == "")
    #expect(fixture.boolValue == false)
    #expect(fixture.arrayValue == [])
    #expect(fixture.dictValue == [:])

    #if DEBUG
    // null is not considered an error
    #expect(fixture.$intValue.error == nil)
    #expect(fixture.$stringValue.error == nil)
    #expect(fixture.$boolValue.error == nil)
    #expect(fixture.$arrayValue.error == nil)
    #expect(fixture.$dictValue.error == nil)
    #endif
  }

  @Test
  func `error reporting with JSONDecoder`() throws {
    let json = """
      {
        "intValue": "invalid",
        "stringValue": [],
        "boolValue": {}
      }
      """

    let decoder = JSONDecoder()
    let errorReporter = decoder.enableResilientDecodingErrorReporting()

    let data = try #require(json.data(using: .utf8))
    _ = try decoder.decode(Fixture.self, from: data)

    let errorDigest = errorReporter.flushReportedErrors()

    #if DEBUG
    let digest = try #require(errorDigest)
    // At least 3 errors should be reported
    #expect(digest.errors.count >= 3)
    print("Error digest: \(digest.debugDescription)")
    #else
    #expect(errorDigest == nil)
    #endif
  }

  @Test
  func `LossyOptional behavior`() throws {
    struct OptionalFixture: Decodable {
      @LossyOptional var url: URL?
      @LossyOptional var date: Date?
      @LossyOptional var number: Int?
    }

    let json = """
      {
        "url": "https://example .com",
        "date": "not a date",
        "number": "not a number"
      }
      """

    let decoder = JSONDecoder()
    let data = try #require(json.data(using: .utf8))
    let fixture = try decoder.decode(OptionalFixture.self, from: data)

    // nil on decoding failure
    #expect(fixture.url == nil)
    #expect(fixture.date == nil)
    #expect(fixture.number == nil)

    #if DEBUG
    // Check error info
    #expect(fixture.$url.error != nil)
    #expect(fixture.$date.error != nil)
    #expect(fixture.$number.error != nil)
    #endif
  }

  // MARK: - RawRepresentable Support Tests

  enum TestEnum: String, Decodable, DefaultCodableStrategy {
    case first
    case second
    case unknown

    static var defaultValue: TestEnum { .unknown }
  }

  enum FrozenTestEnum: String, Decodable, DefaultCodableStrategy {
    case alpha
    case beta
    case fallback

    static var defaultValue: FrozenTestEnum { .fallback }
    static var isFrozen: Bool { true }
  }

  struct RawRepresentableFixture: Decodable {
    @DefaultCodable<TestEnum> var normalEnum: TestEnum
    @DefaultCodable<FrozenTestEnum> var frozenEnum: FrozenTestEnum
  }

  @Test
  func `RawRepresentable with valid raw values`() throws {
    // given
    let json = """
      {
        "normalEnum": "first",
        "frozenEnum": "alpha"
      }
      """

    // when
    let decoder = JSONDecoder()
    let data = try #require(json.data(using: .utf8))
    let fixture = try decoder.decode(RawRepresentableFixture.self, from: data)

    // then
    #expect(fixture.normalEnum == .first)
    #expect(fixture.frozenEnum == .alpha)

    #if DEBUG
    #expect(fixture.$normalEnum.outcome == .decodedSuccessfully)
    #expect(fixture.$frozenEnum.outcome == .decodedSuccessfully)
    #expect(fixture.$normalEnum.error == nil)
    #expect(fixture.$frozenEnum.error == nil)
    #endif
  }

  @Test
  func `RawRepresentable with unknown raw values (non-frozen)`() throws {
    // given
    let json = """
      {
        "normalEnum": "third",
        "frozenEnum": "beta"
      }
      """

    // when
    let decoder = JSONDecoder()
    let data = try #require(json.data(using: .utf8))
    let fixture = try decoder.decode(RawRepresentableFixture.self, from: data)

    // then
    #expect(fixture.normalEnum == .unknown) // Should use default value
    #expect(fixture.frozenEnum == .beta)

    #if DEBUG
    // Non-frozen enum should recover with UnknownNovelValueError
    if case .recoveredFrom(let error as UnknownNovelValueError, _) = fixture.$normalEnum.outcome {
      #expect(error.novelValue as? String == "third")
    } else {
      Issue.record("Expected recoveredFrom outcome with UnknownNovelValueError")
    }
    #expect(fixture.$frozenEnum.outcome == .decodedSuccessfully)
    #endif
  }

  @Test
  func `RawRepresentable with unknown raw values (frozen)`() throws {
    // given
    let json = """
      {
        "normalEnum": "first",
        "frozenEnum": "gamma"
      }
      """

    // when
    let decoder = JSONDecoder()
    let errorReporter = decoder.enableResilientDecodingErrorReporting()
    let data = try #require(json.data(using: .utf8))
    let fixture = try decoder.decode(RawRepresentableFixture.self, from: data)

    // then
    #expect(fixture.normalEnum == .first)
    #expect(fixture.frozenEnum == .fallback) // Should use default value due to error

    #if DEBUG
    // Frozen enum should report DecodingError
    if case .recoveredFrom(let error, _) = fixture.$frozenEnum.outcome {
      #expect(error is DecodingError)
      if case .dataCorrupted = error as? DecodingError {
        // Expected
      } else {
        Issue.record("Expected dataCorrupted DecodingError for frozen enum")
      }
    } else {
      Issue.record("Expected recoveredFrom outcome for frozen enum")
    }

    /// Error should be reported to error reporter
    let errorDigest = errorReporter.flushReportedErrors()
    #expect(errorDigest != nil)
    #endif
  }

  @Test
  func `RawRepresentable with missing keys`() throws {
    // given
    let json = "{}"

    // when
    let decoder = JSONDecoder()
    let data = try #require(json.data(using: .utf8))
    let fixture = try decoder.decode(RawRepresentableFixture.self, from: data)

    // then
    #expect(fixture.normalEnum == .unknown)
    #expect(fixture.frozenEnum == .fallback)

    #if DEBUG
    #expect(fixture.$normalEnum.outcome == .keyNotFound)
    #expect(fixture.$frozenEnum.outcome == .keyNotFound)
    #expect(fixture.$normalEnum.error == nil)
    #expect(fixture.$frozenEnum.error == nil)
    #endif
  }

  @Test
  func `RawRepresentable with null values`() throws {
    // given
    let json = """
      {
        "normalEnum": null,
        "frozenEnum": null
      }
      """

    // when
    let decoder = JSONDecoder()
    let data = try #require(json.data(using: .utf8))
    let fixture = try decoder.decode(RawRepresentableFixture.self, from: data)

    // then
    #expect(fixture.normalEnum == .unknown)
    #expect(fixture.frozenEnum == .fallback)

    #if DEBUG
    #expect(fixture.$normalEnum.outcome == .valueWasNil)
    #expect(fixture.$frozenEnum.outcome == .valueWasNil)
    #expect(fixture.$normalEnum.error == nil)
    #expect(fixture.$frozenEnum.error == nil)
    #endif
  }

  @Test
  func `RawRepresentable with type mismatch`() throws {
    // given - enums expect String but we provide numbers
    let json = """
      {
        "normalEnum": 123,
        "frozenEnum": true
      }
      """

    // when
    let decoder = JSONDecoder()
    let data = try #require(json.data(using: .utf8))
    let fixture = try decoder.decode(RawRepresentableFixture.self, from: data)

    // then
    #expect(fixture.normalEnum == .unknown)
    #expect(fixture.frozenEnum == .fallback)

    #if DEBUG
    // Both should have type mismatch errors
    if case .recoveredFrom(let error, _) = fixture.$normalEnum.outcome {
      #expect(error is DecodingError)
      if case .typeMismatch = error as? DecodingError {
        // Expected
      } else {
        Issue.record("Expected typeMismatch DecodingError")
      }
    } else {
      Issue.record("Expected recoveredFrom outcome")
    }
    #endif
  }
}
