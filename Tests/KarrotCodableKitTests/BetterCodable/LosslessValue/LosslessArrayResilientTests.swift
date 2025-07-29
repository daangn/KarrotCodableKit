//
//  LosslessArrayResilientTests.swift
//  KarrotCodableKitTests
//
//  Created by Elon on 4/9/25.
//

import Testing
import Foundation
@testable import KarrotCodableKit

@Suite("LosslessArray Resilient Decoding")
struct LosslessArrayResilientTests {
  struct Fixture: Decodable {
    @LosslessArray var stringArray: [String]
    @LosslessArray var intArray: [Int]
    @LosslessArray var doubleArray: [Double]
    
    struct NestedObject: Decodable, Equatable, LosslessStringConvertible {
      let id: Int
      let name: String
      
      init?(_ description: String) {
        return nil // Not convertible from string
      }
      
      var description: String {
        "NestedObject(id: \(id), name: \(name))"
      }
    }
    @LosslessArray var objectArray: [String] // Objects cannot be converted to String
  }
  
  @Test("projected value provides error information for each failed element")
  func testProjectedValueProvidesErrorInfo() throws {
    let json = """
    {
      "stringArray": [1, "two", true, null, 5.5],
      "intArray": ["invalid", 2, 3.14, 4, true],
      "doubleArray": [1.5, "2.5", 3, null, "invalid"],
      "objectArray": [{"id": 1, "name": "test"}, "string"]
    }
    """
    
    let decoder = JSONDecoder()
    let data = try #require(json.data(using: .utf8))
    let fixture = try decoder.decode(Fixture.self, from: data)
    
    // Verify default behavior - only convertible values included
    #expect(fixture.stringArray == ["1", "two", "true", "5.5"])
    #expect(fixture.intArray == [2, 4])
    #expect(fixture.doubleArray == [1.5, 2.5, 3.0])  // 1.5, "2.5"->2.5, 3->3.0
    #expect(fixture.objectArray == ["string"])
    
    #if DEBUG
    // Access error info through projected value
    #expect(fixture.$stringArray.results.count == 5)
    #expect(fixture.$stringArray.errors.count == 1) // null
    
    #expect(fixture.$intArray.results.count == 5)
    #expect(fixture.$intArray.errors.count == 3) // "invalid", 3.14, true
    
    #expect(fixture.$doubleArray.results.count == 5)
    #expect(fixture.$doubleArray.errors.count == 2) // null, "invalid"
    
    #expect(fixture.$objectArray.results.count == 2)
    #expect(fixture.$objectArray.errors.count == 1) // Objects cannot be converted to String
    #endif
  }
  
  @Test("error reporting with JSONDecoder")
  func testErrorReporting() throws {
    let json = """
    {
      "stringArray": [1, null, "three"],
      "intArray": ["not a number", 2],
      "doubleArray": [1.5, "invalid", null],
      "objectArray": []
    }
    """
    
    let decoder = JSONDecoder()
    let errorReporter = decoder.enableResilientDecodingErrorReporting()
    
    let data = try #require(json.data(using: .utf8))
    _ = try decoder.decode(Fixture.self, from: data)
    
    let errorDigest = errorReporter.flushReportedErrors()
    
    #if DEBUG
    // Check if errors were reported
    let digest = try #require(errorDigest)
    // null and conversion failure errors
    #expect(digest.errors.count >= 3)
    print("Error digest: \(digest.debugDescription)")
    #else
    #expect(errorDigest == nil)
    #endif
  }
  
  @Test("complete failure results in empty array")
  func testCompleteFailure() async throws {
    let json = """
    {
      "stringArray": "not an array",
      "intArray": 123,
      "doubleArray": null,
      "objectArray": true
    }
    """
    
    let decoder = JSONDecoder()
    let data = try #require(json.data(using: .utf8))
    
    await confirmation(expectedCount: 1) { confirmation in
      do {
        _ = try decoder.decode(Fixture.self, from: data)
        Issue.record("Should have thrown")
      } catch {
        // Non-array values cause decoding failure
        confirmation()
      }
    }
  }
  
  @Test("missing keys result in decoding error")
  func testMissingKeys() async throws {
    let json = "{}"
    
    let decoder = JSONDecoder()
    let data = try #require(json.data(using: .utf8))
    
    await confirmation(expectedCount: 1) { confirmation in
      do {
        _ = try decoder.decode(Fixture.self, from: data)
        Issue.record("Should have thrown")
      } catch {
        // Decoding failure as required property
        confirmation()
      }
    }
  }
}
