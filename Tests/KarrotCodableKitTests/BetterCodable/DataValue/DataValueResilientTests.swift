//
//  DataValueResilientTests.swift
//  KarrotCodableKitTests
//
//  Created by Elon on 4/9/25.
//

import Foundation
import Testing
@testable import KarrotCodableKit

@Suite("DataValue Resilient Decoding")
struct DataValueResilientTests {
  struct Fixture: Decodable {
    @DataValue<Base64Strategy> var base64Data: Data
    @DataValue<Base64Strategy> var anotherData: Data
  }

  @Test("projected value provides error information")
  func projectedValueProvidesErrorInfo() throws {
    let json = """
      {
        "base64Data": "SGVsbG8gV29ybGQ=",
        "anotherData": "VGVzdCBEYXRh"
      }
      """

    let decoder = JSONDecoder()
    let data = try #require(json.data(using: .utf8))
    let fixture = try decoder.decode(Fixture.self, from: data)

    // Verify default behavior
    #expect(String(data: fixture.base64Data, encoding: .utf8) == "Hello World")
    #expect(String(data: fixture.anotherData, encoding: .utf8) == "Test Data")

    #if DEBUG
    // Access success info through projected value
    #expect(fixture.$base64Data.outcome == .decodedSuccessfully)
    #expect(fixture.$anotherData.outcome == .decodedSuccessfully)
    #endif
  }

  @Test("invalid base64 format handling")
  func invalidBase64Format() async throws {
    let json = """
      {
        "base64Data": "Invalid!@#$%^&*()Base64",
        "anotherData": "====="
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
  func nullValues() async throws {
    let json = """
      {
        "base64Data": null,
        "anotherData": null
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
  func errorReporting() async throws {
    let json = """
      {
        "base64Data": 12345,
        "anotherData": {"key": "value"}
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
