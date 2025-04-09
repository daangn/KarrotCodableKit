//
//  CustomCodableMacro.swift
//  KarrotCodableKit
//
//  Created by Elon on 10/10/23.
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//
//

import SwiftSyntax
import SwiftSyntaxMacros

public enum CustomCodableMacro: MemberMacro {
  public static func expansion(
    of node: AttributeSyntax,
    providingMembersOf declaration: some DeclGroupSyntax,
    in context: some MacroExpansionContext
  ) throws -> [DeclSyntax] {
    [try CodingKeysSyntaxFactory.makeCodingKeysSyntax(from: declaration)]
  }
}

extension CustomCodableMacro: ExtensionMacro {
  public static func expansion(
    of node: AttributeSyntax,
    attachedTo declaration: some DeclGroupSyntax,
    providingExtensionsOf type: some TypeSyntaxProtocol,
    conformingTo protocols: [TypeSyntax],
    in context: some MacroExpansionContext
  ) throws -> [ExtensionDeclSyntax] {
    if declaration.is(EnumDeclSyntax.self) {
      throw CodableKitError.cannotApplyToEnum
    }

    return [try ExtensionDeclSyntax("extension \(type.trimmed): Codable {}")]
  }
}
