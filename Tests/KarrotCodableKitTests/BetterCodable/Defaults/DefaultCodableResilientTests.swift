//
//  DefaultCodableResilientTests.swift
//  KarrotCodableKitTests
//
//  Created by Elon on 4/9/25.
//

import Testing
import Foundation
@testable import KarrotCodableKit

@Suite("DefaultCodable Resilient Decoding")
struct DefaultCodableResilientTests {
  struct Fixture: Decodable {
    @DefaultZeroInt var intValue: Int
    @DefaultEmptyString var stringValue: String
    @DefaultFalse var boolValue: Bool
    @DefaultEmptyArray var arrayValue: [String]
    @DefaultEmptyDictionary var dictValue: [String: Int]
  }
  
  @Test("projected value provides error information for failed decoding")
  func testProjectedValueProvidesErrorInfo() throws {
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
    let data = json.data(using: .utf8)!
    let fixture = try decoder.decode(Fixture.self, from: data)
    
    // 기본 동작 검증 - 디코딩 실패 시 기본값 사용
    #expect(fixture.intValue == 0)
    #expect(fixture.stringValue == "")
    #expect(fixture.boolValue == false)
    #expect(fixture.arrayValue == [])
    #expect(fixture.dictValue == [:])
    
    #if DEBUG
    // projected value로 에러 정보 접근
    #expect(fixture.$intValue.error != nil)
    #expect(fixture.$stringValue.error != nil)
    #expect(fixture.$boolValue.error != nil)
    #expect(fixture.$arrayValue.error != nil)
    #expect(fixture.$dictValue.error != nil)
    
    // 에러 타입 확인
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
  
  @Test("missing keys use default values without error")
  func testMissingKeysUseDefaultValues() throws {
    let json = "{}"
    
    let decoder = JSONDecoder()
    let data = json.data(using: .utf8)!
    let fixture = try decoder.decode(Fixture.self, from: data)
    
    // 기본값 확인
    #expect(fixture.intValue == 0)
    #expect(fixture.stringValue == "")
    #expect(fixture.boolValue == false)
    #expect(fixture.arrayValue == [])
    #expect(fixture.dictValue == [:])
    
    #if DEBUG
    // 키가 없을 때는 에러가 없음 (기본 동작)
    #expect(fixture.$intValue.error == nil)
    #expect(fixture.$stringValue.error == nil)
    #expect(fixture.$boolValue.error == nil)
    #expect(fixture.$arrayValue.error == nil)
    #expect(fixture.$dictValue.error == nil)
    #endif
  }
  
  @Test("valid values decode successfully")
  func testValidValuesDecodeSuccessfully() throws {
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
    let data = json.data(using: .utf8)!
    let fixture = try decoder.decode(Fixture.self, from: data)
    
    // 정상 값 확인
    #expect(fixture.intValue == 42)
    #expect(fixture.stringValue == "hello")
    #expect(fixture.boolValue == true)
    #expect(fixture.arrayValue == ["a", "b", "c"])
    #expect(fixture.dictValue == ["key": 123])
    
    #if DEBUG
    // 성공적으로 디코딩된 경우 에러 없음
    #expect(fixture.$intValue.error == nil)
    #expect(fixture.$stringValue.error == nil)
    #expect(fixture.$boolValue.error == nil)
    #expect(fixture.$arrayValue.error == nil)
    #expect(fixture.$dictValue.error == nil)
    #endif
  }
  
  @Test("null values use default values")
  func testNullValuesUseDefaultValues() throws {
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
    let data = json.data(using: .utf8)!
    let fixture = try decoder.decode(Fixture.self, from: data)
    
    // null일 때 기본값 사용
    #expect(fixture.intValue == 0)
    #expect(fixture.stringValue == "")
    #expect(fixture.boolValue == false)
    #expect(fixture.arrayValue == [])
    #expect(fixture.dictValue == [:])
    
    #if DEBUG
    // null은 에러로 간주되지 않음
    #expect(fixture.$intValue.error == nil)
    #expect(fixture.$stringValue.error == nil)
    #expect(fixture.$boolValue.error == nil)
    #expect(fixture.$arrayValue.error == nil)
    #expect(fixture.$dictValue.error == nil)
    #endif
  }
  
  @Test("error reporting with JSONDecoder")
  func testErrorReportingWithDecoder() throws {
    let json = """
    {
      "intValue": "invalid",
      "stringValue": [],
      "boolValue": {}
    }
    """
    
    let decoder = JSONDecoder()
    let errorReporter = decoder.enableResilientDecodingErrorReporting()
    
    let data = json.data(using: .utf8)!
    let fixture = try decoder.decode(Fixture.self, from: data)
    
    let errorDigest = errorReporter.flushReportedErrors()
    
    #if DEBUG
    let digest = try #require(errorDigest)
    // 최소 3개의 에러가 리포트되어야 함
    #expect(digest.errors.count >= 3)
    print("Error digest: \(digest.debugDescription)")
    #else
    #expect(errorDigest == nil)
    #endif
  }
  
  @Test("LossyOptional behavior")
  func testLossyOptional() throws {
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
    let data = json.data(using: .utf8)!
    let fixture = try decoder.decode(OptionalFixture.self, from: data)
    
    // 디코딩 실패 시 nil
    print("URL value: \(String(describing: fixture.url))")
    print("Date value: \(String(describing: fixture.date))")
    print("Number value: \(String(describing: fixture.number))")
    #expect(fixture.url == nil)
    #expect(fixture.date == nil) 
    #expect(fixture.number == nil)
    
    #if DEBUG
    // 에러 정보 확인
    #expect(fixture.$url.error != nil)
    #expect(fixture.$date.error != nil)
    #expect(fixture.$number.error != nil)
    #endif
  }
  
  // MARK: - RawRepresentable Support Tests
  
  enum TestEnum: String, DefaultCodableStrategy {
    case first
    case second
    case unknown
    
    static var defaultValue: TestEnum { .unknown }
  }
  
  enum FrozenTestEnum: String, DefaultCodableStrategy {
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
  
  @Test("RawRepresentable with valid raw values")
  func testRawRepresentableValidValues() throws {
    // given
    let json = """
    {
      "normalEnum": "first",
      "frozenEnum": "alpha"
    }
    """
    
    // when
    let decoder = JSONDecoder()
    let data = json.data(using: .utf8)!
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
  
  @Test("RawRepresentable with unknown raw values (non-frozen)")
  func testRawRepresentableUnknownValueNonFrozen() throws {
    // given
    let json = """
    {
      "normalEnum": "third",
      "frozenEnum": "beta"
    }
    """
    
    // when
    let decoder = JSONDecoder()
    let data = json.data(using: .utf8)!
    let fixture = try decoder.decode(RawRepresentableFixture.self, from: data)
    
    // then
    #expect(fixture.normalEnum == .unknown) // Should use default value
    #expect(fixture.frozenEnum == .beta)
    
    #if DEBUG
    // Non-frozen enum should recover with UnknownNovelValueError
    if case .recoveredFrom(let error, _) = fixture.$normalEnum.outcome {
      #expect(error is UnknownNovelValueError)
      if let unknownError = error as? UnknownNovelValueError {
        #expect(unknownError.novelValue as? String == "third")
      }
    } else {
      Issue.record("Expected recoveredFrom outcome for non-frozen enum")
    }
    
    #expect(fixture.$frozenEnum.outcome == .decodedSuccessfully)
    #endif
  }
  
  @Test("RawRepresentable with unknown raw values (frozen)")
  func testRawRepresentableUnknownValueFrozen() throws {
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
    let data = json.data(using: .utf8)!
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
    
    // Error should be reported to error reporter
    let errorDigest = errorReporter.flushReportedErrors()
    #expect(errorDigest != nil)
    #endif
  }
  
  @Test("RawRepresentable with missing keys")
  func testRawRepresentableMissingKeys() throws {
    // given
    let json = "{}"
    
    // when
    let decoder = JSONDecoder()
    let data = json.data(using: .utf8)!
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
  
  @Test("RawRepresentable with null values")
  func testRawRepresentableNullValues() throws {
    // given
    let json = """
    {
      "normalEnum": null,
      "frozenEnum": null
    }
    """
    
    // when
    let decoder = JSONDecoder()
    let data = json.data(using: .utf8)!
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
  
  @Test("RawRepresentable with type mismatch")
  func testRawRepresentableTypeMismatch() throws {
    // given - enums expect String but we provide numbers
    let json = """
    {
      "normalEnum": 123,
      "frozenEnum": true
    }
    """
    
    // when
    let decoder = JSONDecoder()
    let data = json.data(using: .utf8)!
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