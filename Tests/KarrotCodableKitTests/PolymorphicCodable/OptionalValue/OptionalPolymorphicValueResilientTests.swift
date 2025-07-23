import Foundation
import Testing
@testable import KarrotCodableKit

@Suite("OptionalPolymorphicValue Resilient Decoding")
struct OptionalPolymorphicValueResilientTests {
  struct Fixture: Decodable {
    @DummyNotice.OptionalPolymorphic var notice: DummyNotice?
  }
  
  @Test("Outcome should be valueWasNil when decoding nil value")
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
  
  @Test("Outcome should be keyNotFound when key is missing")
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
  
  @Test("Outcome should be decodedSuccessfully for successful decoding")
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
  
  @Test("Should throw error for unknown type")
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
  
  @Test("Should throw error for invalid JSON format")
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