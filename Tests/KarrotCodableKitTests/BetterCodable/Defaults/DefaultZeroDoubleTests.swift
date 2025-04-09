//
//  DefaultZeroDoubleTests.swift
//  KarrotCodableKitTests
//
//  Created by Elon on 2023/04/27.
//  Copyright © 2023 Danggeun Market Inc. All rights reserved.
//

import XCTest

import KarrotCodableKit

final class DefaultZeroDoubleTests: XCTestCase {
  struct Fixture: Equatable, Codable {
    @DefaultZeroDouble var doubleValue: Double
  }

  func testDecodingFailableDoubleDefaultZeroDouble() throws {
    let jsonData = #"{ "doubleValue": null }"#.data(using: .utf8)!
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)
    XCTAssertEqual(fixture.doubleValue, 0.0)
  }

  func testDecodingKeyNotPresentDefaultZeroDouble() throws {
    let jsonData = #"{}"#.data(using: .utf8)!
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)
    XCTAssertEqual(fixture.doubleValue, 0.0)
  }

  func testDecodinSuccessDefaultZeroDouble() throws {
    let jsonData = #"{ "doubleValue": 0.001 }"#.data(using: .utf8)!
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)
    XCTAssertEqual(fixture.doubleValue, 0.001)
  }
}
