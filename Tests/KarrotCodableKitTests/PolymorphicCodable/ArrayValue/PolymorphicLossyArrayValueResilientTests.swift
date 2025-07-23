import Foundation
import Testing
@testable import KarrotCodableKit

@Suite("PolymorphicLossyArrayValue Resilient Decoding")
struct PolymorphicLossyArrayValueResilientTests {
  struct Fixture: Decodable {
    @DummyNotice.PolymorphicLossyArray var notices: [DummyNotice]
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
    #expect(result.$notices.results.isEmpty)
    #endif
  }
  
  @Test("정상적인 배열 디코딩 시 모든 요소가 성공해야 함")
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
    #expect(result.$notices.results.count == 2)
    #expect(result.$notices.results.allSatisfy { result in
      if case .success = result { return true }
      return false
    })
    #endif
  }
  
  @Test("배열에 잘못된 요소가 있을 때 유효한 요소만 디코딩해야 함")
  func testArrayWithInvalidElements() throws {
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
        },
        {
          "type": "dismissible-callout",
          "title": "Also Valid",
          "description": "Another valid callout",
          "key": "dismiss-key"
        },
        "not-an-object",
        null,
        123
      ]
    }
    """
    
    // When
    let data = json.data(using: .utf8)!
    let result = try JSONDecoder().decode(Fixture.self, from: data)
    
    // Then
    #expect(result.notices.count == 2)
    #expect(result.notices[0] is DummyCallout)
    #expect(result.notices[1] is DummyDismissibleCallout)
    
    #if DEBUG
    #expect(result.$notices.outcome == .decodedSuccessfully)
    #expect(result.$notices.results.count == 6)
    
    // 첫 번째와 세 번째 요소만 성공
    if case .success = result.$notices.results[0] {} else {
      Issue.record("Expected success at index 0")
    }
    if case .failure = result.$notices.results[1] {} else {
      Issue.record("Expected failure at index 1")
    }
    if case .success = result.$notices.results[2] {} else {
      Issue.record("Expected success at index 2")
    }
    if case .failure = result.$notices.results[3] {} else {
      Issue.record("Expected failure at index 3")
    }
    if case .failure = result.$notices.results[4] {} else {
      Issue.record("Expected failure at index 4")
    }
    if case .failure = result.$notices.results[5] {} else {
      Issue.record("Expected failure at index 5")
    }
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
    #expect(result.$notices.results.isEmpty)
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
    #expect(result.$notices.results.isEmpty)
    #endif
  }
  
  @Test("에러 리포터가 부분적으로 호출되어야 함")
  func testPartialErrorReporting() throws {
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
    #expect(result.notices.count == 1)
    
    let errorDigest = errorReporter.flushReportedErrors()
    #expect(errorDigest != nil)
    if let digest = errorDigest {
      let errors = digest.errors
      #expect(errors.count >= 1)
    }
  }
}