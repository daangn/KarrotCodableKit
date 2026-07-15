//
//  DefaultZeroFloatTests.swift
//  KarrotCodableKitTests
//
//  Created by daniel on 2023/10/11.
//  Copyright © 2023 Danggeun Market Inc. All rights reserved.
//

import Foundation
import Testing

import KarrotCodableKit

struct DefaultZeroFloatTests {
  struct Fixture: Equatable, Codable {
    @DefaultZeroFloat var floatValue: Float
  }

  @Test
  func `decoding failable float default zero float`() throws {
    // given
    let jsonData = #"{ "floatValue": null }"#.data(using: .utf8)!

    // when
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)

    // then
    #expect(fixture.floatValue == 0.0)
  }

  @Test
  func `decoding key not present default zero float`() throws {
    // given
    let jsonData = #"{}"#.data(using: .utf8)!

    // when
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)

    // then
    #expect(fixture.floatValue == 0.0)
  }

  @Test
  func `decodin success default zero float`() throws {
    // given
    let jsonData = #"{ "floatValue": 0.001 }"#.data(using: .utf8)!

    // when
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)

    // then
    #expect(fixture.floatValue == 0.001)
  }
}
