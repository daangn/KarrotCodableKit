//
//  PolymorphicMacroArgumentValidator.swift
//  KarrotCodableKit
//
//  Created by Elon on 6/11/25.
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

import SwiftSyntax
import SwiftSyntaxMacros

public enum PolymorphicMacroArgumentValidator {

  public struct PolymorphicMacroArguments {
    public let identifier: String

    public init(identifier: String) {
      self.identifier = identifier
    }
  }

  public struct UnnestedPolymorphicMacroArguments {
    public let identifier: String
    public let nestedKey: String
    public let codingKeyStyle: String?

    public init(identifier: String, nestedKey: String, codingKeyStyle: String?) {
      self.identifier = identifier
      self.nestedKey = nestedKey
      self.codingKeyStyle = codingKeyStyle
    }
  }

  public static func extractPolymorphicArguments(
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

  public static func extractUnnestedPolymorphicArguments(
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

    guard !nestedKey.isEmpty else {
      throw CodableKitError.message(
        "Invalid nested key: expected a non-empty string."
      )
    }

    let codingKeyStyle: String? = SyntaxHelper.findArgument(named: "codingKeyStyle", in: arguments)
      .flatMap { SyntaxHelper.extractMemberAccess(from: $0) }

    return UnnestedPolymorphicMacroArguments(
      identifier: identifier,
      nestedKey: nestedKey,
      codingKeyStyle: codingKeyStyle
    )
  }

  public static func extractNestedKey(from node: AttributeSyntax) throws -> String {
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
