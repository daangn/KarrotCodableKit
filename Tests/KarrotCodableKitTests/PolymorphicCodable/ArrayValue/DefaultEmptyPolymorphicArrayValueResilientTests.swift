import Foundation
import Testing
@testable import KarrotCodableKit

@Suite("DefaultEmptyPolymorphicArrayValue Resilient Decoding")
struct DefaultEmptyPolymorphicArrayValueResilientTests {
  struct Fixture: Decodable {
    @DummyNotice.DefaultEmptyPolymorphicArray var notices: [any DummyNotice]
  }

  @Test("Empty array decoding should have decodedSuccessfully outcome")
  func emptyArray() throws {
    // given
    let json = """
      {
        "notices": []
      }
      """

    // when
    let data = try #require(json.data(using: .utf8))
    let result = try JSONDecoder().decode(Fixture.self, from: data)

    // then
    #expect(result.notices.isEmpty)
    #if DEBUG
    #expect(result.$notices.outcome == .decodedSuccessfully)
    #expect(result.$notices.error == nil)
    #endif
  }

  @Test("Successful array decoding should have decodedSuccessfully outcome")
  func successfulArrayDecoding() throws {
    // given
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

    // when
    let data = try #require(json.data(using: .utf8))
    let result = try JSONDecoder().decode(Fixture.self, from: data)

    // then
    #expect(result.notices.count == 2)
    #expect(result.notices[0] is DummyCallout)
    #expect(result.notices[1] is DummyActionableCallout)

    #if DEBUG
    #expect(result.$notices.outcome == .decodedSuccessfully)
    #expect(result.$notices.error == nil)
    #endif
  }

  @Test("Should return empty array when array contains any invalid element")
  func arrayWithAnyInvalidElement() throws {
    // given
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

    // when
    let data = try #require(json.data(using: .utf8))
    let result = try JSONDecoder().decode(Fixture.self, from: data)

    // then
    #expect(result.notices.isEmpty)

    #if DEBUG
    if case .recoveredFrom = result.$notices.outcome {
      // Expected
    } else {
      Issue.record("Expected recoveredFrom outcome")
    }
    #expect(result.$notices.error != nil)
    #endif
  }

  @Test("Should return empty array when key is missing")
  func missingKey() throws {
    // given
    let json = """
      {}
      """

    // when
    let data = try #require(json.data(using: .utf8))
    let result = try JSONDecoder().decode(Fixture.self, from: data)

    // then
    #expect(result.notices.isEmpty)
    #if DEBUG
    #expect(result.$notices.outcome == .keyNotFound)
    #expect(result.$notices.error == nil)
    #endif
  }

  @Test("Should return empty array for null value")
  func nullValue() throws {
    // given
    let json = """
      {
        "notices": null
      }
      """

    // when
    let data = try #require(json.data(using: .utf8))
    let result = try JSONDecoder().decode(Fixture.self, from: data)

    // then
    #expect(result.notices.isEmpty)
    #if DEBUG
    #expect(result.$notices.outcome == .valueWasNil)
    #expect(result.$notices.error == nil)
    #endif
  }

  @Test("Should return empty array for invalid type")
  func invalidType() throws {
    // given
    let json = """
      {
        "notices": "not an array"
      }
      """

    // when
    let data = try #require(json.data(using: .utf8))
    let result = try JSONDecoder().decode(Fixture.self, from: data)

    // then
    #expect(result.notices.isEmpty)
    #if DEBUG
    if case .recoveredFrom = result.$notices.outcome {
      // Expected
    } else {
      Issue.record("Expected recoveredFrom outcome")
    }
    #expect(result.$notices.error != nil)
    #endif
  }

  @Test("Error reporter should be called")
  func errorReporting() throws {
    // given
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

    // when
    let data = try #require(json.data(using: .utf8))
    let decoder = JSONDecoder()
    let errorReporter = decoder.enableResilientDecodingErrorReporting()

    let result = try decoder.decode(Fixture.self, from: data)

    // then
    #expect(result.notices.isEmpty)

    let errorDigest = errorReporter.flushReportedErrors()
    let digest = try #require(errorDigest)
    let errors = digest.errors
    #expect(errors.count >= 1)
  }
}
