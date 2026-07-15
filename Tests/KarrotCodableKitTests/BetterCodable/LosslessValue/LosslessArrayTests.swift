//
//  LosslessArrayTests.swift
//  KarrotCodableKitTests
//
//  Created by Elon on 2023/04/25.
//

import Foundation
import Testing

import KarrotCodableKit

struct LosslessArrayTests {
  struct Fixture: Equatable, Codable {
    @LosslessArray var values: [Int]
  }

  struct Fixture2: Equatable, Codable {
    @LosslessArray var values: [String]
  }

  @Test
  func `decoding lossless array acts like lossy array`() throws {
    // given
    let jsonData = #"{ "values": [1, null, 3, 4] }"#.data(using: .utf8)!

    // when
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)

    // then
    #expect(fixture.values == [1, 3, 4])
  }

  @Test
  func `decoding ints converts strings into lossless elements`() throws {
    // given
    let jsonData = #"{ "values": ["1", 2, null, "4"] }"#.data(using: .utf8)!

    // when
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)

    // then
    #expect(fixture.values == [1, 2, 4])
  }

  @Test
  func `decoding strings preserves lossless elements`() throws {
    // given
    let jsonData = #"{ "values": ["1", 2, 3.14, null, false, "4"] }"#.data(using: .utf8)!

    // when
    let fixture = try JSONDecoder().decode(Fixture2.self, from: jsonData)

    // then
    #expect(fixture.values == ["1", "2", "3.14", "false", "4"])
  }

  @Test
  func `encoding decoded lossless array ignores failable elements`() throws {
    // given
    let jsonData = #"{ "values": [null, "2", null, 4] }"#.data(using: .utf8)!

    // when
    var _fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)

    _fixture.values += [5]

    // when
    let fixtureData = try JSONEncoder().encode(_fixture)
    // when
    let fixture = try JSONDecoder().decode(Fixture.self, from: fixtureData)

    // then
    #expect(fixture.values == [2, 4, 5])
  }

  @Test
  func `encoding decoded lossless array retains contents`() throws {
    // given
    let jsonData = #"{ "values": [1, 2, "3"] }"#.data(using: .utf8)!

    // when
    let _fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)
    // when
    let fixtureData = try JSONEncoder().encode(_fixture)
    // when
    let fixture = try JSONDecoder().decode(Fixture.self, from: fixtureData)

    // then
    #expect(fixture.values == [1, 2, 3])
  }
}
