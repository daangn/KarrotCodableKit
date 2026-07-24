//
//  TrimmingBackticksTests.swift
//  KarrotCodableKit
//
//  Created by elon on 6/11/25.
//

import Testing

@testable import KarrotCodableKitMacros

struct TrimmingBackticksTests {
  @Test(arguments: [
    ("``", ""),
    ("```", ""),
    ("`class`", "class"),
    ("`func`", "func"),
    ("`var`", "var"),
    ("`let`", "let"),
    ("`if`", "if"),
    ("`else`", "else"),
    ("`return`", "return"),
    ("`for`", "for"),
    ("`in`", "in"),
    ("`while`", "while"),
    ("`do`", "do"),
  ])
  func `Trimming backticks`(testValues: (given: String, then: String)) {
    #expect(testValues.given.trimmingBackticks == testValues.then)
  }
}
