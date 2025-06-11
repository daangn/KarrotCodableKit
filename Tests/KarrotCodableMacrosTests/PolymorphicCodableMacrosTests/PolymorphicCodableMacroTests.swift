//
//  PolymorphicCodableMacroTests.swift
//
//
//  Created by Elon on 10/19/24.
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

import Foundation

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(KarrotCodableKitMacros)
import KarrotCodableKitMacros
#endif

final class PolymorphicCodableMacroTests: XCTestCase {

  #if canImport(KarrotCodableKitMacros)
  let testMacros: [String: Macro.Type] = [
    "PolymorphicCodable": PolymorphicCodableMacro.self,
  ]
  #endif

  func testPolymorphicCodableMacro() throws {
    #if canImport(KarrotCodableKitMacros)
    assertMacroExpansion(
      """
      @PolymorphicCodable(
        identifier: "dismissible-callout",
        codingKeyStyle: .snakeCase
      )
      public struct DismissibleCallout: Notice {
        let type: String
        let noticeTitle: String?
        let description: String
        let key: String
      }
      """,
      expandedSource: """

        public struct DismissibleCallout: Notice {
          let type: String
          let noticeTitle: String?
          let description: String
          let key: String

          private enum CodingKeys: String, CodingKey {
            case type
            case noticeTitle = "notice_title"
            case description
            case key
          }
        }

        extension DismissibleCallout: PolymorphicCodableType {
          public static var polymorphicIdentifier: String {
            "dismissible-callout"
          }
        }
        """,
      macros: testMacros,
      indentationWidth: .spaces(2)
    )
    #else
    throw XCTSkip("macros are only supported when running tests for the host platform")
    #endif
  }

  func testPolymorphicCodableMacroIdentifierValueError() {
    #if canImport(KarrotCodableKitMacros)
    assertMacroExpansion(
      """
      @PolymorphicCodable(identifier: "")
      struct DismissibleCallout: Notice {
        let type: String
        let noticeTitle: String?
        let description: String
        let key: String
      }
      """,
      expandedSource: """
        struct DismissibleCallout: Notice {
          let type: String
          let noticeTitle: String?
          let description: String
          let key: String

          private enum CodingKeys: String, CodingKey {
            case type
            case noticeTitle
            case description
            case key
          }
        }
        """,
      diagnostics: [
        DiagnosticSpec(
          message: "Invalid polymorphic identifier: expected a non-empty string.",
          line: 1,
          column: 1
        )
      ],
      macros: testMacros,
      indentationWidth: .spaces(2)
    )
    #else
    throw XCTSkip("macros are only supported when running tests for the host platform")
    #endif
  }
}
