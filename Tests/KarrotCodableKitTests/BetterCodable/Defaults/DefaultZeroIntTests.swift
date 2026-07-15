//
//  DefaultZeroIntTests.swift
//  KarrotCodableKitTests
//
//  Created by Elon on 2023/04/27.
//

import Foundation
import Testing

import KarrotCodableKit

struct DefaultZeroIntTests {
  struct Fixture: Equatable, Codable {
    @DefaultZeroInt var intValue: Int
  }

  @Test
  func `decoding failable int default zero int`() throws {
    // given
    let jsonData = #"{ "intValue": null }"#.data(using: .utf8)!

    // when
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)

    // then
    #expect(fixture.intValue == 0)
  }

  @Test
  func `decoding key not present default zero int`() throws {
    // given
    let jsonData = #"{}"#.data(using: .utf8)!

    // when
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)

    // then
    #expect(fixture.intValue == 0)
  }

  @Test
  func `decodin success default zero int`() throws {
    // given
    let jsonData = #"{ "intValue": 999 }"#.data(using: .utf8)!

    // when
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)

    // then
    #expect(fixture.intValue == 999)
  }
}
