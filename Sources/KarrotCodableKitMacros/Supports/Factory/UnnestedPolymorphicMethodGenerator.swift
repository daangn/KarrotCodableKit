//
//  UnnestedPolymorphicMethodGenerator.swift
//  KarrotCodableKit
//
//  Created by Elon on 6/25/25.
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

import SwiftSyntax

public enum UnnestedPolymorphicMethodGenerator {

  public static func generateInitFromDecoder(
    from declaration: some DeclGroupSyntax,
    nestedKey: String,
    accessLevel: String,
    structName: String
  ) -> String {
    let assignableProperties = extractAssignableProperties(from: declaration)
    let functionBody = createInitFunctionBody(
      assignableProperties: assignableProperties,
      nestedKey: nestedKey,
      structName: structName
    )

    return """
      \(accessLevel)init(from decoder: any Decoder) throws {
      \(functionBody)
      }
      """
  }

  public static func generateEncodeToEncoder(
    from declaration: some DeclGroupSyntax,
    nestedKey: String,
    accessLevel: String,
    structName: String
  ) -> String {
    let propertyParameters = extractPropertyParameters(from: declaration)
    let functionBody = createEncodeFunctionBody(
      propertyParameters: propertyParameters,
      nestedKey: nestedKey,
      structName: structName
    )

    return """
      \(accessLevel)func encode(to encoder: any Encoder) throws {
      \(functionBody)
      }
      """
  }

  // MARK: - Private Methods

  private static func extractAssignableProperties(from declaration: some DeclGroupSyntax) -> [String] {
    let propertyDeclarations = CodingKeysSyntaxFactory.extractStoredPropertyDeclarations(from: declaration)

    return propertyDeclarations.compactMap { propDecl -> String? in
      guard
        let binding = propDecl.variableDecl.bindings.first(where: { $0.accessorBlock == nil }),
        binding.typeAnnotation?.type != nil || binding.initializer != nil
      else {
        return nil
      }

      let isVar = propDecl.variableDecl.bindingSpecifier.tokenKind == .keyword(.var)
      let hasInitializer = binding.initializer != nil

      if isVar {
        return "self.\(propDecl.propertyName) = dataContainer.\(propDecl.propertyName)"
      }

      if !hasInitializer {
        return "self.\(propDecl.propertyName) = dataContainer.\(propDecl.propertyName)"
      }

      return nil
    }
  }

  private static func createInitFunctionBody(
    assignableProperties: [String],
    nestedKey: String,
    structName: String
  ) -> String {
    if assignableProperties.isEmpty {
      """
      let container = try decoder.container(keyedBy: CodingKeys.self)
      _ = try container.decode(\(structName).self, forKey: CodingKeys.\(nestedKey.trimmingBackticks))
      """
    } else {
      """
      let container = try decoder.container(keyedBy: CodingKeys.self)
      let dataContainer = try container.decode(\(structName).self, forKey: CodingKeys.\(nestedKey.trimmingBackticks))

      \(assignableProperties.joined(separator: "\n"))
      """
    }
  }

  private static func extractPropertyParameters(from declaration: some DeclGroupSyntax) -> [String] {
    let propertyDeclarations = CodingKeysSyntaxFactory.extractStoredPropertyDeclarations(from: declaration)

    return propertyDeclarations.compactMap { propDecl -> String? in
      guard
        let binding = propDecl.variableDecl.bindings.first(where: { $0.accessorBlock == nil }),
        binding.typeAnnotation?.type != nil || binding.initializer != nil
      else {
        return nil
      }

      let isVar = propDecl.variableDecl.bindingSpecifier.tokenKind == .keyword(.var)
      let hasInitializer = binding.initializer != nil
      let shouldInclude = isVar || !hasInitializer

      guard shouldInclude else { return nil }

      return "\(propDecl.propertyName): \(propDecl.propertyName)"
    }
  }

  private static func createEncodeFunctionBody(
    propertyParameters: [String],
    nestedKey: String,
    structName: String
  ) -> String {
    if propertyParameters.isEmpty {
      """
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(
        \(structName)(),
        forKey: CodingKeys.\(nestedKey.trimmingBackticks)
      )
      """
    } else {
      """
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(
        \(structName)(
          \(propertyParameters.joined(separator: ",\n    "))
        ),
        forKey: CodingKeys.\(nestedKey.trimmingBackticks)
      )
      """
    }
  }
}
