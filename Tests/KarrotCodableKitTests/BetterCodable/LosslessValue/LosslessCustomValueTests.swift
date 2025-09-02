//
//  LosslessCustomValueTests.swift
//  KarrotCodableKitTests
//
//  Created by Elon on 2023/04/25.
//

import XCTest

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

final class LosslessCustomValueTests: XCTestCase {
  struct Fixture: Equatable, Codable {
    @MyLosslessType var int: Int
    @MyLosslessType var string: String
    @MyLosslessType var fortytwo: Int
    @MyLosslessType var bool: Bool
  }

  func testDecodingCustomLosslessStrategyDecodesCorrectly() throws {
    // given
    let jsonData = #"{ "string": 7, "int": "1", "fortytwo": null, "bool": true }"#.data(using: .utf8)!

    // when
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)

    // then
    XCTAssertEqual(fixture.string, "7")
    XCTAssertEqual(fixture.int, 1)
    XCTAssertEqual(fixture.fortytwo, 42)
    XCTAssertEqual(fixture.bool, true)
  }

  func testDecodingCustomLosslessStrategyWithBrokenFieldsThrowsError() throws {
    // given
    let jsonData = #"{ "string": 7, "int": "1", "fortytwo": null, "bool": 9 }"#.data(using: .utf8)!

    // when/then
    XCTAssertThrowsError(try JSONDecoder().decode(Fixture.self, from: jsonData))
  }
}
