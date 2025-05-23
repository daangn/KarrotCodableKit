//
//  String+SnakeCase.swift
//
//
//  Created by Elon on 1/4/23.
//
//  Based on code from the Swift.org open source project.
//
//  Copyright (c) 2014 - 2017 Apple Inc. and the Swift project authors
//  Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://github.com/daangn/KarrotCodableKit/ThirdPartyLicenses/swiftlang/swift-foundation for license information
//

import Foundation

extension String {

  /// camelCase to snake_case
  ///
  /// from [Apple JSONEncoder](https://github.com/swiftlang/swift-foundation/blob/main/Sources/FoundationEssentials/JSON/JSONEncoder.swift#L132)
  ///
  /// Capital characters are determined by testing membership in Unicode General Categories Lu and Lt.
  /// The conversion to lower case uses `Locale.system`, also known as the ICU "root" locale. This means the result is consistent regardless of the current user's locale and language preferences.
  ///
  /// Converting from camel case to snake case:
  /// 1. Splits words at the boundary of lower-case to upper-case
  /// 2. Inserts `_` between words
  /// 3. Lowercases the entire string
  /// 4. Preserves starting and ending `_`.
  ///
  /// For example, `oneTwoThree` becomes `one_two_three`. `_oneTwoThree_` becomes `_one_two_three_`.
  ///
  /// - Note: Using this conversion has a nominal performance cost, as each string key has to be converted.
  var toSnakeCase: String {
    guard !isEmpty else { return self }

    var words = [Range<String.Index>]()
    // The general idea of this algorithm is to split words on transition from lower to upper case,
    // then on transition of >1 upper case characters to lowercase
    //
    // myProperty -> my_property
    // myURLProperty -> my_url_property
    //
    // We assume, per Swift naming conventions, that the first character of the key is lowercase.
    var wordStart = startIndex
    var searchRange = index(after: wordStart)..<endIndex

    // Find next uppercase character
    while let upperCaseRange = rangeOfCharacter(from: .uppercaseLetters, range: searchRange) {
      let untilUpperCase = wordStart..<upperCaseRange.lowerBound
      words.append(untilUpperCase)

      // Find next lowercase character
      searchRange = upperCaseRange.lowerBound..<searchRange.upperBound
      guard let lowerCaseRange = rangeOfCharacter(from: .lowercaseLetters, range: searchRange) else {
        // There are no more lower case letters. Just end here.
        wordStart = searchRange.lowerBound
        break
      }

      // Is the next lowercase letter more than 1 after the uppercase?
      // If so, we encountered a group of uppercase letters that we should treat as its own word
      let nextCharacterAfterCapital = index(after: upperCaseRange.lowerBound)
      if lowerCaseRange.lowerBound == nextCharacterAfterCapital {
        // The next character after capital is a lower case character and therefore not a word boundary.
        // Continue searching for the next upper case for the boundary.
        wordStart = upperCaseRange.lowerBound
      } else {
        // There was a range of >1 capital letters. Turn those into a word,
        // stopping at the capital before the lower case character.
        let beforeLowerIndex = index(before: lowerCaseRange.lowerBound)
        words.append(upperCaseRange.lowerBound..<beforeLowerIndex)

        // Next word starts at the capital before the lowercase we just found
        wordStart = beforeLowerIndex
      }
      searchRange = lowerCaseRange.upperBound..<searchRange.upperBound
    }
    words.append(wordStart..<searchRange.upperBound)

    let result = words.map { range in
      self[range].lowercased()
    }.joined(separator: "_")

    return result
  }
}
