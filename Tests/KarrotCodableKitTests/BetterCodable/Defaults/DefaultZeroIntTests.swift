//
//  DefaultZeroIntTests.swift
//  KarrotCodableKitTests
//
//  Created by Elon on 2023/04/27.
//

import Testing
import Foundation

import KarrotCodableKit

struct DefaultZeroIntTests {
  struct Fixture: Equatable, Codable {
    @DefaultZeroInt var intValue: Int
  }

  @Test func testDecodingFailableIntDefaultZeroInt() throws {
    // given
    let jsonData = #"{ "intValue": null }"#.data(using: .utf8)!

    // when
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)

    // then
    #expect(fixture.intValue == 0)
  }

  @Test func testDecodingKeyNotPresentDefaultZeroInt() throws {
    // given
    let jsonData = #"{}"#.data(using: .utf8)!

    // when
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)

    // then
    #expect(fixture.intValue == 0)
  }

  @Test func testDecodinSuccessDefaultZeroInt() throws {
    // given
    let jsonData = #"{ "intValue": 999 }"#.data(using: .utf8)!

    // when
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)

    // then
    #expect(fixture.intValue == 999)
  }
}
