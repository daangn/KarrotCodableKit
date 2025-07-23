//
//  DataValueResilientTests.swift
//  KarrotCodableKitTests
//
//  Created by Elon on 4/9/25.
//

import Testing
import Foundation
@testable import KarrotCodableKit

@Suite("DataValue Resilient Decoding")
struct DataValueResilientTests {
  struct Fixture: Decodable {
    @DataValue<Base64Strategy> var base64Data: Data
    @DataValue<Base64Strategy> var anotherData: Data
  }
  
  @Test("projected value provides error information")
  func testProjectedValueProvidesErrorInfo() throws {
    let json = """
    {
      "base64Data": "SGVsbG8gV29ybGQ=",
      "anotherData": "VGVzdCBEYXRh"
    }
    """
    
    let decoder = JSONDecoder()
    let data = json.data(using: .utf8)!
    let fixture = try decoder.decode(Fixture.self, from: data)
    
    // 기본 동작 검증
    #expect(String(data: fixture.base64Data, encoding: .utf8) == "Hello World")
    #expect(String(data: fixture.anotherData, encoding: .utf8) == "Test Data")
    
    #if DEBUG
    // projected value로 성공 정보 접근
    #expect(fixture.$base64Data.outcome == .decodedSuccessfully)
    #expect(fixture.$anotherData.outcome == .decodedSuccessfully)
    #endif
  }
  
  @Test("invalid base64 format handling")
  func testInvalidBase64Format() throws {
    let json = """
    {
      "base64Data": "Invalid!@#$%^&*()Base64",
      "anotherData": "====="
    }
    """
    
    let decoder = JSONDecoder()
    let data = json.data(using: .utf8)!
    
    do {
      _ = try decoder.decode(Fixture.self, from: data)
      #expect(Bool(false), "Should have thrown")
    } catch {
      // 잘못된 Base64 형식은 디코딩 실패
    }
  }
  
  @Test("null values handling")
  func testNullValues() throws {
    let json = """
    {
      "base64Data": null,
      "anotherData": null
    }
    """
    
    let decoder = JSONDecoder()
    let data = json.data(using: .utf8)!
    
    do {
      _ = try decoder.decode(Fixture.self, from: data)
      #expect(Bool(false), "Should have thrown")
    } catch {
      // null 값은 Data로 변환할 수 없음
    }
  }
  
  @Test("error reporting with JSONDecoder")
  func testErrorReporting() throws {
    let json = """
    {
      "base64Data": 12345,
      "anotherData": {"key": "value"}
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