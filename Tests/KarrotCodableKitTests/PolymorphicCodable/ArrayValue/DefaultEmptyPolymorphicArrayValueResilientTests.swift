import Foundation
import Testing
@testable import KarrotCodableKit

@Suite("DefaultEmptyPolymorphicArrayValue Resilient Decoding")
struct DefaultEmptyPolymorphicArrayValueResilientTests {
  struct Fixture: Decodable {
    @DummyNotice.DefaultEmptyPolymorphicArray var notices: [DummyNotice]
  }
  
  @Test("빈 배열 디코딩 시 outcome이 decodedSuccessfully여야 함")
  func testEmptyArray() throws {
    // Given
    let json = """
    {
      "notices": []
    }
    """
    
    // When
    let data = json.data(using: .utf8)!
    let result = try JSONDecoder().decode(Fixture.self, from: data)
    
    // Then
    #expect(result.notices.isEmpty)
    #if DEBUG
    #expect(result.$notices.outcome == .decodedSuccessfully)
    #expect(result.$notices.error == nil)
    #endif
  }
  
  @Test("정상적인 배열 디코딩 시 outcome이 decodedSuccessfully여야 함")
  func testSuccessfulArrayDecoding() throws {
    // Given
    let json = """
    {
      "notices": [
        {
          "type": "callout",
          "title": "First",
          "description": "First callout",
          "icon": "icon1.png"
        },
        {
          "type": "actionable-callout",
          "title": "Second",
          "description": "Second callout",
          "action": "https://example.com"
        }
      ]
    }
    """
    
    // When
    let data = json.data(using: .utf8)!
    let result = try JSONDecoder().decode(Fixture.self, from: data)
    
    // Then
    #expect(result.notices.count == 2)
    #expect(result.notices[0] is DummyCallout)
    #expect(result.notices[1] is DummyActionableCallout)
    
    #if DEBUG
    #expect(result.$notices.outcome == .decodedSuccessfully)
    #expect(result.$notices.error == nil)
    #endif
  }
  
  @Test("배열에 잘못된 요소가 하나라도 있으면 빈 배열을 반환해야 함")
  func testArrayWithAnyInvalidElement() throws {
    // Given
    let json = """
    {
      "notices": [
        {
          "type": "callout",
          "title": "Valid",
          "description": "Valid callout",
          "icon": "icon.png"
        },
        {
          "type": "invalid-type"
        }
      ]
    }
    """
    
    // When
    let data = json.data(using: .utf8)!
    let result = try JSONDecoder().decode(Fixture.self, from: data)
    
    // Then
    #expect(result.notices.isEmpty)
    
    #if DEBUG
    if case .recoveredFrom(_, _) = result.$notices.outcome {
      // Expected
    } else {
      Issue.record("Expected recoveredFrom outcome")
    }
    #expect(result.$notices.error != nil)
    #endif
  }
  
  @Test("키가 없을 때 빈 배열을 반환해야 함")
  func testMissingKey() throws {
    // Given
    let json = """
    {}
    """
    
    // When
    let data = json.data(using: .utf8)!
    let result = try JSONDecoder().decode(Fixture.self, from: data)
    
    // Then
    #expect(result.notices.isEmpty)
    #if DEBUG
    #expect(result.$notices.outcome == .keyNotFound)
    #expect(result.$notices.error == nil)
    #endif
  }
  
  @Test("null 값일 때 빈 배열을 반환해야 함")
  func testNullValue() throws {
    // Given
    let json = """
    {
      "notices": null
    }
    """
    
    // When
    let data = json.data(using: .utf8)!
    let result = try JSONDecoder().decode(Fixture.self, from: data)
    
    // Then
    #expect(result.notices.isEmpty)
    #if DEBUG
    #expect(result.$notices.outcome == .valueWasNil)
    #expect(result.$notices.error == nil)
    #endif
  }
  
  @Test("잘못된 타입일 때 빈 배열을 반환해야 함")
  func testInvalidType() throws {
    // Given
    let json = """
    {
      "notices": "not an array"
    }
    """
    
    // When
    let data = json.data(using: .utf8)!
    let result = try JSONDecoder().decode(Fixture.self, from: data)
    
    // Then
    #expect(result.notices.isEmpty)
    #if DEBUG
    if case .recoveredFrom(_, _) = result.$notices.outcome {
      // Expected
    } else {
      Issue.record("Expected recoveredFrom outcome")
    }
    #expect(result.$notices.error != nil)
    #endif
  }
  
  @Test("에러 리포터가 호출되어야 함")
  func testErrorReporting() throws {
    // Given
    let json = """
    {
      "notices": [
        {
          "type": "callout",
          "title": "Valid",
          "description": "Valid callout",
          "icon": "icon.png"
        },
        {
          "type": "invalid-type"
        }
      ]
    }
    """
    
    // When
    let data = json.data(using: .utf8)!
    let decoder = JSONDecoder()
    let errorReporter = decoder.enableResilientDecodingErrorReporting()
    
    let result = try decoder.decode(Fixture.self, from: data)
    
    // Then
    #expect(result.notices.isEmpty)
    
    let errorDigest = errorReporter.flushReportedErrors()
    #expect(errorDigest != nil)
    if let digest = errorDigest {
      let errors = digest.errors
      #expect(errors.count >= 1)
    }
  }
}