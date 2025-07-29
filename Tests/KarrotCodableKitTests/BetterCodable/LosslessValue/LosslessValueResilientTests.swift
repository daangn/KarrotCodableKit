//
//  LosslessValueResilientTests.swift
//  KarrotCodableKitTests
//
//  Created by Elon on 4/9/25.
//

import Testing
import Foundation
@testable import KarrotCodableKit

@Suite("LosslessValue Resilient Decoding")
struct LosslessValueResilientTests {
  struct Fixture: Decodable {
    @LosslessValue var stringValue: String
    @LosslessValue var intValue: Int
    @LosslessValue var boolValue: Bool
    @LosslessValue var doubleValue: Double
  }
  
  @Test("projected value provides error information")
  func testProjectedValueProvidesErrorInfo() throws {
    let json = """
    {
      "stringValue": 123,
      "intValue": "456",
      "boolValue": "true",
      "doubleValue": "3.14"
    }
    """
    
    let decoder = JSONDecoder()
    let data = try #require(json.data(using: .utf8))
    let fixture = try decoder.decode(Fixture.self, from: data)
    
    // Verify default behavior - all values converted
    #expect(fixture.stringValue == "123")
    #expect(fixture.intValue == 456)
    #expect(fixture.boolValue == true)
    #expect(fixture.doubleValue == 3.14)
    
    #if DEBUG
    // Access success info through projected value
    #expect(fixture.$stringValue.outcome == .decodedSuccessfully)
    #expect(fixture.$intValue.outcome == .decodedSuccessfully)
    #expect(fixture.$boolValue.outcome == .decodedSuccessfully)
    #expect(fixture.$doubleValue.outcome == .decodedSuccessfully)
    #endif
  }
  
  @Test("null values handling")
  func testNullValues() async throws {
    let json = """
    {
      "stringValue": null,
      "intValue": null,
      "boolValue": null,
      "doubleValue": null
    }
    """
    
    let decoder = JSONDecoder()
    let data = try #require(json.data(using: .utf8))
    
    await confirmation(expectedCount: 1) { confirmation in
      do {
        _ = try decoder.decode(Fixture.self, from: data)
        Issue.record("Should have thrown")
      } catch {
        // null values cannot be handled by LosslessValue
        confirmation()
      }
    }
  }
  
  @Test("unconvertible values")
  func testUnconvertibleValues() async throws {
    let json = """
    {
      "stringValue": {"key": "value"},
      "intValue": [1, 2, 3],
      "boolValue": {"nested": true},
      "doubleValue": ["array"]
    }
    """
    
    let decoder = JSONDecoder()
    let data = try #require(json.data(using: .utf8))
    
    await confirmation(expectedCount: 1) { confirmation in
      do {
        _ = try decoder.decode(Fixture.self, from: data)
        Issue.record("Should have thrown")
      } catch {
        // Complex types cannot be converted
        confirmation()
      }
    }
  }
  
  @Test("error reporting with JSONDecoder")
  func testErrorReporting() async throws {
    let json = """
    {
      "stringValue": {"key": "value"},
      "intValue": [1, 2, 3],
      "boolValue": {"nested": true},
      "doubleValue": ["array"]
    }
    """
    
    let decoder = JSONDecoder()
    let errorReporter = decoder.enableResilientDecodingErrorReporting()
    
    let data = try #require(json.data(using: .utf8))
    
    await confirmation(expectedCount: 1) { confirmation in
      do {
        _ = try decoder.decode(Fixture.self, from: data)
        Issue.record("Should have thrown")
      } catch {
        // Complex types cannot be converted
        confirmation()
      }
    }
    
    let errorDigest = errorReporter.flushReportedErrors()
    
    // Check if errors were reported
    let digest = try #require(errorDigest)
    #expect(digest.errors.count >= 1)  // At least 1 error occurred
  }
}
