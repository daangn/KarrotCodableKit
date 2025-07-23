//
//  DateValueResilientTests.swift
//  KarrotCodableKitTests
//
//  Created by Elon on 4/9/25.
//

import Testing
import Foundation
@testable import KarrotCodableKit

@Suite("DateValue Resilient Decoding")
struct DateValueResilientTests {
  struct Fixture: Decodable {
    @DateValue<ISO8601Strategy> var isoDate: Date
    @DateValue<RFC3339Strategy> var rfcDate: Date
    @DateValue<TimestampStrategy> var timestampDate: Date
  }
  
  @Test("projected value provides error information")
  func testProjectedValueProvidesErrorInfo() throws {
    let json = """
    {
      "isoDate": "2025-01-01T12:00:00Z",
      "rfcDate": "2025-01-01T12:00:00+00:00",
      "timestampDate": 1735728000
    }
    """
    
    let decoder = JSONDecoder()
    let data = json.data(using: .utf8)!
    let fixture = try decoder.decode(Fixture.self, from: data)
    
    // 기본 동작 검증
    #expect(fixture.isoDate.timeIntervalSince1970 > 0)
    #expect(fixture.rfcDate.timeIntervalSince1970 > 0)
    #expect(fixture.timestampDate.timeIntervalSince1970 > 0)
    
    #if DEBUG
    // projected value로 성공 정보 접근
    #expect(fixture.$isoDate.outcome == .decodedSuccessfully)
    #expect(fixture.$rfcDate.outcome == .decodedSuccessfully)
    #expect(fixture.$timestampDate.outcome == .decodedSuccessfully)
    #endif
  }
  
  @Test("invalid date format handling")
  func testInvalidDateFormat() throws {
    let json = """
    {
      "isoDate": "invalid-date",
      "rfcDate": "2025-01-01",
      "timestampDate": "not a number"
    }
    """
    
    let decoder = JSONDecoder()
    let data = json.data(using: .utf8)!
    
    do {
      _ = try decoder.decode(Fixture.self, from: data)
      #expect(Bool(false), "Should have thrown")
    } catch {
      // 잘못된 형식은 디코딩 실패
    }
  }
  
  @Test("null values handling")
  func testNullValues() throws {
    let json = """
    {
      "isoDate": null,
      "rfcDate": null,
      "timestampDate": null
    }
    """
    
    let decoder = JSONDecoder()
    let data = json.data(using: .utf8)!
    
    do {
      _ = try decoder.decode(Fixture.self, from: data)
      #expect(Bool(false), "Should have thrown")
    } catch {
      // null 값은 Date로 변환할 수 없음
    }
  }
  
  @Test("error reporting with JSONDecoder")
  func testErrorReporting() throws {
    let json = """
    {
      "isoDate": 12345,
      "rfcDate": true,
      "timestampDate": ["array"]
    }
    """
    
    let decoder = JSONDecoder()
    let errorReporter = decoder.enableResilientDecodingErrorReporting()
    
    let data = json.data(using: .utf8)!
    
    do {
      _ = try decoder.decode(Fixture.self, from: data)
      #expect(Bool(false), "Should have thrown")
    } catch {
      // 타입 불일치로 디코딩 실패
    }
    
    let errorDigest = errorReporter.flushReportedErrors()
    
    #if DEBUG
    // 에러가 리포트되었는지 확인
    #expect(errorDigest != nil)
    if let digest = errorDigest {
      #expect(digest.errors.count >= 1)  // 최소 1개 이상의 에러
      print("Error digest: \(digest.debugDescription)")
    }
    #else
    #expect(errorDigest == nil)
    #endif
  }
}