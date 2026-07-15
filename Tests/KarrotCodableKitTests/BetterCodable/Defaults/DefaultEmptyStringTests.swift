//
//  DefaultEmptyStringTests.swift
//  KarrotCodableKitTests
//
//  Created by Elon on 2023/04/27.
//  Copyright © 2023 Danggeun Market Inc. All rights reserved.
//

import Foundation
import Testing

import KarrotCodableKit

struct DefaultEmptyStringTests {
  struct Fixture: Equatable, Codable {
    @DefaultEmptyString var string: String
  }

  @Test
  func `decoding failable string default empty string`() throws {
    // given
    let jsonData = #"{ "string": null }"#.data(using: .utf8)!

    // when
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)

    // then
    #expect(fixture.string == "")
  }

  @Test
  func `decoding key not present default empty string`() throws {
    // given
    let jsonData = #"{}"#.data(using: .utf8)!

    // when
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)

    // then
    #expect(fixture.string == "")
  }

  @Test
  func `decodin success default empty string`() throws {
    // given
    let jsonData = #"{ "string": "hi" }"#.data(using: .utf8)!

    // when
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)

    // then
    #expect(fixture.string == "hi")
  }
}
