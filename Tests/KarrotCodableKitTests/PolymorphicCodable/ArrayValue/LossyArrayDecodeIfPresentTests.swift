//
//  LossyArrayDecodeIfPresentTests.swift
//  KarrotCodableKit
//
//  Created by Elon on 7/15/26.
//  Copyright © 2026 Danggeun Market Inc. All rights reserved.
//

import Testing
import Foundation

import KarrotCodableKit

/// Characterizes the `decodeIfPresent(_:forKey:)` container overload for
/// `PolymorphicLossyArrayValue`, which synthesized `Codable` never calls for
/// `@PolymorphicLossyArray` (its `wrappedValue` is a non-optional `[T]`, so the
/// compiler-generated code always calls `decode`).
struct LossyArrayDecodeIfPresentTests {

  @Test func testDecodeIfPresentReturnsNilForMissingKey() throws {
    // given
    let jsonData = #"{ }"#

    // when
    let result = try JSONDecoder().decode(
      LossyArrayDecodeIfPresentDummyResponse.self,
      from: Data(jsonData.utf8)
    )

    // then
    #expect(result.notices1 == nil)
  }

  @Test func testDecodeIfPresentReturnsEmptyArrayForNullValue() throws {
    // given
    let jsonData = #"""
    {
      "notices1" : null
    }
    """#

    // when
    let result = try JSONDecoder().decode(
      LossyArrayDecodeIfPresentDummyResponse.self,
      from: Data(jsonData.utf8)
    )

    // then
    let notices1 = try #require(result.notices1)
    #expect(notices1.wrappedValue.isEmpty)
  }

  @Test func testDecodeIfPresentDecodesPresentArray() throws {
    // given
    let jsonData = #"""
    {
      "notices1" : [
        {
          "description" : "test",
          "icon" : "test_icon",
          "type" : "callout"
        }
      ]
    }
    """#

    // when
    let result = try JSONDecoder().decode(
      LossyArrayDecodeIfPresentDummyResponse.self,
      from: Data(jsonData.utf8)
    )

    // then
    let notices1 = try #require(result.notices1)
    #expect(notices1.wrappedValue.count == 1)
    #expect(notices1.wrappedValue.first?.type == .callout)
  }

  @Test func testDecodeIfPresentRecoversEmptyArrayForNonArrayValue() throws {
    // given
    let jsonData = #"""
    {
      "notices1" : "not an array"
    }
    """#

    // when
    let result = try JSONDecoder().decode(
      LossyArrayDecodeIfPresentDummyResponse.self,
      from: Data(jsonData.utf8)
    )

    // then: matches `decode(_:forKey:)`, which recovers a non-array value to an empty array
    let notices1 = try #require(result.notices1)
    #expect(notices1.wrappedValue.isEmpty)
  }

  #if DEBUG
  @Test func testDecodeIfPresentNonArrayOutcomeMatchesDecode() throws {
    // given: the same non-array payload decoded through both container entry points
    let jsonData = #"""
    {
      "notices1" : "not an array"
    }
    """#

    // when
    let decodeResult = try JSONDecoder().decode(
      OptionalLossyArrayDummyResponse.self,
      from: Data(jsonData.utf8)
    )
    let decodeIfPresentResult = try JSONDecoder().decode(
      LossyArrayDecodeIfPresentDummyResponse.self,
      from: Data(jsonData.utf8)
    )

    // then: both entry points recover and report the same outcome
    let notices1 = try #require(decodeIfPresentResult.notices1)
    #expect(notices1.outcome != .decodedSuccessfully)
    #expect(notices1.outcome == decodeResult.$notices1.outcome)
  }

  @Test func testDecodeIfPresentNullOutcomeMatchesDecode() throws {
    // given: the same null payload decoded through both container entry points
    let jsonData = #"""
    {
      "notices1" : null
    }
    """#

    // when
    let decodeResult = try JSONDecoder().decode(
      OptionalLossyArrayDummyResponse.self,
      from: Data(jsonData.utf8)
    )
    let decodeIfPresentResult = try JSONDecoder().decode(
      LossyArrayDecodeIfPresentDummyResponse.self,
      from: Data(jsonData.utf8)
    )

    // then: a null value must not be reported as a clean success by either entry point
    let notices1 = try #require(decodeIfPresentResult.notices1)
    #expect(notices1.outcome != .decodedSuccessfully)
    #expect(notices1.outcome == decodeResult.$notices1.outcome)
  }
  #endif
}

/// Reaches the container-level `decodeIfPresent(_:forKey:)` overload through a manual
/// `init(from:)`, since property-wrapper synthesis never routes through it.
private struct LossyArrayDecodeIfPresentDummyResponse: Decodable {

  let notices1: PolymorphicLossyArrayValue<DummyNoticeCodableStrategy>?

  enum CodingKeys: String, CodingKey {
    case notices1
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.notices1 = try container.decodeIfPresent(
      PolymorphicLossyArrayValue<DummyNoticeCodableStrategy>.self,
      forKey: .notices1
    )
  }
}
