//
//  DefaultZeroIntTests.swift
//  KarrotCodableKitTests
//
//  Created by Elon on 2023/04/27.
//

import XCTest

import KarrotCodableKit

final class DefaultZeroIntTests: XCTestCase {
  struct Fixture: Equatable, Codable {
    @DefaultZeroInt var intValue: Int
  }

  func testDecodingFailableIntDefaultZeroInt() throws {
    let jsonData = #"{ "intValue": null }"#.data(using: .utf8)!
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)
    XCTAssertEqual(fixture.intValue, 0)
  }

  func testDecodingKeyNotPresentDefaultZeroInt() throws {
    let jsonData = #"{}"#.data(using: .utf8)!
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)
    XCTAssertEqual(fixture.intValue, 0)
  }

  func testDecodinSuccessDefaultZeroInt() throws {
    let jsonData = #"{ "intValue": 999 }"#.data(using: .utf8)!
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)
    XCTAssertEqual(fixture.intValue, 999)
  }
}
