//
//  PolymorphicValueResilientTests.swift
//  KarrotCodableKitTests
//
//  Created by Elon on 4/9/25.
//

import Testing
import Foundation
@testable import KarrotCodableKit

@Suite("PolymorphicValue Resilient Decoding")
struct PolymorphicValueResilientTests {
  struct Fixture: Decodable {
    @DummyNotice.Polymorphic var notice: DummyNotice
  }
  
  @Test("projected value provides error information")
  func testProjectedValueProvidesErrorInfo() throws {
    let json = """
    {
      "notice": {
        "type": "callout",
        "description": "test description",
        "icon": "test_icon"
      }
    }
    """
    
    let decoder = JSONDecoder()
    let data = json.data(using: .utf8)!
    let fixture = try decoder.decode(Fixture.self, from: data)
    
    // 기본 동작 검증
    #expect(fixture.notice.description == "test description")
    #expect((fixture.notice as? DummyCallout)?.icon == "test_icon")
    
    #if DEBUG
    // projected value로 성공 정보 접근
    #expect(fixture.$notice.outcome == .decodedSuccessfully)
    #endif
  }
  
  @Test("unknown type handling with fallback")
  func testUnknownType() throws {
    let json = """
    {
      "notice": {
        "type": "unknown-type",
        "description": "test description"
      }
    }
    """
    
    let decoder = JSONDecoder()
    let data = json.data(using: .utf8)!
    
    // DummyNotice에는 fallback type이 설정되어 있어서 성공해야 함
    let fixture = try decoder.decode(Fixture.self, from: data)
    
    // fallback type으로 디코딩되었는지 검증
    #expect(fixture.notice is DummyUndefinedCallout)
    #expect(fixture.notice.description == "test description")
    
    #if DEBUG
    // projected value로 성공 정보 접근
    #expect(fixture.$notice.outcome == .decodedSuccessfully)
    #endif
  }
  
  @Test("null values handling")
  func testNullValues() throws {
    let json = """
    {
      "notice": null
    }
    """
    
    let decoder = JSONDecoder()
    let data = json.data(using: .utf8)!
    
    do {
      _ = try decoder.decode(Fixture.self, from: data)
      #expect(Bool(false), "Should have thrown")
    } catch {
      // null 값은 처리할 수 없음
    }
  }
  
  @Test("error reporting with JSONDecoder")
  func testErrorReporting() throws {
    let json = """
    {
      "notice": {
        "type": "dismissible-callout",
        "description": "test",
        "title": "title",
        "key": 123
      }
    }
    """
    
    let decoder = JSONDecoder()
    let errorReporter = decoder.enableResilientDecodingErrorReporting()
    
    let data = json.data(using: .utf8)!
    
    do {
      _ = try decoder.decode(Fixture.self, from: data)
      #expect(Bool(false), "Should have thrown")
    } catch {
      // 타입 불일치로 디코딩 실패 (key는 String이어야 함)
    }
    
    let errorDigest = errorReporter.flushReportedErrors()
    
    #if DEBUG
    // 에러가 리포트되었는지 확인
    #expect(errorDigest != nil)
    if let digest = errorDigest {
      #expect(digest.errors.count >= 1)
      print("Error digest: \(digest.debugDescription)")
    }
    #else
    #expect(errorDigest == nil)
    #endif
  }
}