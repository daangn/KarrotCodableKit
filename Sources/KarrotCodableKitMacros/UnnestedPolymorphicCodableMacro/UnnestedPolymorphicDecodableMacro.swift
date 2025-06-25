//
//  UnnestedPolymorphicDecodableMacro.swift
//  KarrotCodableKit
//
//  Created by Elon on 6/11/25.
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public enum UnnestedPolymorphicDecodableMacro: MemberMacro, UnnestedPolymorphicMacroType {
  public static let protocolType = PolymorphicExtensionFactory.PolymorphicProtocolType.decodable
  public static let macroType = UnnestedPolymorphicCodeGenerator.MacroType.decodable
  public static let macroName = "UnnestedPolymorphicDecodable"

  public static func expansion(
    of node: AttributeSyntax,
    providingMembersOf declaration: some DeclGroupSyntax,
    in context: some MacroExpansionContext
  ) throws -> [DeclSyntax] {
    try generateMemberDeclarations(
      of: node,
      providingMembersOf: declaration,
      in: context,
      for: Self.self
    )
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
    try generateExtensionDeclarations(
      of: node,
      attachedTo: declaration,
      providingExtensionsOf: type,
      conformingTo: protocols,
      in: context,
      for: Self.self
    )
  }
}
