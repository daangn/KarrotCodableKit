import Foundation
import Testing
@testable import KarrotCodableKit

@Suite("LossyOptionalPolymorphicValue Resilient Decoding")
struct LossyOptionalPolymorphicValueResilientTests {
  struct Fixture: Decodable {
    @DummyNotice.LossyOptionalPolymorphic var notice: DummyNotice?
  }

  @Test("nil 값 디코딩 시 outcome이 valueWasNil이어야 함")
  func nilValue() throws {
    // given
    let json = """
      {
        "notice": null
      }
      """

    // when
    let data = json.data(using: .utf8)!
    let result = try JSONDecoder().decode(Fixture.self, from: data)

    // then
    #expect(result.notice == nil)
    #if DEBUG
    #expect(result.$notice.outcome == .valueWasNil)
    #expect(result.$notice.error == nil)
    #endif
  }

  @Test("키가 없을 때 outcome이 keyNotFound여야 함")
  func missingKey() throws {
    // given
    let json = """
      {}
      """

    // when
    let data = json.data(using: .utf8)!
    let result = try JSONDecoder().decode(Fixture.self, from: data)

    // then
    #expect(result.notice == nil)
    #if DEBUG
    #expect(result.$notice.outcome == .keyNotFound)
    #expect(result.$notice.error == nil)
    #endif
  }

  @Test("정상적인 값 디코딩 시 outcome이 decodedSuccessfully여야 함")
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
    let data = json.data(using: .utf8)!
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

  @Test("알 수 없는 타입일 때 nil을 반환하고 에러를 기록해야 함")
  func unknownTypeReturnsNil() throws {
    // given
    let json = """
      {
        "notice": {
          "type": "unknown-type"
        }
      }
      """

    // when
    let data = json.data(using: .utf8)!
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

  @Test("잘못된 JSON 형식일 때 nil을 반환하고 에러를 기록해야 함")
  func invalidJSONReturnsNil() throws {
    // given
    let json = """
      {
        "notice": "invalid"
      }
      """

    // when
    let data = json.data(using: .utf8)!
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

  @Test("에러 리포터가 호출되어야 함")
  func errorReporterCalled() throws {
    // given
    let json = """
      {
        "notice": {
          "type": "unknown-type"
        }
      }
      """

    // when
    let data = json.data(using: .utf8)!
    let decoder = JSONDecoder()
    let errorReporter = decoder.enableResilientDecodingErrorReporting()

    let result = try decoder.decode(Fixture.self, from: data)

    // then
    #expect(result.notice == nil)

    let errorDigest = errorReporter.flushReportedErrors()
    #expect(errorDigest != nil)
    if let digest = errorDigest {
      let errors = digest.errors
      #expect(errors.count >= 1)
      #expect(errors.first is DecodingError)
    }
  }
}
