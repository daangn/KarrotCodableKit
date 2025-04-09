//
//  CustomEncodableMacro.swift
//  KarrotCodableKit
//
//  Created by Elon on 4/8/25.
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//
//

import SwiftSyntax
import SwiftSyntaxMacros

public enum CustomEncodableMacro: MemberMacro {
  public static func expansion(
    of node: AttributeSyntax,
    providingMembersOf declaration: some DeclGroupSyntax,
    in context: some MacroExpansionContext
  ) throws -> [DeclSyntax] {
    [try CodingKeysSyntaxFactory.makeCodingKeysSyntax(from: declaration)]
  }
}

extension CustomEncodableMacro: ExtensionMacro {
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

    return [try ExtensionDeclSyntax("extension \(type.trimmed): Encodable {}")]
  }
}
