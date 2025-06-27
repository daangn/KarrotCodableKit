//
//  CodingKeysSyntaxFactory.swift
//  KarrotCodableKit
//
//  Created by Elon on 4/8/25.
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

import SwiftSyntax
import SwiftSyntaxMacros

enum CodingKeysSyntaxFactory {

  struct PropertyDeclaration {
    let variableDecl: VariableDeclSyntax
    let propertyName: String
  }

  static func makeCodingKeysSyntax(from declaration: some DeclGroupSyntax) throws -> DeclSyntax {
    guard !declaration.is(EnumDeclSyntax.self) else { throw CodableKitError.cannotApplyToEnum }

    let cases = makeCodingKeysCases(from: declaration)
    guard !cases.isEmpty else {
      return "private enum CodingKeys: CodingKey {}"
    }

    return """
      private enum CodingKeys: String, CodingKey {
        \(raw: cases.joined(separator: "\n"))
      }
      """
  }

  static func makeCodingKeysCases(from declaration: some DeclGroupSyntax) -> [String] {
    extractStoredPropertyDeclarations(from: declaration)
      .map { propertyDeclaration in
        let propertyName = propertyDeclaration.propertyName.trimmingBackticks
        if
          let codableKeyAttribute = codableKeyAttribute(from: propertyDeclaration.variableDecl.attributes),
          let customKeyValue = customKeyValue(from: codableKeyAttribute.as(AttributeSyntax.self))
        {
          return "case `\(propertyName)` = \(customKeyValue)"
        }

        if needsToSnakeCaseCodingKeyValue(by: declaration) {
          let snakeCaseKey = propertyDeclaration.propertyName.toSnakeCase
          if propertyDeclaration.propertyName != snakeCaseKey {
            return "case `\(propertyName)` = \"\(snakeCaseKey)\""
          }
        }

        return "case `\(propertyName)`"
      }
  }

  // MARK: - Shared Helper Methods

  static func extractStoredPropertyDeclarations(
    from declaration: some DeclGroupSyntax
  ) -> [PropertyDeclaration] {
    declaration.memberBlock.members
      .compactMap { member in
        let variableDecl = member.decl.as(VariableDeclSyntax.self)

        // Skip static properties
        guard
          let variableDecl,
          !variableDecl.modifiers.contains(where: { $0.name.tokenKind == .keyword(.static) })
        else {
          return nil
        }

        let storedPropertyVariableDecl = variableDecl.bindings.filter {
          $0.accessorBlock == nil
        }

        guard
          let propertyName = storedPropertyVariableDecl.first?
            .pattern.as(IdentifierPatternSyntax.self)?
            .identifier.text
        else {
          return nil
        }

        return PropertyDeclaration(
          variableDecl: variableDecl,
          propertyName: propertyName
        )
      }
  }

  static func codableKeyAttribute(
    from attributes: AttributeListSyntax?
  ) -> AttributeListSyntax.Element? {
    attributes?.first { element in
      element.as(AttributeSyntax.self)?
        .attributeName
        .as(IdentifierTypeSyntax.self)?
        .name.text == "CodableKey"
    }
  }

  static func customKeyValue(
    from codableKeyAttribute: AttributeSyntax?
  ) -> ExprSyntax? {
    codableKeyAttribute?
      .arguments?
      .as(LabeledExprListSyntax.self)?
      .first?
      .expression
  }

  static func needsToSnakeCaseCodingKeyValue(by declaration: some DeclGroupSyntax) -> Bool {
    let codingKeyStyleAttributeSyntax = declaration.attributes.compactMap {
      $0.as(AttributeSyntax.self)?
        .arguments?
        .as(LabeledExprListSyntax.self)?
        .first {
          $0.label?.text == "codingKeyStyle"
        }
    }

    return codingKeyStyleAttributeSyntax.contains {
      $0.expression
        .as(MemberAccessExprSyntax.self)?
        .declName
        .baseName
        .text == "snakeCase"
    }
  }
}
