//
//  PropertyAnalyzer.swift
//  KarrotCodableKit
//
//  Created by Elon on 6/11/25.
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

import SwiftSyntax

enum PropertyAnalyzer {

  struct PropertyInfo {
    let name: String
    let type: String
    let isOptional: Bool
    let isConstant: Bool
  }

  struct ConstantPropertyInfo {
    let name: String
    let value: String
  }

  static func extractStoredProperties(from declaration: some DeclGroupSyntax) -> [PropertyInfo] {
    CodingKeysSyntaxFactory.extractStoredPropertyDeclarations(from: declaration)
      .compactMap { propertyDeclaration in
        guard
          let binding = propertyDeclaration.variableDecl.bindings
            .first(where: { $0.accessorBlock == nil }),
          let typeAnnotation = binding.typeAnnotation?.type
        else {
          return nil
        }

        let typeString = typeAnnotation.trimmed.description
        let isOptional = Self.isOptionalType(typeAnnotation)
        let isConstant = binding.initializer != nil

        return PropertyInfo(
          name: propertyDeclaration.propertyName,
          type: typeString,
          isOptional: isOptional,
          isConstant: isConstant
        )
      }
  }

  static func extractConstantPropertiesForEncoding(from declaration: some DeclGroupSyntax) -> [ConstantPropertyInfo] {
    declaration.memberBlock.members
      .compactMap { member in
        guard let variableDecl = member.decl.as(VariableDeclSyntax.self) else {
          return nil
        }

        // Skip static properties
        if variableDecl.modifiers.contains(where: { $0.name.tokenKind == .keyword(.static) }) {
          return nil
        }

        for binding in variableDecl.bindings {
          guard
            binding.accessorBlock == nil,
            let initializer = binding.initializer,
            let pattern = binding.pattern.as(IdentifierPatternSyntax.self),
            variableDecl.bindingSpecifier.tokenKind == .keyword(.let)
          else {
            continue
          }

          let propertyName = pattern.identifier.text
          let initializerValue = initializer.value.trimmed.description

          return ConstantPropertyInfo(
            name: propertyName,
            value: initializerValue
          )
        }

        return nil
      }
  }

  static func isOptionalType(_ type: TypeSyntax) -> Bool {
    // Check for Optional<T> syntax
    if let identifierType = type.as(IdentifierTypeSyntax.self) {
      if identifierType.name.text == "Optional" {
        return true
      }
    }

    // Check for T? syntax
    if type.as(OptionalTypeSyntax.self) != nil {
      return true
    }

    // Check for String? pattern in the type description
    let typeDescription = type.trimmed.description
    return typeDescription.hasSuffix("?")
  }
}
