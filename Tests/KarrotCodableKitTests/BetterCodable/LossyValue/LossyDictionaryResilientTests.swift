//
//  LossyDictionaryResilientTests.swift
//  KarrotCodableKitTests
//
//  Created by Elon on 4/9/25.
//

import Foundation
import Testing
@testable import KarrotCodableKit

@Suite("LossyDictionary Resilient Decoding")
struct LossyDictionaryResilientTests {
  struct Fixture: Decodable {
    @LossyDictionary var stringDict: [String: Int]
    @LossyDictionary var intDict: [Int: String]

    struct NestedObject: Decodable, Equatable {
      let id: Int
      let name: String
    }

    @LossyDictionary var objectDict: [String: NestedObject]
  }

  @Test("projected value provides error information for each failed key-value pair")
  func projectedValueProvidesErrorInfo() throws {
    let json = """
      {
        "stringDict": {
          "one": 1,
          "two": "invalid",
          "three": 3,
          "four": null
        },
        "intDict": {
          "1": "first",
          "2": "second",
          "3": "third",
          "invalid": "should be ignored"
        },
        "objectDict": {
          "obj1": {"id": 1, "name": "first"},
          "obj2": {"id": "invalid", "name": "second"},
          "obj3": {"id": 3, "name": "third"}
        }
      }
      """

    let decoder = JSONDecoder()
    let data = try #require(json.data(using: .utf8))
    let fixture = try decoder.decode(Fixture.self, from: data)

    // Verify default behavior - only valid key-value pairs included
    #expect(fixture.stringDict == ["one": 1, "three": 3])
    #expect(fixture.intDict == [1: "first", 2: "second", 3: "third"]) // All Int keys are valid
    #expect(fixture.objectDict == [
      "obj1": Fixture.NestedObject(id: 1, name: "first"),
      "obj3": Fixture.NestedObject(id: 3, name: "third"),
    ])

    #if DEBUG
    // Access error info through projected value
    #expect(fixture.$stringDict.results.count == 4)
    #expect(fixture.$stringDict.errors.count == 2) // "invalid" and null

    /// Check success/failure of each key
    let stringResults = fixture.$stringDict.results
    #expect(stringResults["one"]?.success == 1)
    #expect(stringResults["two"]?.isFailure == true)

    // intDict validation - Int key type
    #expect(fixture.$intDict.errors.count == 0) // All keys are valid

    // objectDict validation
    #expect(fixture.$objectDict.results.count == 3)
    #expect(fixture.$objectDict.errors.count == 1) // "invalid" id
    #endif
  }

  @Test("error reporting with JSONDecoder")
  func errorReporting() throws {
    let json = """
      {
        "stringDict": {
          "a": "not a number",
          "b": 2,
          "c": false
        },
        "intDict": {},
        "objectDict": {}
      }
      """

    let decoder = JSONDecoder()
    let errorReporter = decoder.enableResilientDecodingErrorReporting()

    let data = try #require(json.data(using: .utf8))
    _ = try decoder.decode(Fixture.self, from: data)

    let errorDigest = errorReporter.flushReportedErrors()

    #if DEBUG
    /// Check if errors were reported
    let digest = try #require(errorDigest)
    #expect(digest.errors.count >= 2) // Errors for keys "a" and "c"
    #else
    #expect(errorDigest == nil)
    #endif
  }

  @Test("complete failure results in empty dictionary")
  func completeFailure() throws {
    let json = """
      {
        "stringDict": "not a dictionary",
        "intDict": 123,
        "objectDict": null
      }
      """

    let decoder = JSONDecoder()
    let data = try #require(json.data(using: .utf8))

    let fixture = try decoder.decode(Fixture.self, from: data)

    #expect(fixture.stringDict == [:])
    #expect(fixture.intDict == [:])
    #expect(fixture.objectDict == [:])

    #if DEBUG
    // Error info when entire dictionary decoding fails
    #expect(fixture.$stringDict.error != nil)
    #expect(fixture.$intDict.error != nil)
    #expect(fixture.$objectDict.error != nil) // null value should error for non-optional property
    #endif
  }

  @Test("missing keys result in empty dictionary")
  func missingKeys() throws {
    let json = "{}"

    let decoder = JSONDecoder()
    let data = try #require(json.data(using: .utf8))

    let fixture = try decoder.decode(Fixture.self, from: data)

    #expect(fixture.stringDict == [:])
    #expect(fixture.intDict == [:])
    #expect(fixture.objectDict == [:])

    #if DEBUG
    // Missing key should error for non-optional properties
    #expect(fixture.$stringDict.error != nil)
    #expect(fixture.$intDict.error != nil)
    #expect(fixture.$objectDict.error != nil)
    #endif
  }
}
