//
//  PolymorphicCodableStrategyProvidingMacroTests.swift
//
//
//  Created by Elon on 10/18/24.
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

import Foundation

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(KarrotCodableKitMacros)
import KarrotCodableKitMacros
#endif


final class PolymorphicCodableStrategyProvidingMacroTests: XCTestCase {

  #if canImport(KarrotCodableKitMacros)
  let testMacros: [String: Macro.Type] = [
    "PolymorphicCodableStrategyProviding": PolymorphicCodableStrategyProvidingMacro.self,
  ]
  #endif

  func testPolymorphicCodableStrategyProvidingMacro() throws {
    #if canImport(KarrotCodableKitMacros)
    assertMacroExpansion(
      """
      @PolymorphicCodableStrategyProviding(
        identifierCodingKey: "type",
        matchingTypes: [
          ActionableCallout.self,
          DismissibleCallout.self
        ],
        fallbackType: UndefinedCallout.self
      )
      public protocol Notice: Codable {
        var type: String { get }
        var title: String? { get }
        var description: String { get }
      }
      """,
      expandedSource: """

        public protocol Notice: Codable {
          var type: String { get }
          var title: String? { get }
          var description: String { get }
        }

        public struct NoticeCodableStrategy: PolymorphicCodableStrategy {
          enum PolymorphicMetaCodingKey: CodingKey {
            case type
          }

          public static var polymorphicMetaCodingKey: CodingKey {
            PolymorphicMetaCodingKey.type
          }

          public static func decode(from decoder: Decoder) throws -> Notice {
            try decoder.decode(
              codingKey: Self.polymorphicMetaCodingKey,
              matchingTypes: [
                ActionableCallout.self,
                DismissibleCallout.self
              ],
              fallbackType: UndefinedCallout.self
            )
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

  func testPolymorphicCodableStrategyProvidingMacroTypeError() {
    #if canImport(KarrotCodableKitMacros)
    assertMacroExpansion(
      """
      @PolymorphicCodableStrategyProviding(
        identifierCodingKey: "",
        matchingTypes: [],
        fallbackType: nil
      )
      struct Notice: Codable {
        var type: String
        var title: String?
        var description: String
      }
      """,
      expandedSource: """

        struct Notice: Codable {
          var type: String
          var title: String?
          var description: String
        }
        """,
      diagnostics: [
        DiagnosticSpec(
          message: "Macro must be attached to a protocol.",
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

  func testPolymorphicCodableStrategyProvidingMacroIdentifierCodingKeyValueError() {
    #if canImport(KarrotCodableKitMacros)
    assertMacroExpansion(
      """
      @PolymorphicCodableStrategyProviding(
        identifierCodingKey: "",
        matchingTypes: [],
        fallbackType: nil
      )
      protocol Notice: Codable {
        var type: String
        var title: String?
        var description: String
      }
      """,
      expandedSource: """

        protocol Notice: Codable {
          var type: String
          var title: String?
          var description: String
        }
        """,
      diagnostics: [
        DiagnosticSpec(
          message: "Invalid or missing identifierCodingKey: expected a non-empty string.",
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
