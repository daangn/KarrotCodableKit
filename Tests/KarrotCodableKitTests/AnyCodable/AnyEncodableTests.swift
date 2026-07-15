//
//  AnyEncodableTests.swift
//  KarrotCodableKit
//
//  Created by Elon on 4/9/25.
//

import Foundation
import Testing
@testable import KarrotCodableKit

struct AnyEncodableTests {

  @CustomEncodable(codingKeyStyle: .snakeCase)
  struct SomeEncodable {
    var string: String
    var int: Int
    var bool: Bool
    var hasUnderscore: String
  }

  @Test
  func `JSON encoding`() throws {
    // given
    let someEncodable = AnyEncodable(SomeEncodable(
      string: "String",
      int: 100,
      bool: true,
      hasUnderscore: "another string",
    ))

    let dictionary: [String: AnyEncodable] = [
      "boolean": true,
      "integer": 42,
      "double": 3.141592653589793,
      "string": "string",
      "array": [1, 2, 3],
      "nested": [
        "a": "alpha",
        "b": "bravo",
        "c": "charlie",
      ],
      "someCodable": someEncodable,
      "null": nil,
    ]
    let encoder = JSONEncoder()

    // when
    let json = try encoder.encode(dictionary)
    let encodedJSONObject = try #require(try JSONSerialization.jsonObject(with: json, options: []) as? NSDictionary)

    // then
    let expected = """
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
          "someCodable": {
              "string":"String",
              "int":100,
              "bool": true,
              "has_underscore":"another string"
          },
          "null": null
      }
      """.data(using: .utf8)!
    let expectedJSONObject = try #require(try JSONSerialization.jsonObject(
      with: expected,
      options: [],
    ) as? NSDictionary)

    #expect(encodedJSONObject == expectedJSONObject)
  }

  @Test
  func `encode NS number`() throws {
    // given
    let dictionary: [String: NSNumber] = [
      "boolean": true,
      "char": -127,
      "int": -32767,
      "short": -32767,
      "long": -2147483647,
      "longlong": -9223372036854775807,
      "uchar": 255,
      "uint": 65535,
      "ushort": 65535,
      "ulong": 4294967295,
      "ulonglong": 18446744073709615,
      "double": 3.141592653589793,
    ]
    let encoder = JSONEncoder()

    // when
    let json = try encoder.encode(AnyEncodable(dictionary))
    let encodedJSONObject = try #require(try JSONSerialization.jsonObject(with: json, options: []) as? NSDictionary)

    // then
    let expected = """
      {
          "boolean": true,
          "char": -127,
          "int": -32767,
          "short": -32767,
          "long": -2147483647,
          "longlong": -9223372036854775807,
          "uchar": 255,
          "uint": 65535,
          "ushort": 65535,
          "ulong": 4294967295,
          "ulonglong": 18446744073709615,
          "double": 3.141592653589793,
      }
      """.data(using: .utf8)!
    let expectedJSONObject = try #require(try JSONSerialization.jsonObject(
      with: expected,
      options: [],
    ) as? NSDictionary)

    #expect(encodedJSONObject == expectedJSONObject)
    #expect(encodedJSONObject["boolean"] is Bool)

    #expect(encodedJSONObject["char"] is Int8)
    #expect(encodedJSONObject["int"] is Int16)
    #expect(encodedJSONObject["short"] is Int32)
    #expect(encodedJSONObject["long"] is Int32)
    #expect(encodedJSONObject["longlong"] is Int64)

    #expect(encodedJSONObject["uchar"] is UInt8)
    #expect(encodedJSONObject["uint"] is UInt16)
    #expect(encodedJSONObject["ushort"] is UInt32)
    #expect(encodedJSONObject["ulong"] is UInt32)
    #expect(encodedJSONObject["ulonglong"] is UInt64)

    #expect(encodedJSONObject["double"] is Double)
  }

  @Test
  func `string interpolation encoding`() throws {
    // given
    let dictionary: [String: AnyEncodable] = [
      "boolean": "\(true)",
      "integer": "\(42)",
      "double": "\(3.141592653589793)",
      "string": "\("string")",
      "array": "\([1, 2, 3])",
    ]
    let encoder = JSONEncoder()

    // when
    let json = try encoder.encode(dictionary)
    let encodedJSONObject = try #require(try JSONSerialization.jsonObject(with: json, options: []) as? NSDictionary)

    // then
    let expected = """
      {
          "boolean": "true",
          "integer": "42",
          "double": "3.141592653589793",
          "string": "string",
          "array": "[1, 2, 3]",
      }
      """.data(using: .utf8)!
    let expectedJSONObject = try #require(try JSONSerialization.jsonObject(
      with: expected,
      options: [],
    ) as? NSDictionary)

    #expect(encodedJSONObject == expectedJSONObject)
  }
}
