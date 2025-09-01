//
//  AnyCodableTests.swift
//  KarrotCodableKit
//
//  Created by Elon on 4/9/25.
//

import XCTest
@testable import KarrotCodableKit

final class AnyCodableTests: XCTestCase {

  @CustomCodable(codingKeyStyle: .snakeCase)
  struct SomeCodable {
    var string: String
    var int: Int
    var bool: Bool
    var hasUnderscore: String
  }

  func testJSONDecoding() throws {
    // given
    let json = """
      {
          "boolean": true,
          "integer": 42,
          "double": 3.141592653589793,
          "string": "string",
          "array": [1, 2, 3],
          "nested": {
              "a": "alpha",
              "b": "bravo",
              "c": "charlie"
          },
          "null": null
      }
      """.data(using: .utf8)!
    let decoder = JSONDecoder()

    // when
    let dictionary = try decoder.decode([String: AnyCodable].self, from: json)

    // then
    XCTAssertEqual(dictionary["boolean"]?.value as! Bool, true)
    XCTAssertEqual(dictionary["integer"]?.value as! Int, 42)
    XCTAssertEqual(dictionary["double"]?.value as! Double, 3.141592653589793, accuracy: 0.001)
    XCTAssertEqual(dictionary["string"]?.value as! String, "string")
    XCTAssertEqual(dictionary["array"]?.value as! [Int], [1, 2, 3])
    XCTAssertEqual(dictionary["nested"]?.value as! [String: String], ["a": "alpha", "b": "bravo", "c": "charlie"])
    XCTAssertEqual(dictionary["null"]?.value as! NSNull, NSNull())
  }

  func testJSONDecodingEquatable() throws {
    // given
    let json = """
      {
          "boolean": true,
          "integer": 42,
          "double": 3.141592653589793,
          "string": "string",
          "array": [1, 2, 3],
          "nested": {
              "a": "alpha",
              "b": "bravo",
              "c": "charlie"
          },
          "null": null
      }
      """.data(using: .utf8)!
    let decoder = JSONDecoder()

    // when
    let dictionary1 = try decoder.decode([String: AnyCodable].self, from: json)
    let dictionary2 = try decoder.decode([String: AnyCodable].self, from: json)

    // then
    XCTAssertEqual(dictionary1["boolean"], dictionary2["boolean"])
    XCTAssertEqual(dictionary1["integer"], dictionary2["integer"])
    XCTAssertEqual(dictionary1["double"], dictionary2["double"])
    XCTAssertEqual(dictionary1["string"], dictionary2["string"])
    XCTAssertEqual(dictionary1["array"], dictionary2["array"])
    XCTAssertEqual(dictionary1["nested"], dictionary2["nested"])
    XCTAssertEqual(dictionary1["null"], dictionary2["null"])
  }

  func testJSONEncoding() throws {
    // given
    let someCodable = AnyCodable(SomeCodable(
      string: "String",
      int: 100,
      bool: true,
      hasUnderscore: "another string"
    ))

    let injectedValue = 1234
    let dictionary: [String: AnyCodable] = [
      "boolean": true,
      "integer": 42,
      "double": 3.141592653589793,
      "string": "string",
      "stringInterpolation": "string \(injectedValue)",
      "array": [1, 2, 3],
      "nested": [
        "a": "alpha",
        "b": "bravo",
        "c": "charlie",
      ],
      "someCodable": someCodable,
      "null": nil,
    ]
    let encoder = JSONEncoder()

    // when
    let json = try encoder.encode(dictionary)
    let encodedJSONObject = try JSONSerialization.jsonObject(with: json) as! NSDictionary

    // then
    let expected = """
      {
          "boolean": true,
          "integer": 42,
          "double": 3.141592653589793,
          "string": "string",
          "stringInterpolation": "string 1234",
          "array": [1, 2, 3],
          "nested": {
              "a": "alpha",
              "b": "bravo",
              "c": "charlie"
          },
          "someCodable": {
              "string":"String",
              "int":100,
              "bool": true,
              "has_underscore":"another string"
          },
          "null": null
      }
      """.data(using: .utf8)!
    let expectedJSONObject = try JSONSerialization.jsonObject(with: expected) as! NSDictionary

    XCTAssertEqual(encodedJSONObject, expectedJSONObject)
  }
}
