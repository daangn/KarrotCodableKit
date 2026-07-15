//
//  DefaultZeroDoubleTests.swift
//  KarrotCodableKitTests
//
//  Created by Elon on 2023/04/27.
//  Copyright © 2023 Danggeun Market Inc. All rights reserved.
//

import Foundation
import Testing

import KarrotCodableKit

struct DefaultZeroDoubleTests {
  struct Fixture: Equatable, Codable {
    @DefaultZeroDouble var doubleValue: Double
  }

  @Test
  func `decoding failable double default zero double`() throws {
    // given
    let jsonData = #"{ "doubleValue": null }"#.data(using: .utf8)!

    // when
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)

    // then
    #expect(fixture.doubleValue == 0.0)
  }

  @Test
  func `decoding key not present default zero double`() throws {
    // given
    let jsonData = #"{}"#.data(using: .utf8)!

    // when
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)

    // then
    #expect(fixture.doubleValue == 0.0)
  }

  @Test
  func `decodin success default zero double`() throws {
    // given
    let jsonData = #"{ "doubleValue": 0.001 }"#.data(using: .utf8)!

    // when
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)

    // then
    #expect(fixture.doubleValue == 0.001)
  }
}
