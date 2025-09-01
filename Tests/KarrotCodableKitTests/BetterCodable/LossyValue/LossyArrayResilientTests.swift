//
//  LossyArrayResilientTests.swift
//  KarrotCodableKitTests
//
//  Created by Elon on 4/9/25.
//

import Foundation
import Testing
@testable import KarrotCodableKit

@Suite("LossyArray Resilient Decoding")
struct LossyArrayResilientTests {
  struct Fixture: Decodable {
    struct NestedObject: Decodable, Equatable {
      let id: Int
      let name: String
    }

    @LossyArray var integers: [Int]
    @LossyArray var strings: [String]
    @LossyArray var objects: [NestedObject]
  }

  @Test("projected value provides error information in DEBUG")
  func projectedValueProvidesErrorInfo() throws {
    let json = """
      {
        "integers": [1, "invalid", 3, null, 5],
        "strings": ["hello", 123, "world", null],
        "objects": [
          {"id": 1, "name": "first"},
          {"id": "invalid", "name": "second"},
          {"id": 3, "name": "third"}
        ]
      }
      """

    let decoder = JSONDecoder()
    let data = try #require(json.data(using: .utf8))
    let fixture = try decoder.decode(Fixture.self, from: data)

    // Verify default behavior
    #expect(fixture.integers == [1, 3, 5])
    #expect(fixture.strings == ["hello", "world"])
    #expect(fixture.objects == [
      Fixture.NestedObject(id: 1, name: "first"),
      Fixture.NestedObject(id: 3, name: "third"),
    ])

    #if DEBUG
    // Access error info through projected value
    #expect(fixture.$integers.results.count == 5)
    #expect(fixture.$integers.errors.count == 2) // "invalid" and null

    /// Check success/failure of each element
    let intResults = fixture.$integers.results
    #expect(try intResults[0].get() == 1)
    #expect(intResults[1].isFailure == true)
    #expect(try intResults[2].get() == 3)
    #expect(intResults[3].isFailure == true)
    #expect(try intResults[4].get() == 5)

    // strings validation
    #expect(fixture.$strings.results.count == 4)
    #expect(fixture.$strings.errors.count == 2) // 123 and null

    // objects validation
    #expect(fixture.$objects.results.count == 3)
    #expect(fixture.$objects.errors.count == 1) // "invalid" id
    #endif
  }

  @Test("error reporting with JSONDecoder")
  func errorReporting() throws {
    let json = """
      {
        "integers": [1, "two", 3],
        "strings": ["a", "b", "c"],
        "objects": []
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
    #expect(digest.errors.count >= 1)
    #else
    #expect(errorDigest == nil)
    #endif
  }

  @Test("decode with reportResilientDecodingErrors")
  func decodeWithReportFlag() throws {
    let json = """
      {
        "integers": [1, "invalid", 3],
        "strings": [],
        "objects": []
      }
      """

    let decoder = JSONDecoder()
    let data = try #require(json.data(using: .utf8))

    let (fixture, errorDigest) = try decoder.decode(
      Fixture.self,
      from: data,
      reportResilientDecodingErrors: true
    )

    #expect(fixture.integers == [1, 3])

    #if DEBUG
    #expect(errorDigest != nil)
    #expect(errorDigest?.errors.count ?? 0 >= 1)
    #else
    #expect(errorDigest == nil)
    #endif
  }

  @Test("empty array on complete failure")
  func emptyArrayOnCompleteFailure() throws {
    let json = """
      {
        "integers": "not an array",
        "strings": 123,
        "objects": null
      }
      """

    let decoder = JSONDecoder()
    let data = try #require(json.data(using: .utf8))

    let fixture = try decoder.decode(Fixture.self, from: data)

    #expect(fixture.integers == [])
    #expect(fixture.strings == [])
    #expect(fixture.objects == [])

    #if DEBUG
    // Error info when entire array decoding fails
    #expect(fixture.$integers.error != nil)
    #expect(fixture.$strings.error != nil)
    #expect(fixture.$objects.error != nil) // null value should error for non-optional property
    #endif
  }
}
