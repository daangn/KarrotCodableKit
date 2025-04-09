//
//  StringSnakeCaseTests.swift
//  KarrotCodableKit
//
//  Created by elon on 1/4/23.
//
//  Based on code from the Swift.org open source project.
//
//  Copyright (c) 2014 - 2017 Apple Inc. and the Swift project authors
//  Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://github.com/daangn/KarrotCodableKit/ThirdPartyLicenses/swiftlang/swift-foundation for license information
//

import Foundation

import XCTest

@testable import KarrotCodableKitMacros

final class StringSnakeCaseTests: XCTestCase {
  func test_convert_to_snake_case() {
    // given
    let toSnakeCaseTests: [(camelCase: String, snake_case: String)] = [
      ("simpleOneTwo", "simple_one_two"),
      ("myURL", "my_url"),
      ("singleCharacterAtEndX", "single_character_at_end_x"),
      ("thisIsAnXMLProperty", "this_is_an_xml_property"),
      ("single", "single"), // no underscore
      ("", ""), // don't die on empty string
      ("a", "a"), // single character
      ("aA", "a_a"), // two characters
      ("version4Thing", "version4_thing"), // numerics
      ("partCAPS", "part_caps"), // only insert underscore before first all caps
      ("partCAPSLowerAGAIN", "part_caps_lower_again"), // switch back and forth caps.
      ("manyWordsInThisThing", "many_words_in_this_thing"), // simple lowercase + underscore + more
      ("asdfĆqer", "asdf_ćqer"),
      ("already_snake_case", "already_snake_case"),
      ("dataPoint22", "data_point22"),
      ("dataPoint22Word", "data_point22_word"),
      ("_oneTwoThree", "_one_two_three"),
      ("oneTwoThree_", "one_two_three_"),
      ("__oneTwoThree", "__one_two_three"),
      ("oneTwoThree__", "one_two_three__"),
      ("_oneTwoThree_", "_one_two_three_"),
      ("__oneTwoThree", "__one_two_three"),
      ("__oneTwoThree__", "__one_two_three__"),
      ("_test", "_test"),
      ("_test_", "_test_"),
      ("__test", "__test"),
      ("test__", "test__"),
      ("m͉̟̹y̦̳G͍͚͎̳r̤͉̤͕ͅea̲͕t͇̥̼͖U͇̝̠R͙̻̥͓̣L̥̖͎͓̪̫ͅR̩͖̩eq͈͓u̞e̱s̙t̤̺ͅ", "m͉̟̹y̦̳_g͍͚͎̳r̤͉̤͕ͅea̲͕t͇̥̼͖_u͇̝̠r͙̻̥͓̣l̥̖͎͓̪̫ͅ_r̩͖̩eq͈͓u̞e̱s̙t̤̺ͅ"), // because Itai wanted to test this
      ("🐧🐟", "🐧🐟"), // fishy emoji example?
    ]

    // when
    for test in toSnakeCaseTests {
      let expected = test.camelCase.toSnakeCase

      // then
      XCTAssertEqual(test.snake_case, expected)
    }
  }
}
