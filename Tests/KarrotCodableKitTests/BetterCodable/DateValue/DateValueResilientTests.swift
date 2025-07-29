//
//  DateValueResilientTests.swift
//  KarrotCodableKitTests
//
//  Created by Elon on 4/9/25.
//

import Testing
import Foundation
@testable import KarrotCodableKit

@Suite("DateValue Resilient Decoding")
struct DateValueResilientTests {
  struct Fixture: Decodable {
    @DateValue<ISO8601Strategy> var isoDate: Date
    @DateValue<RFC3339Strategy> var rfcDate: Date
    @DateValue<TimestampStrategy> var timestampDate: Date
  }
  
  @Test("projected value provides error information")
  func testProjectedValueProvidesErrorInfo() throws {
    let json = """
    {
      "isoDate": "2025-01-01T12:00:00Z",
      "rfcDate": "2025-01-01T12:00:00+00:00",
      "timestampDate": 1735728000
    }
    """
    
    let decoder = JSONDecoder()
    let data = try #require(json.data(using: .utf8))
    let fixture = try decoder.decode(Fixture.self, from: data)
    
    // Verify basic functionality
    #expect(fixture.isoDate.timeIntervalSince1970 > 0)
    #expect(fixture.rfcDate.timeIntervalSince1970 > 0)
    #expect(fixture.timestampDate.timeIntervalSince1970 > 0)
    
    #if DEBUG
    // Access success info via projected value
    #expect(fixture.$isoDate.outcome == .decodedSuccessfully)
    #expect(fixture.$rfcDate.outcome == .decodedSuccessfully)
    #expect(fixture.$timestampDate.outcome == .decodedSuccessfully)
    #endif
  }
  
  @Test("invalid date format handling")
  func testInvalidDateFormat() async throws {
    let json = """
    {
      "isoDate": "invalid-date",
      "rfcDate": "2025-01-01",
      "timestampDate": "not a number"
    }
    """
    
    let decoder = JSONDecoder()
    let data = try #require(json.data(using: .utf8))

    await confirmation(expectedCount: 1) { confirmation in
      do {
        _ = try decoder.decode(Fixture.self, from: data)
        Issue.record("Should have thrown")
      } catch {
        // Invalid Base64 format causes decoding failure
        confirmation()
      }
    }
  }
  
  @Test("null values handling")
  func testNullValues() async throws {
    let json = """
    {
      "isoDate": null,
      "rfcDate": null,
      "timestampDate": null
    }
    """
    
    let decoder = JSONDecoder()
    let data = try #require(json.data(using: .utf8))

    await confirmation(expectedCount: 1) { confirmation in
      do {
        _ = try decoder.decode(Fixture.self, from: data)
        Issue.record("Should have thrown")
      } catch {
        // null values cannot be converted to Data
        confirmation()
      }
    }
  }
  
  @Test("error reporting with JSONDecoder")
  func testErrorReporting() async throws {
    let json = """
    {
      "isoDate": 12345,
      "rfcDate": true,
      "timestampDate": ["array"]
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
        // Type mismatch causes decoding failure
        confirmation()
      }
    }
    
    let errorDigest = errorReporter.flushReportedErrors()
    
    let digest = try #require(errorDigest)
    #expect(digest.errors.count >= 1)
  }
}
