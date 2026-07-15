import Foundation
import Testing
@testable import KarrotCodableKit

@Suite("LossyOptionalPolymorphicValue Resilient Decoding")
struct LossyOptionalPolymorphicValueResilientTests {
  struct Fixture: Decodable {
    @DummyNotice.LossyOptionalPolymorphic var notice: (any DummyNotice)?
  }

  @Test
  func `Outcome should be valueWasNil when decoding nil value`() throws {
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

  @Test
  func `Outcome should be keyNotFound when key is missing`() throws {
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

  @Test
  func `Outcome should be decodedSuccessfully for successful decoding`() throws {
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

  @Test
  func `Should return nil and record error for unknown type`() throws {
    // given
    let json = """
      {
        "notice": {
          "type": "unknown-type"
        }
      }
      """

    // when
    let data = try #require(json.data(using: .utf8))
    let result = try JSONDecoder().decode(Fixture.self, from: data)

    // then
    #expect(result.notice == nil)

    #if DEBUG
    if case .recoveredFrom(let error, _) = result.$notice.outcome {
      #expect(error is DecodingError)
    } else {
      Issue.record("Expected recoveredFrom outcome")
    }
    #expect(result.$notice.error != nil)
    #endif
  }

  @Test
  func `Should return nil and record error for invalid JSON format`() throws {
    // given
    let json = """
      {
        "notice": "invalid"
      }
      """

    // when
    let data = try #require(json.data(using: .utf8))
    let result = try JSONDecoder().decode(Fixture.self, from: data)

    // then
    #expect(result.notice == nil)

    #if DEBUG
    if case .recoveredFrom(let error, _) = result.$notice.outcome {
      #expect(error is DecodingError)
    } else {
      Issue.record("Expected recoveredFrom outcome")
    }
    #expect(result.$notice.error != nil)
    #endif
  }

  @Test
  func `Error reporter should be called`() throws {
    /// given
    let json = """
      {
        "notice": {
          "type": "unknown-type"
        }
      }
      """

    // when
    let data = try #require(json.data(using: .utf8))
    let decoder = JSONDecoder()
    let errorReporter = decoder.enableResilientDecodingErrorReporting()

    let result = try decoder.decode(Fixture.self, from: data)

    // then
    #expect(result.notice == nil)

    let errorDigest = errorReporter.flushReportedErrors()

    #if DEBUG
    let digest = try #require(errorDigest)
    let errors = digest.errors
    #expect(errors.count >= 1)
    #expect(errors.first is DecodingError)
    #else
    #expect(errorDigest == nil)
    #endif
  }
}
