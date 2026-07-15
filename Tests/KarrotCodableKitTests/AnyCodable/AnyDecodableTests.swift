//
//  AnyDecodableTests.swift
//  KarrotCodableKit
//
//  Created by Elon on 4/9/25.
//

import Foundation
import Testing
@testable import KarrotCodableKit

struct AnyDecodableTests {
  @Test
  func `JSON decoding`() throws {
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
    let dictionary = try decoder.decode([String: AnyDecodable].self, from: json)

    // then
    #expect(dictionary["boolean"]?.value as? Bool == true)
    #expect(dictionary["integer"]?.value as? Int == 42)
    #expect(abs(try #require(dictionary["double"]?.value as? Double) - 3.141592653589793) < 0.001)
    #expect(dictionary["string"]?.value as? String == "string")
    #expect(dictionary["array"]?.value as? [Int] == [1, 2, 3])
    #expect(dictionary["nested"]?.value as? [String: String] == ["a": "alpha", "b": "bravo", "c": "charlie"])
    #expect(dictionary["null"]?.value as? NSNull == NSNull())
  }
}
