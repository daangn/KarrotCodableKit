//
//  PolymorphicDecodableMacro.swift
//
//
//  Created by Elon on 10/19/24.
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public enum PolymorphicDecodableMacro: MemberMacro {
  public static func expansion(
    of node: AttributeSyntax,
    providingMembersOf declaration: some DeclGroupSyntax,
    in context: some MacroExpansionContext
  ) throws -> [DeclSyntax] {
    [try CodingKeysSyntaxFactory.makeCodingKeysSyntax(from: declaration)]
  }
}

extension PolymorphicDecodableMacro: ExtensionMacro {
  public static func expansion(
    of node: AttributeSyntax,
    attachedTo declaration: some DeclGroupSyntax,
    providingExtensionsOf type: some TypeSyntaxProtocol,
    conformingTo protocols: [TypeSyntax],
    in context: some MacroExpansionContext
  ) throws -> [ExtensionDeclSyntax] {
    guard let arguments = node.arguments?.as(LabeledExprListSyntax.self),
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

    let accessLevel = AccessLevelModifier.stringValue(from: declaration)
    return [
      try ExtensionDeclSyntax(
        """
        extension \(type.trimmed): PolymorphicDecodableType {
          \(raw: accessLevel)static var polymorphicIdentifier: String { "\(raw: identifier)" }
        }
        """
      )
    ]
  }
}
