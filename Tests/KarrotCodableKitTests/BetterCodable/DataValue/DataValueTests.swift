//
//  DataValueTests.swift
//  KarrotCodableKit
//
//  Created by Elon on 4/9/25.
//

import XCTest

import KarrotCodableKit

final class DataValueTests: XCTestCase {
  func testDecodingAndEncodingBase64String() throws {
    // given
    struct Fixture: Codable {
      @DataValue<Base64Strategy> var data: Data
    }
    let jsonData = #"{"data":"QmV0dGVyQ29kYWJsZQ=="}"#.data(using: .utf8)!

    // when
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)

    // then
    XCTAssertEqual(fixture.data, Data("BetterCodable".utf8))

    // when
    let outputJSON = try JSONEncoder().encode(fixture)

    // then
    XCTAssertEqual(outputJSON, jsonData)
  }

  func testDecodingMalformedBase64Fails() throws {
    // given
    struct Fixture: Codable {
      @DataValue<Base64Strategy> var data: Data
    }
    let jsonData = #"{"data":"invalidBase64!"}"#.data(using: .utf8)!

    // when & then
    XCTAssertThrowsError(try JSONDecoder().decode(Fixture.self, from: jsonData))
  }

  func testDecodingAndEncodingBase64StringToArray() throws {
    // given
    struct Fixture: Codable {
      @DataValue<Base64Strategy> var data: [UInt8]
    }
    let jsonData = #"{"data":"QmV0dGVyQ29kYWJsZQ=="}"#.data(using: .utf8)!

    // when
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)

    // then
    XCTAssertEqual(fixture.data, Array("BetterCodable".utf8))

    // when
    let outputJSON = try JSONEncoder().encode(fixture)

    // then
    XCTAssertEqual(outputJSON, jsonData)
  }
}
