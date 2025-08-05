//
//  PolymorphicValueResilientTests.swift
//  KarrotCodableKitTests
//
//  Created by Elon on 4/9/25.
//

import Foundation
import Testing
@testable import KarrotCodableKit

@Suite("PolymorphicValue Resilient Decoding")
struct PolymorphicValueResilientTests {
  struct Fixture: Decodable {
    @DummyNotice.Polymorphic var notice: any DummyNotice
  }

  @Test("projected value provides error information")
  func projectedValueProvidesErrorInfo() throws {
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
    let data = try #require(json.data(using: .utf8))
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
  func unknownType() throws {
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
    let data = try #require(json.data(using: .utf8))

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
  func nullValues() async throws {
    // given
    let json = """
      {
        "notice": null
      }
      """

    // when/then
    let decoder = JSONDecoder()
    let data = try #require(json.data(using: .utf8))

    await confirmation(expectedCount: 1) { confirmation in
      do {
        _ = try decoder.decode(Fixture.self, from: data)
        Issue.record("Should have thrown")
      } catch {
        // Verify specific error type if possible
        // e.g., check for DecodingError.valueNotFound or similar
        confirmation()
      }
    }
  }

  @Test("error reporting with JSONDecoder")
  func errorReporting() async throws {
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

    let data = try #require(json.data(using: .utf8))

    // then
    await confirmation(expectedCount: 1) { confirmation in
      do {
        _ = try decoder.decode(Fixture.self, from: data)
        Issue.record("Should have thrown")
      } catch {
        // Decoding failed due to type mismatch (key should be String)
        confirmation()
      }
    }

    // then
    let errorDigest = errorReporter.flushReportedErrors()

    // Check if error was reported
    let digest = try #require(errorDigest)
    #expect(digest.errors.count >= 1)
  }
}
