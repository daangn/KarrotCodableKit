//
//  PolymorphicLossyArrayNullOutcomeTests.swift
//  KarrotCodableKit
//
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

import Testing
import Foundation

import KarrotCodableKit

/// Guards the shared `PolymorphicKeyPresence` null branch for `@PolymorphicLossyArray`.
///
/// Note: the container `decodeIfPresent(_:forKey:)` overload is not reached by synthesized `Codable`
/// (the wrapper's `wrappedValue` is a non-optional `[T]`, so the compiler calls `decode`). The
/// release-mode `outcome` is also a zero-size, non-`Equatable` value and thus unobservable. These
/// tests therefore characterize the observable `decode` null/missing behavior and its DEBUG outcome.
@Suite struct PolymorphicLossyArrayNullOutcomeTests {

  @Test func nullArrayDecodesToEmptyArray() throws {
    let json = #"{ "notices1": null }"#.data(using: .utf8)!

    let result = try JSONDecoder().decode(OptionalLossyArrayDummyResponse.self, from: json)

    #expect(result.notices1.isEmpty)
    #expect(result.notices2.isEmpty)
  }

  #if DEBUG
  @Test func nullArrayIsTreatedAsRecoveredNotSuccessful() throws {
    let json = #"{ "notices1": null }"#.data(using: .utf8)!

    let result = try JSONDecoder().decode(OptionalLossyArrayDummyResponse.self, from: json)

    // A null value must not be reported as a clean success.
    #expect(result.$notices1.outcome != .decodedSuccessfully)
    // A missing key is likewise recovered, not a clean success.
    #expect(result.$notices2.outcome != .decodedSuccessfully)
  }
  #endif
}
