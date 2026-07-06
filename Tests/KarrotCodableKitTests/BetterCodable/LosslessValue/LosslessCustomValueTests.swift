//
//  LosslessCustomValueTests.swift
//  KarrotCodableKitTests
//
//  Created by Elon on 2023/04/25.
//

import Testing
import Foundation

import KarrotCodableKit

struct MyLosslessStrategy<Value: LosslessStringCodable>: LosslessDecodingStrategy {
  static var losslessDecodableTypes: [(Decoder) -> LosslessStringCodable?] {
    [
      { try? String(from: $0) },
      { try? Bool(from: $0) },
      { try? Int(from: $0) },
      { _ in 42 },
    ]
  }
}

typealias MyLosslessType<T> = LosslessValueCodable<MyLosslessStrategy<T>> where T: LosslessStringCodable

struct LosslessCustomValueTests {
  struct Fixture: Equatable, Codable {
    @MyLosslessType var int: Int
    @MyLosslessType var string: String
    @MyLosslessType var fortytwo: Int
    @MyLosslessType var bool: Bool
  }

  @Test func testDecodingCustomLosslessStrategyDecodesCorrectly() throws {
    // given
    let jsonData = #"{ "string": 7, "int": "1", "fortytwo": null, "bool": true }"#.data(using: .utf8)!

    // when
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)

    // then
    #expect(fixture.string == "7")
    #expect(fixture.int == 1)
    #expect(fixture.fortytwo == 42)
    #expect(fixture.bool == true)
  }

  @Test func testDecodingCustomLosslessStrategyWithBrokenFieldsThrowsError() throws {
    // given
    let jsonData = #"{ "string": 7, "int": "1", "fortytwo": null, "bool": 9 }"#.data(using: .utf8)!

    // when/then
    #expect(throws: (any Error).self) { try JSONDecoder().decode(Fixture.self, from: jsonData) }
  }
}
