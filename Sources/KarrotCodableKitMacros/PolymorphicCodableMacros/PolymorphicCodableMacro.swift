//
//  PolymorphicCodableMacro.swift
//  KarrotCodableKit
//
//  Created by Elon on 10/18/24.
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public enum PolymorphicCodableMacro: MemberMacro {
  public static func expansion(
    of node: AttributeSyntax,
    providingMembersOf declaration: some DeclGroupSyntax,
    in context: some MacroExpansionContext
  ) throws -> [DeclSyntax] {
    [try CodingKeysSyntaxFactory.makeCodingKeysSyntax(from: declaration)]
  }
}

extension PolymorphicCodableMacro: ExtensionMacro {
  public static func expansion(
    of node: AttributeSyntax,
    attachedTo declaration: some DeclGroupSyntax,
    providingExtensionsOf type: some TypeSyntaxProtocol,
    conformingTo protocols: [TypeSyntax],
    in context: some MacroExpansionContext
  ) throws -> [ExtensionDeclSyntax] {
    let arguments = try PolymorphicMacroArgumentValidator.extractPolymorphicArguments(from: node)
    let accessLevel = AccessLevelModifier.stringValue(from: declaration)

    return [
      try PolymorphicExtensionFactory.makeBasicPolymorphicExtension(
        for: type,
        identifier: arguments.identifier,
        protocolType: .codable,
        accessLevel: accessLevel
      ),
    ]
  }
}
