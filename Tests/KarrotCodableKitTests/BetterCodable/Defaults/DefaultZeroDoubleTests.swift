//
//  DefaultZeroDoubleTests.swift
//  KarrotCodableKitTests
//
//  Created by Elon on 2023/04/27.
//  Copyright © 2023 Danggeun Market Inc. All rights reserved.
//

import Testing
import Foundation

import KarrotCodableKit

struct DefaultZeroDoubleTests {
  struct Fixture: Equatable, Codable {
    @DefaultZeroDouble var doubleValue: Double
  }

  @Test func testDecodingFailableDoubleDefaultZeroDouble() throws {
    // given
    let jsonData = #"{ "doubleValue": null }"#.data(using: .utf8)!

    // when
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)

    // then
    #expect(fixture.doubleValue == 0.0)
  }

  @Test func testDecodingKeyNotPresentDefaultZeroDouble() throws {
    // given
    let jsonData = #"{}"#.data(using: .utf8)!

    // when
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)

    // then
    #expect(fixture.doubleValue == 0.0)
  }

  @Test func testDecodinSuccessDefaultZeroDouble() throws {
    // given
    let jsonData = #"{ "doubleValue": 0.001 }"#.data(using: .utf8)!

    // when
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)

    // then
    #expect(fixture.doubleValue == 0.001)
  }
}
