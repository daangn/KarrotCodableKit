import Foundation
import Testing
@testable import KarrotCodableKit

@Suite("LossyOptionalPolymorphicValue Resilient Decoding")
struct LossyOptionalPolymorphicValueResilientTests {
  struct Fixture: Decodable {
    @DummyNotice.LossyOptionalPolymorphic var notice: DummyNotice?
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
  
  @Test("Should return nil and record error for unknown type")
  func testUnknownTypeReturnsNil() throws {
    // Given
    let json = """
    {
      "notice": {
        "type": "unknown-type"
      }
    }
    """
    
    // When
    let data = json.data(using: .utf8)!
    let result = try JSONDecoder().decode(Fixture.self, from: data)
    
    // Then
    #expect(result.notice == nil)
    
    #if DEBUG
    if case .recoveredFrom(let error, _) = result.$notice.outcome {
      #expect(error is DecodingError)
    } else {
      Issue.record("Expected recoveredFrom outcome")
    }
    #expect(result.$notice.error != nil)
    #endif
  }
  
  @Test("Should return nil and record error for invalid JSON format")
  func testInvalidJSONReturnsNil() throws {
    // Given
    let json = """
    {
      "notice": "invalid"
    }
    """
    
    // When
    let data = json.data(using: .utf8)!
    let result = try JSONDecoder().decode(Fixture.self, from: data)
    
    // Then
    #expect(result.notice == nil)
    
    #if DEBUG
    if case .recoveredFrom(let error, _) = result.$notice.outcome {
      #expect(error is DecodingError)
    } else {
      Issue.record("Expected recoveredFrom outcome")
    }
    #expect(result.$notice.error != nil)
    #endif
  }
  
  @Test("Error reporter should be called")
  func testErrorReporterCalled() throws {
    // Given
    let json = """
    {
      "notice": {
        "type": "unknown-type"
      }
    }
    """
    
    // When
    let data = json.data(using: .utf8)!
    let decoder = JSONDecoder()
    let errorReporter = decoder.enableResilientDecodingErrorReporting()
    
    let result = try decoder.decode(Fixture.self, from: data)
 
    // Then
    #expect(result.notice == nil)
    
    let errorDigest = errorReporter.flushReportedErrors()
    #expect(errorDigest != nil)
    if let digest = errorDigest {
      let errors = digest.errors
      #expect(errors.count >= 1)
      #expect(errors.first is DecodingError)
    }
  }
}