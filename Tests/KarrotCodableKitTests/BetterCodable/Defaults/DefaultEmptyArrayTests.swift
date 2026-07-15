//
//  DefaultEmptyArrayTests.swift
//  KarrotCodableKitTests
//
//  Created by Elon on 2023/04/25.
//

import Foundation
import Testing

import KarrotCodableKit

struct DefaultEmptyArrayTests {
  struct Fixture: Equatable, Codable {
    struct NestedFixture: Equatable, Codable {
      var one: String
      var two: [String: [String]]
    }

    @DefaultEmptyArray var values: [Int]
    @DefaultEmptyArray var nonPrimitiveValues: [NestedFixture]
  }

  @Test
  func `decoding failable array defaults to empty array`() throws {
    // given
    let jsonData = #"{ "values": null, "nonPrimitiveValues": null }"#.data(using: .utf8)!

    // when
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)

    // then
    #expect(fixture.values == [])
    #expect(fixture.nonPrimitiveValues == [])
  }

  @Test
  func `decoding key not present defaults to empty array`() throws {
    // given
    let jsonData = #"{}"#.data(using: .utf8)!

    // when
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)

    // then
    #expect(fixture.values == [])
    #expect(fixture.nonPrimitiveValues == [])
  }

  @Test
  func `encoding decoded failable array defaults to empty array`() throws {
    // given
    let jsonData = #"{ "values": null, "nonPrimitiveValues": null }"#.data(using: .utf8)!
    var _fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)
    _fixture.values += [1, 2, 3]
    _fixture.nonPrimitiveValues += [Fixture.NestedFixture(one: "a", two: ["b": ["c"]])]

    // when
    let fixtureData = try JSONEncoder().encode(_fixture)
    let fixture = try JSONDecoder().decode(Fixture.self, from: fixtureData)

    // then
    #expect(fixture.values == [1, 2, 3])
    #expect(fixture.nonPrimitiveValues == [Fixture.NestedFixture(one: "a", two: ["b": ["c"]])])
  }

  @Test
  func `encoding decoded fulfillable array retains contents`() throws {
    // given
    let jsonData = #"{ "values": [1, 2], "nonPrimitiveValues": [{ "one": "one", "two": {"key": ["value"]}}] }"#
      .data(using: .utf8)!
    let _fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)

    // when
    let fixtureData = try JSONEncoder().encode(_fixture)
    let fixture = try JSONDecoder().decode(Fixture.self, from: fixtureData)

    // then
    #expect(fixture.values == [1, 2])
    #expect(fixture.nonPrimitiveValues == [Fixture.NestedFixture(one: "one", two: ["key": ["value"]])])
  }
}
