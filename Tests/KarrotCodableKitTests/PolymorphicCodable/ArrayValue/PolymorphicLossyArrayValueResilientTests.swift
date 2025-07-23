import Foundation
import Testing
@testable import KarrotCodableKit

@Suite("PolymorphicLossyArrayValue Resilient Decoding")
struct PolymorphicLossyArrayValueResilientTests {
  struct Fixture: Decodable {
    @DummyNotice.PolymorphicLossyArray var notices: [DummyNotice]
  }
  
  @Test("Empty array decoding should have decodedSuccessfully outcome")
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
  
  @Test("Successful array decoding should have all elements succeed")
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
  
  @Test("Should decode only valid elements when array has invalid elements")
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
    
    // Only first and third elements succeed
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
  
  @Test("Should return empty array when key is missing")
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
  
  @Test("Should return empty array for invalid type")
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
  
  @Test("Error reporter should be called partially")
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