import Foundation
import Testing
@testable import KarrotCodableKit

@Suite("PolymorphicLossyArrayValue Resilient Decoding")
struct PolymorphicLossyArrayValueResilientTests {
  struct Fixture: Decodable {
    @DummyNotice.PolymorphicLossyArray var notices: [any DummyNotice]
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
    #expect(result.$notices.results.isEmpty)
    #endif
  }

  @Test("Successful array decoding should have all elements succeed")
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
    #expect(result.$notices.results.count == 2)
    #expect(try result.$notices.results.allSatisfy(\.isSuccess))
    #endif
  }

  @Test("Should decode only valid elements when array has invalid elements")
  func arrayWithInvalidElements() throws {
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
          },
          {
            "type": "dismissible-callout",
            "title": "Also Valid",
            "description": "Another valid callout",
            "key": "dismiss-key"
          },
          "not-an-object",
          null,
          123
        ]
      }
      """

    // when
    let data = try #require(json.data(using: .utf8))
    let result = try JSONDecoder().decode(Fixture.self, from: data)

    // then
    #expect(result.notices.count == 2)
    #expect(result.notices[0] is DummyCallout)
    #expect(result.notices[1] is DummyDismissibleCallout)

    #if DEBUG
    #expect(result.$notices.outcome == .decodedSuccessfully)
    #expect(result.$notices.results.count == 6)

    // Only first and third elements succeed
    #expect(result.$notices.results[0].isSuccess)
    #expect(result.$notices.results[1].isFailure)
    #expect(result.$notices.results[2].isSuccess)
    #expect(result.$notices.results[3].isFailure)
    #expect(result.$notices.results[4].isFailure)
    #expect(result.$notices.results[5].isFailure)
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
    // missing key should error for non-optional property
    #expect(result.$notices.error != nil)
    #expect(result.$notices.results.isEmpty)
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
    #expect(result.$notices.results.isEmpty)
    #endif
  }

  @Test("Error reporter should be called partially")
  func partialErrorReporting() throws {
    /// given
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
    #expect(result.notices.count == 1)

    let errorDigest = errorReporter.flushReportedErrors()

    #if DEBUG
    let digest = try #require(errorDigest)
    let errors = digest.errors
    #expect(errors.count >= 1)
    #else
    #expect(errorDigest == nil)
    #endif
  }
}
