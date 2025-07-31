import Foundation
import Testing
@testable import KarrotCodableKit

@Suite("OptionalPolymorphicValue Resilient Decoding")
struct OptionalPolymorphicValueResilientTests {
  struct Fixture: Decodable {
    @DummyNotice.OptionalPolymorphic var notice: (any DummyNotice)?
  }

  @Test("Outcome should be valueWasNil when decoding nil value")
  func nilValue() throws {
    // given
    let json = """
      {
        "notice": null
      }
      """

    // when
    let data = try #require(json.data(using: .utf8))
    let result = try JSONDecoder().decode(Fixture.self, from: data)

    // then
    #expect(result.notice == nil)
    #if DEBUG
    #expect(result.$notice.outcome == .valueWasNil)
    #expect(result.$notice.error == nil)
    #endif
  }

  @Test("Outcome should be keyNotFound when key is missing")
  func missingKey() throws {
    // given
    let json = """
      {}
      """

    // when
    let data = try #require(json.data(using: .utf8))
    let result = try JSONDecoder().decode(Fixture.self, from: data)

    // then
    #expect(result.notice == nil)
    #if DEBUG
    #expect(result.$notice.outcome == .keyNotFound)
    #expect(result.$notice.error == nil)
    #endif
  }

  @Test("Outcome should be decodedSuccessfully for successful decoding")
  func successfulDecoding() throws {
    // given
    let json = """
      {
        "notice": {
          "__typename": "callout",
          "type": "callout",
          "title": "Test Title",
          "description": "Hello",
          "icon": "icon.png"
        }
      }
      """

    // when
    let data = try #require(json.data(using: .utf8))
    let result = try JSONDecoder().decode(Fixture.self, from: data)

    // then
    let callout = try #require(result.notice as? DummyCallout)
    #expect(callout.type == .callout)
    #expect(callout.title == "Test Title")
    #expect(callout.description == "Hello")

    #if DEBUG
    #expect(result.$notice.outcome == .decodedSuccessfully)
    #expect(result.$notice.error == nil)
    #endif
  }

  @Test("Should throw error for unknown type")
  func unknownTypeThrowsError() throws {
    // given
    let json = """
      {
        "notice": {
          "__typename": "unknown",
          "id": "1"
        }
      }
      """

    // when/then
    let data = try #require(json.data(using: .utf8))
    #expect(throws: Error.self) {
      _ = try JSONDecoder().decode(Fixture.self, from: data)
    }
  }

  @Test("Should throw error for invalid JSON format")
  func invalidJSONThrowsError() throws {
    // given
    let json = """
      {
        "notice": "invalid"
      }
      """

    // when/then
    let data = try #require(json.data(using: .utf8))
    #expect(throws: Error.self) {
      _ = try JSONDecoder().decode(Fixture.self, from: data)
    }
  }

}
