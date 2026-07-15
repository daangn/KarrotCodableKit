//
//  DefaultEmptyStringTests.swift
//  KarrotCodableKitTests
//
//  Created by Elon on 2023/04/27.
//  Copyright © 2023 Danggeun Market Inc. All rights reserved.
//

import Testing
import Foundation

import KarrotCodableKit

struct DefaultEmptyStringTests {
  struct Fixture: Equatable, Codable {
    @DefaultEmptyString var string: String
  }

  @Test func testDecodingFailableStringDefaultEmptyString() throws {
    // given
    let jsonData = #"{ "string": null }"#.data(using: .utf8)!

    // when
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)

    // then
    #expect(fixture.string == "")
  }

  @Test func testDecodingKeyNotPresentDefaultEmptyString() throws {
    // given
    let jsonData = #"{}"#.data(using: .utf8)!

    // when
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)

    // then
    #expect(fixture.string == "")
  }

  @Test func testDecodinSuccessDefaultEmptyString() throws {
    // given
    let jsonData = #"{ "string": "hi" }"#.data(using: .utf8)!

    // when
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)

    // then
    #expect(fixture.string == "hi")
  }
}
