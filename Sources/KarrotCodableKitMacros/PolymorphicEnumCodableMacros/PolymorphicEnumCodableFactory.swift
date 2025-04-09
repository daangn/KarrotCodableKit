//
//  PolymorphicEnumCodableFactory.swift
//
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
    accessLevel: String
  ) -> String {
    let caseSwitches = caseInfos.map { caseInfo in
      """
      case \(caseInfo.associatedType).polymorphicIdentifier:
          self = .\(caseInfo.name)(\(caseInfo.parameterName)try \(caseInfo.associatedType)(from: decoder))
      """
    }.joined(separator: "\n   ")

    return """
      \(accessLevel)init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: PolymorphicMetaCodingKey.self)
        let type = try container.decode(String.self, forKey: PolymorphicMetaCodingKey.\(identifierCodingKey))

        switch type {
        \(caseSwitches)
        default:
          throw PolymorphicCodableError.unableToFindPolymorphicType(type)
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
  @discardableResult static func validateIdentifierCodingKey(in node: AttributeSyntax) throws -> String {
    guard let arguments = node.arguments?.as(LabeledExprListSyntax.self),
          let identifierCodingKey = SyntaxHelper.findArgument(named: "identifierCodingKey", in: arguments),
          let identifierCodingKeyString = SyntaxHelper.extractString(from: identifierCodingKey)
    else {
      throw CodableKitError.message("Invalid or missing identifierCodingKey argument.")
    }

    guard !identifierCodingKeyString.isEmpty else {
      throw CodableKitError.message("Invalid or missing polymorphic identifier: expected a non-empty string.")
    }

    return identifierCodingKeyString
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
