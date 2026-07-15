//
//  LossyDictionaryTests.swift
//  KarrotCodableKitTests
//
//  Created by Elon on 2023/04/25.
//

import Testing
import Foundation

import KarrotCodableKit

struct LossyDictionaryTests {
  struct Fixture: Equatable, Codable {
    @LossyDictionary var stringToInt: [String: Int]
    @LossyDictionary var intToString: [Int: String]
  }

  @Test func testDecodingLossyDictionaryIgnoresFailableElements() throws {
    // given
    let jsonData = """
      {
          "stringToInt": {
              "one": 1,
              "two": 2,
              "three": null
          },
          "intToString": {
              "1": "one",
              "2": "two",
              "3": null
          }
      }
      """.data(using: .utf8)!

    // when
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)

    // then
    #expect(fixture.stringToInt == ["one": 1, "two": 2])
    #expect(fixture.intToString == [1: "one", 2: "two"])
  }

  @Test func testEncodingDecodedLossyDictionaryIgnoresFailableElements() throws {
    // given
    let jsonData = """
      {
          "stringToInt": {
              "one": 1,
              "two": 2,
              "three": null
          },
          "intToString": {
              "1": "one",
              "2": "two",
              "3": null
          }
      }
      """.data(using: .utf8)!
    var _fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)
    _fixture.stringToInt["three"] = 3
    _fixture.intToString[3] = "three"

    // when
    let fixtureData = try JSONEncoder().encode(_fixture)
    let fixture = try JSONDecoder().decode(Fixture.self, from: fixtureData)

    // then
    #expect(fixture.stringToInt == ["one": 1, "two": 2, "three": 3])
    #expect(fixture.intToString == [1: "one", 2: "two", 3: "three"])
  }

  @Test func testEncodingDecodedLosslessArrayRetainsContents() throws {
    // given
    let jsonData = """
      {
          "stringToInt": {
              "one": 1,
              "two": 2,
              "three": 3
          },
          "intToString": {
              "1": "one",
              "2": "two",
              "3": "three"
          }
      }
      """.data(using: .utf8)!

    // when
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)

    // then
    #expect(fixture.stringToInt == ["one": 1, "two": 2, "three": 3])
    #expect(fixture.intToString == [1: "one", 2: "two", 3: "three"])
  }

  @Test func testEncodingLosslessDictionaryRetainsKeys() throws {
    // given
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    let encoder = JSONEncoder()
    encoder.keyEncodingStrategy = .convertToSnakeCase
    let fixture = Fixture(
      stringToInt: [
        "snake_case.with.dots_99.and_numbers": 1,
        "dots.and_2.00.1_numbers": 2,
        "key.1": 3,
        "normal key": 4,
        "another_key": 5,
      ],
      intToString: [:]
    )

    // when
    let reencodedFixture = try decoder.decode(Fixture.self, from: encoder.encode(fixture))

    // then
    #expect(reencodedFixture == fixture)
  }
}
