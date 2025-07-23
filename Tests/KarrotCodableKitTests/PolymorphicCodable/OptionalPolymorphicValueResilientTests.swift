import Foundation
import Testing
@testable import KarrotCodableKit

@Suite("OptionalPolymorphicValue Resilient Decoding")
struct OptionalPolymorphicValueResilientTests {
  struct Fixture: Decodable {
    @DummyNotice.OptionalPolymorphic var notice: DummyNotice?
  }
  
  @Test("nil 값 디코딩 시 outcome이 valueWasNil이어야 함")
  func testNilValue() throws {
    // Given
    let json = """
    {
      "notice": null
    }
    """
    
    // When
    let data = json.data(using: .utf8)!
    let result = try JSONDecoder().decode(Fixture.self, from: data)
    
    // Then
    #expect(result.notice == nil)
    #if DEBUG
    #expect(result.$notice.outcome == .valueWasNil)
    #expect(result.$notice.error == nil)
    #endif
  }
  
  @Test("키가 없을 때 outcome이 keyNotFound여야 함")
  func testMissingKey() throws {
    // Given
    let json = """
    {}
    """
    
    // When
    let data = json.data(using: .utf8)!
    let result = try JSONDecoder().decode(Fixture.self, from: data)
    
    // Then
    #expect(result.notice == nil)
    #if DEBUG
    #expect(result.$notice.outcome == .keyNotFound)
    #expect(result.$notice.error == nil)
    #endif
  }
  
  @Test("정상적인 값 디코딩 시 outcome이 decodedSuccessfully여야 함")
  func testSuccessfulDecoding() throws {
    // Given
    let json = """
    {
      "notice": {
        "__typename": "callout",
        "type": "callout",
        "title": "Test Title",
        "description": "Hello",
        "icon": "icon.png"
      }
    }
    """
    
    // When
    let data = json.data(using: .utf8)!
    let result = try JSONDecoder().decode(Fixture.self, from: data)
    
    // Then
    #expect(result.notice is DummyCallout)
    if let callout = result.notice as? DummyCallout {
      #expect(callout.type == .callout)
      #expect(callout.title == "Test Title")
      #expect(callout.description == "Hello")
    }
    
    #if DEBUG
    #expect(result.$notice.outcome == .decodedSuccessfully)
    #expect(result.$notice.error == nil)
    #endif
  }
  
  @Test("알 수 없는 타입일 때 에러를 throw해야 함")
  func testUnknownTypeThrowsError() throws {
    // Given
    let json = """
    {
      "notice": {
        "__typename": "unknown",
        "id": "1"
      }
    }
    """
    
    // When/Then
    let data = json.data(using: .utf8)!
    #expect(throws: Error.self) {
      _ = try JSONDecoder().decode(Fixture.self, from: data)
    }
  }
  
  @Test("잘못된 JSON 형식일 때 에러를 throw해야 함")
  func testInvalidJSONThrowsError() throws {
    // Given
    let json = """
    {
      "notice": "invalid"
    }
    """
    
    // When/Then
    let data = json.data(using: .utf8)!
    #expect(throws: Error.self) {
      _ = try JSONDecoder().decode(Fixture.self, from: data)
    }
  }
  
}