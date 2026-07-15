//
//  DataValueTests.swift
//  KarrotCodableKit
//
//  Created by Elon on 4/9/25.
//

import Foundation
import Testing

import KarrotCodableKit

struct DataValueTests {
  @Test
  func `decoding and encoding base 64 string`() throws {
    // given
    struct Fixture: Codable {
      @DataValue<Base64Strategy> var data: Data
    }
    let jsonData = #"{"data":"QmV0dGVyQ29kYWJsZQ=="}"#.data(using: .utf8)!

    // when
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)

    // then
    #expect(fixture.data == Data("BetterCodable".utf8))

    // when
    let outputJSON = try JSONEncoder().encode(fixture)

    // then
    #expect(outputJSON == jsonData)
  }

  @Test
  func `decoding malformed base 64 fails`() throws {
    // given
    struct Fixture: Codable {
      @DataValue<Base64Strategy> var data: Data
    }
    let jsonData = #"{"data":"invalidBase64!"}"#.data(using: .utf8)!

    // when & then
    #expect(throws: (any Error).self) { try JSONDecoder().decode(Fixture.self, from: jsonData) }
  }

  @Test
  func `decoding and encoding base 64 string to array`() throws {
    // given
    struct Fixture: Codable {
      @DataValue<Base64Strategy> var data: [UInt8]
    }
    let jsonData = #"{"data":"QmV0dGVyQ29kYWJsZQ=="}"#.data(using: .utf8)!

    // when
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)

    // then
    #expect(fixture.data == Array("BetterCodable".utf8))

    // when
    let outputJSON = try JSONEncoder().encode(fixture)

    // then
    #expect(outputJSON == jsonData)
  }
}
