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
    // given
    let json = """
    {
      "notice": {
        "type": "callout",
        "description": "test description",
        "icon": "test_icon"
      }
    }
    """
    
    // when
    let decoder = JSONDecoder()
    let data = json.data(using: .utf8)!
    let fixture = try decoder.decode(Fixture.self, from: data)
    
    // then
    // Verify basic behavior
    #expect(fixture.notice.description == "test description")
    #expect((fixture.notice as? DummyCallout)?.icon == "test_icon")
    
    #if DEBUG
    // Access success info via projected value
    #expect(fixture.$notice.outcome == .decodedSuccessfully)
    #endif
  }
  
  @Test("unknown type handling with fallback")
  func testUnknownType() throws {
    // given
    let json = """
    {
      "notice": {
        "type": "unknown-type",
        "description": "test description"
      }
    }
    """
    
    // when
    let decoder = JSONDecoder()
    let data = json.data(using: .utf8)!
    
    // DummyNotice has fallback type configured so should succeed
    let fixture = try decoder.decode(Fixture.self, from: data)
    
    // then
    // Verify decoded as fallback type
    #expect(fixture.notice is DummyUndefinedCallout)
    #expect(fixture.notice.description == "test description")
    
    #if DEBUG
    // Access success info via projected value
    #expect(fixture.$notice.outcome == .decodedSuccessfully)
    #endif
  }
  
  @Test("null values handling")
  func testNullValues() throws {
    // given
    let json = """
    {
      "notice": null
    }
    """
    
    // when / then
    let decoder = JSONDecoder()
    let data = json.data(using: .utf8)!
    
    do {
      _ = try decoder.decode(Fixture.self, from: data)
      #expect(Bool(false), "Should have thrown")
    } catch {
      // Cannot handle null values
    }
  }
  
  @Test("error reporting with JSONDecoder")
  func testErrorReporting() throws {
    // given
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
    
    // when
    let decoder = JSONDecoder()
    let errorReporter = decoder.enableResilientDecodingErrorReporting()
    
    let data = json.data(using: .utf8)!
    
    // then
    do {
      _ = try decoder.decode(Fixture.self, from: data)
      #expect(Bool(false), "Should have thrown")
    } catch {
      // Decoding failed due to type mismatch (key should be String)
    }
    
    // then
    let errorDigest = errorReporter.flushReportedErrors()
    
    #if DEBUG
    // Check if error was reported
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