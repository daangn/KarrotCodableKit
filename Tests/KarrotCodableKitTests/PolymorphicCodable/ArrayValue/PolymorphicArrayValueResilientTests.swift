import Foundation
import Testing
@testable import KarrotCodableKit

@Suite("PolymorphicArrayValue Resilient Decoding")
struct PolymorphicArrayValueResilientTests {
  struct Fixture: Decodable {
    @DummyNotice.PolymorphicArray var notices: [any DummyNotice]
  }

  @Test
  func `Empty array decoding should have decodedSuccessfully outcome`() throws {
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

  @Test
  func `Successful array decoding should have decodedSuccessfully outcome`() throws {
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
          },
          {
            "type": "dismissible-callout",
            "title": "Third",
            "description": "Third callout",
            "key": "dismiss-key"
          }
        ]
      }
      """

    // when
    let data = try #require(json.data(using: .utf8))
    let result = try JSONDecoder().decode(Fixture.self, from: data)

    // then
    #expect(result.notices.count == 3)
    #expect(result.notices[0] is DummyCallout)
    #expect(result.notices[1] is DummyActionableCallout)
    #expect(result.notices[2] is DummyDismissibleCallout)

    #if DEBUG
    #expect(result.$notices.outcome == .decodedSuccessfully)
    #expect(result.$notices.error == nil)
    #endif
  }

  @Test
  func `Array should fail to decode if any element fails`() throws {
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

    // when/then
    let data = try #require(json.data(using: .utf8))
    #expect(throws: Error.self) {
      _ = try JSONDecoder().decode(Fixture.self, from: data)
    }
  }

  @Test
  func `Should throw error when key is missing`() throws {
    // given
    let json = """
      {}
      """

    // when/then
    let data = try #require(json.data(using: .utf8))
    #expect(throws: Error.self) {
      _ = try JSONDecoder().decode(Fixture.self, from: data)
    }
  }

  @Test
  func `Should throw error for invalid type`() throws {
    // given
    let json = """
      {
        "notices": "not an array"
      }
      """

    // when/then
    let data = try #require(json.data(using: .utf8))
    #expect(throws: Error.self) {
      _ = try JSONDecoder().decode(Fixture.self, from: data)
    }
  }

  @Test
  func `Array element errors should be reported`() throws {
    /// given
    let json = """
      {
        "notices": [
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

    // then
    #expect(throws: Error.self) {
      _ = try decoder.decode(Fixture.self, from: data)
    }

    // PolymorphicValue reports errors, so error digest should exist
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
