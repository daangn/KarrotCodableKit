//
//  DefaulEmptyDictionaryTests.swift
//  KarrotCodableKit
//
//  Created by Elon on 2023/04/25.
//

import Foundation
import Testing

import KarrotCodableKit

struct DefaultEmptyDictionaryTests {
  struct Fixture: Equatable, Codable {
    @DefaultEmptyDictionary var stringToInt: [String: Int]
  }

  @Test
  func `decoding failable dictionary defaults to empty dictionary`() throws {
    // given
    let jsonData = #"{ "stringToInt": null }"#.data(using: .utf8)!

    // when
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)

    // then
    #expect(fixture.stringToInt == [:])
  }

  @Test
  func `decoding key not present defaults to empty dictionary`() throws {
    // given
    let jsonData = #"{}"#.data(using: .utf8)!

    // when
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)

    // then
    #expect(fixture.stringToInt == [:])
  }

  @Test
  func `encoding decoded failable dictionary defaults to empty dictionary`() throws {
    // given
    let jsonData = #"{ "stringToInt": null }"#.data(using: .utf8)!
    var _fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)
    _fixture.stringToInt["one"] = 1

    // when
    let fixtureData = try JSONEncoder().encode(_fixture)
    let fixture = try JSONDecoder().decode(Fixture.self, from: fixtureData)

    // then
    #expect(fixture.stringToInt == ["one": 1])
  }

  @Test
  func `encoding decoded fulfillable dictionary retains contents`() throws {
    // given
    let jsonData = #"{ "stringToInt": {"one": 1, "two": 2} }"#.data(using: .utf8)!
    let _fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)

    // when
    let fixtureData = try JSONEncoder().encode(_fixture)
    let fixture = try JSONDecoder().decode(Fixture.self, from: fixtureData)

    // then
    #expect(fixture.stringToInt == ["one": 1, "two": 2])
  }
}
