//
//  OptionalPolymorphicArrayValueResilientTests.swift
//  KarrotCodableKit
//
//  Created by Elon on 2025-07-28.
//

import Foundation
import Testing

import KarrotCodableKit

// MARK: - Test Types

@CustomCodable(codingKeyStyle: .snakeCase)
struct ResilientOptionalPolymorphicArrayDummyResponse {
  @DummyNotice.OptionalPolymorphicArray
  var notices: [any DummyNotice]?

  @DummyNotice.OptionalPolymorphicArray
  var notices2: [any DummyNotice]?

  @DummyNotice.OptionalPolymorphicArray
  var notices3: [any DummyNotice]?

  @DummyNotice.OptionalPolymorphicArray
  var notices4: [any DummyNotice]?
}

struct OptionalPolymorphicArrayValueResilientTests {

  // MARK: - Successful Decoding Tests

  @Test
  func `decodes valid array without errors`() throws {
    // given
    let jsonData = #"""
      {
        "notices": [
          {
            "description": "test1",
            "icon": "test_icon1",
            "type": "callout"
          },
          {
            "description": "test2",
            "action": "https://example.com",
            "type": "actionable-callout"
          }
        ]
      }
      """#

    // when
    let result = try JSONDecoder().decode(
      ResilientOptionalPolymorphicArrayDummyResponse.self,
      from: Data(jsonData.utf8),
    )

    // then
    let notices = try #require(result.notices)
    #expect(notices.count == 2)

    let firstNotice = try #require(notices[0] as? DummyCallout)
    #expect(firstNotice.description == "test1")
    #expect(firstNotice.icon == "test_icon1")
    #expect(firstNotice.type == .callout)

    let secondNotice = try #require(notices[1] as? DummyActionableCallout)
    #expect(secondNotice.description == "test2")
    #expect(secondNotice.action == URL(string: "https://example.com"))
    #expect(secondNotice.type == .actionableCallout)

    #if DEBUG
    #expect(result.$notices.error == nil)
    #endif
  }

  @Test
  func `decodes empty array without errors`() throws {
    // given
    let jsonData = #"""
      {
        "notices": []
      }
      """#

    // when
    let result = try JSONDecoder().decode(
      ResilientOptionalPolymorphicArrayDummyResponse.self,
      from: Data(jsonData.utf8),
    )

    // then
    let notices = try #require(result.notices)
    #expect(notices.isEmpty)

    #if DEBUG
    #expect(result.$notices.error == nil)
    #endif
  }

  @Test
  func `decodes null value without errors`() throws {
    // given
    let jsonData = #"""
      {
        "notices": null
      }
      """#

    // when
    let result = try JSONDecoder().decode(
      ResilientOptionalPolymorphicArrayDummyResponse.self,
      from: Data(jsonData.utf8),
    )

    // then
    #expect(result.notices == nil)

    #if DEBUG
    #expect(result.$notices.error == nil)
    #endif
  }

  @Test
  func `decodes missing key without errors`() throws {
    // given
    let jsonData = #"""
      {
      }
      """#

    // when
    let result = try JSONDecoder().decode(
      ResilientOptionalPolymorphicArrayDummyResponse.self,
      from: Data(jsonData.utf8),
    )

    // then
    #expect(result.notices == nil)

    #if DEBUG
    #expect(result.$notices.error == nil)
    #endif
  }

  // MARK: - Error Reporting Tests

  @Test
  func `reports error when invalid element in array`() throws {
    /// given - Missing required 'description' field in second element
    let jsonData = #"""
      {
        "notices": [
          {
            "description": "test1",
            "type": "callout"
          },
          {
            "type": "callout"
          }
        ]
      }
      """#

    let decoder = JSONDecoder()
    let errorReporter = decoder.enableResilientDecodingErrorReporting()

    // when & then
    #expect(throws: Error.self) {
      _ = try decoder.decode(ResilientOptionalPolymorphicArrayDummyResponse.self, from: Data(jsonData.utf8))
    }

    /// Verify errors were reported
    let errorDigest = errorReporter.flushReportedErrors()

    #if DEBUG
    #expect(errorDigest != nil)
    #else
    #expect(errorDigest == nil)
    #endif
  }

  @Test
  func `reports error when not array type`() throws {
    /// given
    let jsonData = #"""
      {
        "notices": "not an array"
      }
      """#

    let decoder = JSONDecoder()
    let errorReporter = decoder.enableResilientDecodingErrorReporting()

    // when & then
    #expect(throws: Error.self) {
      _ = try decoder.decode(ResilientOptionalPolymorphicArrayDummyResponse.self, from: Data(jsonData.utf8))
    }

    /// Verify errors were reported
    let errorDigest = errorReporter.flushReportedErrors()

    #if DEBUG
    #expect(errorDigest != nil)
    #else
    #expect(errorDigest == nil)
    #endif
  }

  // MARK: - Projected Value Tests

  #if DEBUG
  @Test
  func `projected value returns nil error for successful decoding`() throws {
    // given
    let jsonData = #"""
      {
        "notices": [
          {
            "description": "test",
            "type": "callout"
          }
        ]
      }
      """#

    // when
    let result = try JSONDecoder().decode(
      ResilientOptionalPolymorphicArrayDummyResponse.self,
      from: Data(jsonData.utf8),
    )

    // then
    #expect(result.$notices.error == nil)
    #expect(result.$notices.outcome == .decodedSuccessfully)
  }

  @Test
  func `projected value returns outcome for nil value`() throws {
    // given
    let jsonData = #"""
      {
        "notices": null
      }
      """#

    // when
    let result = try JSONDecoder().decode(
      ResilientOptionalPolymorphicArrayDummyResponse.self,
      from: Data(jsonData.utf8),
    )

    // then
    #expect(result.$notices.error == nil)
    #expect(result.$notices.outcome == .valueWasNil)
  }

  @Test
  func `projected value returns outcome for missing key`() throws {
    // given
    let jsonData = #"""
      {
      }
      """#

    // when
    let result = try JSONDecoder().decode(
      ResilientOptionalPolymorphicArrayDummyResponse.self,
      from: Data(jsonData.utf8),
    )

    // then
    #expect(result.$notices.error == nil)
    #expect(result.$notices.outcome == .keyNotFound)
  }
  #endif

  // MARK: - Multiple Properties Test

  @Test
  func `decodes multiple properties correctly`() throws {
    // given
    let jsonData = #"""
      {
        "notices": [
          {
            "description": "test1",
            "type": "callout"
          }
        ],
        "notices2": null,
        "notices3": []
      }
      """#

    // when
    let result = try JSONDecoder().decode(
      ResilientOptionalPolymorphicArrayDummyResponse.self,
      from: Data(jsonData.utf8),
    )

    // then
    let notices = try #require(result.notices)
    #expect(notices.count == 1)
    #expect(result.notices2 == nil)

    let notices3 = try #require(result.notices3)
    #expect(notices3.isEmpty)

    #expect(result.notices4 == nil) // missing key

    #if DEBUG
    #expect(result.$notices.outcome == .decodedSuccessfully)
    #expect(result.$notices2.outcome == .valueWasNil)
    #expect(result.$notices3.outcome == .decodedSuccessfully)
    #expect(result.$notices4.outcome == .keyNotFound)
    #endif
  }
}
