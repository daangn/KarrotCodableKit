//
//  UnnestedPolymorphicDecodableMacro.swift
//  KarrotCodableKit
//
//  Created by Elon on 6/11/25.
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public enum UnnestedPolymorphicDecodableMacro: MemberMacro {

  public static func expansion(
    of node: AttributeSyntax,
    providingMembersOf declaration: some DeclGroupSyntax,
    in context: some MacroExpansionContext
  ) throws -> [DeclSyntax] {
    let nestedKey = try MacroArgumentExtractor.extractNestedKey(from: node)

    return [
      UnnestedPolymorphicSyntaxFactory.makeTopLevelCodingKeysSyntax(nestedKey: nestedKey),
      try UnnestedPolymorphicSyntaxFactory.makeNestedDataCodingKeysSyntax(from: declaration),
    ]
  }
}

extension UnnestedPolymorphicDecodableMacro: ExtensionMacro {
  public static func expansion(
    of node: AttributeSyntax,
    attachedTo declaration: some DeclGroupSyntax,
    providingExtensionsOf type: some TypeSyntaxProtocol,
    conformingTo protocols: [TypeSyntax],
    in context: some MacroExpansionContext
  ) throws -> [ExtensionDeclSyntax] {
    let arguments = try MacroArgumentExtractor.extractUnnestedPolymorphicArguments(from: node)
    let accessLevel = AccessLevelModifier.stringValue(from: declaration)

    let initFromDecoder = UnnestedPolymorphicSyntaxFactory.makeUnnestedInitFromDecoder(
      from: declaration,
      nestedKey: arguments.nestedKey,
      accessLevel: accessLevel
    )

    return [
      try PolymorphicExtensionFactory.makeUnnestedPolymorphicExtension(
        for: type,
        identifier: arguments.identifier,
        protocolType: .decodable,
        accessLevel: accessLevel,
        initFromDecoder: initFromDecoder
      ),
    ]
  }
}
