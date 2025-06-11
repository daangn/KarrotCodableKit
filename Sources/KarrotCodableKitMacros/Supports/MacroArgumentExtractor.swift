//
//  MacroArgumentExtractor.swift
//  KarrotCodableKit
//
//  Created by Elon on 6/11/25.
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

import SwiftSyntax
import SwiftSyntaxMacros

enum MacroArgumentExtractor {

  struct PolymorphicMacroArguments {
    let identifier: String
  }

  struct UnnestedPolymorphicMacroArguments {
    let identifier: String
    let nestedKey: String
  }

  static func extractPolymorphicArguments(
    from node: AttributeSyntax
  ) throws -> PolymorphicMacroArguments {
    guard
      let arguments = node.arguments?.as(LabeledExprListSyntax.self),
      let identifierExpr = SyntaxHelper.findArgument(named: "identifier", in: arguments),
      let identifier = SyntaxHelper.extractString(from: identifierExpr)
    else {
      throw CodableKitError.message("Missing polymorphic identifier argument.")
    }

    guard !identifier.isEmpty else {
      throw CodableKitError.message(
        "Invalid polymorphic identifier: expected a non-empty string."
      )
    }

    return PolymorphicMacroArguments(identifier: identifier)
  }

  static func extractUnnestedPolymorphicArguments(
    from node: AttributeSyntax
  ) throws -> UnnestedPolymorphicMacroArguments {
    guard let arguments = node.arguments?.as(LabeledExprListSyntax.self) else {
      throw CodableKitError.message("Missing macro arguments.")
    }

    guard
      let identifierExpr = SyntaxHelper.findArgument(named: "identifier", in: arguments),
      let identifier = SyntaxHelper.extractString(from: identifierExpr)
    else {
      throw CodableKitError.message("Missing polymorphic identifier argument.")
    }

    guard !identifier.isEmpty else {
      throw CodableKitError.message(
        "Invalid polymorphic identifier: expected a non-empty string."
      )
    }

    guard
      let nestedKeyArg = SyntaxHelper.findArgument(named: "forKey", in: arguments),
      let nestedKey = SyntaxHelper.extractString(from: nestedKeyArg)
    else {
      throw CodableKitError.message("Missing required forKey argument.")
    }

    return UnnestedPolymorphicMacroArguments(identifier: identifier, nestedKey: nestedKey)
  }

  static func extractNestedKey(from node: AttributeSyntax) throws -> String {
    guard let arguments = node.arguments?.as(LabeledExprListSyntax.self) else {
      throw CodableKitError.message("Missing macro arguments.")
    }

    guard
      let nestedKeyArg = SyntaxHelper.findArgument(named: "forKey", in: arguments),
      let nestedKey = SyntaxHelper.extractString(from: nestedKeyArg)
    else {
      throw CodableKitError.message("Missing required forKey argument.")
    }

    guard !nestedKey.isEmpty else {
      throw CodableKitError.message(
        "Invalid nested key: expected a non-empty string."
      )
    }

    return nestedKey
  }
}
