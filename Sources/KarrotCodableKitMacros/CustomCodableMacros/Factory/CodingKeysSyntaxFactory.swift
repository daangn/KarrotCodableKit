//
//  CodingKeysSyntaxFactory.swift
//  KarrotCodableKit
//
//  Created by Elon on 4/8/25.
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//
//

import SwiftSyntax
import SwiftSyntaxMacros

final class CodingKeysSyntaxFactory {

  static func makeCodingKeysSyntax(from declaration: some DeclGroupSyntax) throws -> DeclSyntax {
    guard !declaration.is(EnumDeclSyntax.self) else { throw CodableKitError.cannotApplyToEnum }

    let cases = makeCodingKeysCases(from: declaration)
    return """
      enum CodingKeys: String, CodingKey {
        \(raw: cases.joined(separator: "\n"))
      }
      """
  }

  private static func makeCodingKeysCases(from declaration: some DeclGroupSyntax) -> [String] {
    declaration.memberBlock.members
      .compactMap { member -> String? in
        let variableDecl = member.decl.as(VariableDeclSyntax.self)

        let storedPropertyVariableDecl = variableDecl?.bindings.filter { $0.accessorBlock == nil }

        // is a property
        guard let propertyName = storedPropertyVariableDecl?.first?
          .pattern.as(IdentifierPatternSyntax.self)?
          .identifier.text
        else {
          return nil
        }

        // if it has a CodableKey macro on it
        if let codableKeyAttribute = codableKeyAttribute(from: variableDecl?.attributes),
           let customKeyValue = customKeyValue(from: codableKeyAttribute.as(AttributeSyntax.self)) {
          // Uses the value in the Macro
          return "case \(propertyName) = \(customKeyValue)"
        }

        if needsToSnakeCaseCodingKeyValue(by: declaration) {
          let snakeCaseKey = propertyName.toSnakeCase
          if propertyName != snakeCaseKey {
            return "case \(propertyName) = \"\(snakeCaseKey)\""
          }
        }

        return "case \(propertyName)"
      }
  }

  private static func codableKeyAttribute(
    from attributes: AttributeListSyntax?
  ) -> AttributeListSyntax.Element? {
    attributes?.first { element in
      element.as(AttributeSyntax.self)?
        .attributeName
        .as(IdentifierTypeSyntax.self)?
        .name.text == "CodableKey"
    }
  }

  private static func customKeyValue(
    from codableKeyAttribute: AttributeSyntax?
  ) -> ExprSyntax? {
    codableKeyAttribute?
      .arguments?
      .as(LabeledExprListSyntax.self)?
      .first?
      .expression
  }

  private static func needsToSnakeCaseCodingKeyValue(by declaration: some DeclGroupSyntax) -> Bool {
    let codingKeyStyleAttributeSyntax = declaration.attributes.compactMap {
      $0.as(AttributeSyntax.self)?
        .arguments?
        .as(LabeledExprListSyntax.self)?
        .first {
          $0.label?.text == "codingKeyStyle"
        }
    }

    let isSnakeCase = codingKeyStyleAttributeSyntax.contains {
      $0.expression
        .as(MemberAccessExprSyntax.self)?
        .declName
        .baseName
        .text == "snakeCase"
    }

    return isSnakeCase
  }
}
