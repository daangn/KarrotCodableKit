//
//  LossyArrayRecoveryPolicyTests.swift
//  KarrotCodableKit
//
//  Created by Elon on 7/15/26.
//  Copyright © 2026 Danggeun Market Inc. All rights reserved.
//

import Foundation
import Testing

import KarrotCodableKit

/// Pins the shared recovery policy of the lossy array wrappers, aligned with BetterCodable's
/// `@LossyArray`: array-level failures (e.g., a non-array value) recover instead of throwing,
/// and element-level failures are recorded in the decoding `outcome`.
///
/// `OptionalPolymorphicLossyArrayValue` follows the exact same policy as
/// `PolymorphicLossyArrayValue`; the only difference is that a missing key or an explicit
/// `null` is represented as `nil` instead of `[]`.
struct LossyArrayRecoveryPolicyTests {

  // MARK: - Array-level recovery for a non-array value

  @Test
  func `optional lossy array recovers empty array for non array value`() throws {
    // given
    let jsonData = #"""
      {
        "notices1" : "not an array"
      }
      """#

    // when
    let result = try JSONDecoder().decode(
      OptionalPolymorphicLossyArrayDummyResponse.self,
      from: Data(jsonData.utf8),
    )

    // then: recovers to an empty array; `nil` stays reserved for a missing key or explicit null
    #expect(try #require(result.notices1).isEmpty)
    #expect(result.notices2 == nil)
  }

  #if DEBUG
  @Test
  func `optional lossy array non array value outcome is recovered`() throws {
    // given
    let jsonData = #"""
      {
        "notices1" : "not an array"
      }
      """#

    // when
    let result = try JSONDecoder().decode(
      OptionalPolymorphicLossyArrayDummyResponse.self,
      from: Data(jsonData.utf8),
    )

    // then: the recovery is visible in the outcome, matching PolymorphicLossyArrayValue
    #expect(result.$notices1.error != nil)
  }
  #endif

  // MARK: - Direct decoding (bypasses the KeyedDecodingContainer overloads)

  @Test
  func `lossy array recovers when decoded directly`() throws {
    // given: dictionary values invoke `init(from:)` directly, bypassing container overloads
    let jsonData = #"""
      {
        "group" : "not an array"
      }
      """#

    // when
    let result = try JSONDecoder().decode(
      [String: PolymorphicLossyArrayValue<DummyNoticeCodableStrategy>].self,
      from: Data(jsonData.utf8),
    )

    // then
    #expect(try #require(result["group"]).wrappedValue.isEmpty)
  }

  @Test
  func `optional lossy array recovers when decoded directly`() throws {
    // given
    let jsonData = #"""
      {
        "group" : "not an array"
      }
      """#

    // when
    let result = try JSONDecoder().decode(
      [String: OptionalPolymorphicLossyArrayValue<DummyNoticeCodableStrategy>].self,
      from: Data(jsonData.utf8),
    )

    // then
    #expect(try #require(result["group"]).wrappedValue?.isEmpty == true)
  }

  // MARK: - Element failures are recorded in the outcome (as with @LossyArray)

  #if DEBUG
  @Test
  func `lossy array element failure is recorded in outcome`() throws {
    // given: one invalid element (missing required 'description') and one valid element
    let jsonData = #"""
      {
        "notices1" : [
          {
            "icon" : "test_icon",
            "type" : "callout"
          },
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
      OptionalLossyArrayDummyResponse.self,
      from: Data(jsonData.utf8),
    )

    // then: valid elements are kept and the failure surfaces through the outcome
    #expect(result.notices1.count == 1)
    #expect(result.$notices1.error is ResilientDecodingOutcome.ArrayDecodingError<any DummyNotice>)
  }

  @Test
  func `optional lossy array element failure is recorded in outcome`() throws {
    // given
    let jsonData = #"""
      {
        "notices1" : [
          {
            "icon" : "test_icon",
            "type" : "callout"
          },
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
      OptionalPolymorphicLossyArrayDummyResponse.self,
      from: Data(jsonData.utf8),
    )

    // then
    #expect(try #require(result.notices1).count == 1)
    #expect(result.$notices1.error is ResilientDecodingOutcome.ArrayDecodingError<any DummyNotice>)
  }
  #endif
}
