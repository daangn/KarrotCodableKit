//
//  PolymorphicEnumCodableFactory.swift
//  KarrotCodableKit
//
//  Created by Elon on 10/21/24.
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

import SwiftSyntax
import SwiftSyntaxBuilder

enum PolymorphicEnumCodableFactory {

  struct CaseInfo {
    let name: String
    let parameterName: String
    let associatedType: TypeSyntax
  }

  static func makePolymorphicMetaCodingKey(with identifierCodingKey: String) -> String {
    """
    enum PolymorphicMetaCodingKey: CodingKey {
      case \(identifierCodingKey)
    }
    """
  }

  static func makeInitFromDecoder(
    with caseInfos: [CaseInfo],
    identifierCodingKey: String,
    accessLevel: String,
    fallbackCaseName: String?
  ) -> String {
    let caseSwitches = caseInfos.map { caseInfo in
      """
      case \(caseInfo.associatedType).polymorphicIdentifier:
          self = .\(caseInfo.name)(\(caseInfo.parameterName)try \(caseInfo.associatedType)(from: decoder))
      """
    }.joined(separator: "\n   ")

    var defaultCase: String {
      if let fallbackCaseName {
        let fallbackCase = caseInfos.first { $0.name == fallbackCaseName }
        guard let fallbackCase else { return "" } // This will be caught by validateFallbackCaseName
        return """
          default:
              self = .\(fallbackCaseName)(\(fallbackCase.parameterName)try \(fallbackCase.associatedType)(from: decoder))
          """
      } else {
        return """
          default:
              throw PolymorphicCodableError.unableToFindPolymorphicType(type)
          """
      }
    }

    return """
      \(accessLevel)init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: PolymorphicMetaCodingKey.self)
        let type = try container.decode(String.self, forKey: PolymorphicMetaCodingKey.\(identifierCodingKey))

        switch type {
        \(caseSwitches)
        \(defaultCase)
        }
      }
      """
  }

  static func makeEncodeToEncoder(
    with caseInfos: [CaseInfo],
    accessLevel: String
  ) -> String {
    let encodeSwitches = caseInfos.map { caseInfo in
      """
      case .\(caseInfo.name)(let value):
          try value.encode(to: encoder)
      """
    }.joined(separator: "\n   ")

    return """
      \(accessLevel)func encode(to encoder: any Encoder) throws {
        switch self {
        \(encodeSwitches)
        }
      }
      """
  }

  /// Validates and extracts the identifierCodingKey from the attribute arguments
  @discardableResult
  static func validateIdentifierCodingKey(in node: AttributeSyntax) throws -> String {
    let identifierCodingKeyString = node.arguments?.as(LabeledExprListSyntax.self)
      .flatMap {
        SyntaxHelper.findArgument(named: "identifierCodingKey", in: $0)
      }
      .flatMap {
        SyntaxHelper.extractString(from: $0)
      } ?? "type"

    guard !identifierCodingKeyString.isEmpty else {
      throw CodableKitError.message("Invalid polymorphic identifier: expected a non-empty string.")
    }

    return identifierCodingKeyString
  }

  /// Validates and extracts the fallbackCaseName from the attribute arguments
  static func validateFallbackCaseName(
    in node: AttributeSyntax,
    caseInfos: [CaseInfo]
  ) throws -> String? {
    let fallbackCaseNameString = node.arguments?.as(LabeledExprListSyntax.self)
      .flatMap {
        SyntaxHelper.findArgument(named: "fallbackCaseName", in: $0)
      }
      .flatMap {
        SyntaxHelper.extractString(from: $0)
      }

    guard let fallbackCaseNameString, !fallbackCaseNameString.isEmpty else {
      // fallbackCaseName is nil or empty
      if let fallbackCaseNameString, fallbackCaseNameString.isEmpty {
        throw CodableKitError.message("Invalid fallback case name: expected a non-empty string.")
      }
      return nil
    }

    // Verify the fallback case exists in the enum
    let fallbackCaseExists = caseInfos.contains { $0.name == fallbackCaseNameString }
    guard fallbackCaseExists else {
      throw CodableKitError.message("Missing fallback case: should be defined as `case \(fallbackCaseNameString)")
    }

    return fallbackCaseNameString
  }

  /// Extracts case information from the Enum declaration and ensures cases have a single associated value
  static func extractCaseInfos(from enumDecl: EnumDeclSyntax) throws -> [CaseInfo] {
    try enumDecl.memberBlock.members
      .compactMap { $0.decl.as(EnumCaseDeclSyntax.self) }
      .flatMap(\.elements)
      .map { element in
        let caseName = element.name.text
        let associatedValues = element.parameterClause?.parameters ?? []

        // Ensure only one associated value per case
        if associatedValues.count > 1 {
          throw CodableKitError.message("Polymorphic Enum cases can only have one associated value")
        }

        guard let associatedValue = associatedValues.first else {
          throw CodableKitError.message("Polymorphic Enum cases should have one associated value")
        }

        // Handle optional parameter names (with or without labels)
        let parameterName = associatedValue.firstName.flatMap {
          $0.tokenKind == .wildcard ? nil : "\($0.text): "
        } ?? ""

        return CaseInfo(
          name: caseName,
          parameterName: parameterName,
          associatedType: associatedValue.type
        )
      }
  }
}
