import Foundation
import Testing
@testable import KarrotCodableKit

@Suite("PolymorphicArrayValue Resilient Decoding")
struct PolymorphicArrayValueResilientTests {
  struct Fixture: Decodable {
    @DummyNotice.PolymorphicArray var notices: [DummyNotice]
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
        },
        {
          "type": "dismissible-callout",
          "title": "Third",
          "description": "Third callout",
          "key": "dismiss-key"
        }
      ]
    }
    """
    
    // When
    let data = json.data(using: .utf8)!
    let result = try JSONDecoder().decode(Fixture.self, from: data)
    
    // Then
    #expect(result.notices.count == 3)
    #expect(result.notices[0] is DummyCallout)
    #expect(result.notices[1] is DummyActionableCallout)
    #expect(result.notices[2] is DummyDismissibleCallout)
    
    #if DEBUG
    #expect(result.$notices.outcome == .decodedSuccessfully)
    #expect(result.$notices.error == nil)
    #endif
  }
  
  @Test("배열 요소 중 하나라도 디코딩 실패 시 전체가 실패해야 함")
  func testArrayWithInvalidElement() throws {
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
    
    // When/Then
    let data = json.data(using: .utf8)!
    #expect(throws: Error.self) {
      _ = try JSONDecoder().decode(Fixture.self, from: data)
    }
  }
  
  @Test("키가 없을 때 에러를 throw해야 함")
  func testMissingKey() throws {
    // Given
    let json = """
    {}
    """
    
    // When/Then
    let data = json.data(using: .utf8)!
    #expect(throws: Error.self) {
      _ = try JSONDecoder().decode(Fixture.self, from: data)
    }
  }
  
  @Test("잘못된 타입일 때 에러를 throw해야 함")
  func testInvalidType() throws {
    // Given
    let json = """
    {
      "notices": "not an array"
    }
    """
    
    // When/Then
    let data = json.data(using: .utf8)!
    #expect(throws: Error.self) {
      _ = try JSONDecoder().decode(Fixture.self, from: data)
    }
  }
  
  @Test("배열 요소의 에러가 리포트되어야 함")
  func testArrayElementErrorReported() throws {
    // Given
    let json = """
    {
      "notices": [
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
    
    // Then
    #expect(throws: Error.self) {
      _ = try decoder.decode(Fixture.self, from: data)
    }
    
    // PolymorphicValue가 에러를 리포트하므로 에러 다이제스트가 있어야 함
    let errorDigest = errorReporter.flushReportedErrors()
    #expect(errorDigest != nil)
    if let digest = errorDigest {
      let errors = digest.errors
      #expect(errors.count >= 1)
    }
  }
}