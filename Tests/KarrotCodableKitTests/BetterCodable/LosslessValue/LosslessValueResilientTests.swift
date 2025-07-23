//
//  LosslessValueResilientTests.swift
//  KarrotCodableKitTests
//
//  Created by Elon on 4/9/25.
//

import Testing
import Foundation
@testable import KarrotCodableKit

@Suite("LosslessValue Resilient Decoding")
struct LosslessValueResilientTests {
  struct Fixture: Decodable {
    @LosslessValue var stringValue: String
    @LosslessValue var intValue: Int
    @LosslessValue var boolValue: Bool
    @LosslessValue var doubleValue: Double
  }
  
  @Test("projected value provides error information")
  func testProjectedValueProvidesErrorInfo() throws {
    let json = """
    {
      "stringValue": 123,
      "intValue": "456",
      "boolValue": "true",
      "doubleValue": "3.14"
    }
    """
    
    let decoder = JSONDecoder()
    let data = json.data(using: .utf8)!
    let fixture = try decoder.decode(Fixture.self, from: data)
    
    // 기본 동작 검증 - 모든 값이 변환됨
    #expect(fixture.stringValue == "123")
    #expect(fixture.intValue == 456)
    #expect(fixture.boolValue == true)
    #expect(fixture.doubleValue == 3.14)
    
    #if DEBUG
    // projected value로 성공 정보 접근
    #expect(fixture.$stringValue.outcome == .decodedSuccessfully)
    #expect(fixture.$intValue.outcome == .decodedSuccessfully)
    #expect(fixture.$boolValue.outcome == .decodedSuccessfully)
    #expect(fixture.$doubleValue.outcome == .decodedSuccessfully)
    #endif
  }
  
  @Test("null values handling")
  func testNullValues() throws {
    let json = """
    {
      "stringValue": null,
      "intValue": null,
      "boolValue": null,
      "doubleValue": null
    }
    """
    
    let decoder = JSONDecoder()
    let data = json.data(using: .utf8)!
    
    do {
      _ = try decoder.decode(Fixture.self, from: data)
      #expect(Bool(false), "Should have thrown")
    } catch {
      // null 값은 LosslessValue에서 처리할 수 없음
    }
  }
  
  @Test("unconvertible values")
  func testUnconvertibleValues() throws {
    let json = """
    {
      "stringValue": {"key": "value"},
      "intValue": [1, 2, 3],
      "boolValue": {"nested": true},
      "doubleValue": ["array"]
    }
    """
    
    let decoder = JSONDecoder()
    let data = json.data(using: .utf8)!
    
    do {
      _ = try decoder.decode(Fixture.self, from: data)
      #expect(Bool(false), "Should have thrown")
    } catch {
      // 복잡한 타입은 변환할 수 없음
    }
  }
  
  @Test("error reporting with JSONDecoder")
  func testErrorReporting() throws {
    let json = """
    {
      "stringValue": {"key": "value"},
      "intValue": [1, 2, 3],
      "boolValue": {"nested": true},
      "doubleValue": ["array"]
    }
    """
    
    let decoder = JSONDecoder()
    let errorReporter = decoder.enableResilientDecodingErrorReporting()
    
    let data = json.data(using: .utf8)!
    
    do {
      _ = try decoder.decode(Fixture.self, from: data)
      #expect(Bool(false), "Should have thrown")
    } catch {
      // 복잡한 타입은 변환할 수 없음
    }
    
    let errorDigest = errorReporter.flushReportedErrors()
    
    #if DEBUG
    // 에러가 리포트되었는지 확인
    #expect(errorDigest != nil)
    if let digest = errorDigest {
      #expect(digest.errors.count >= 1)  // 최소 1개 이상의 에러 발생
      print("Error digest: \(digest.debugDescription)")
    }
    #else
    #expect(errorDigest == nil)
    #endif
  }
}