//
//  UnnestedPolymorphicCodableMacro.swift
//  KarrotCodableKit
//
//  Created by Elon on 6/10/25.
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public enum UnnestedPolymorphicCodableMacro: MemberMacro, UnnestedPolymorphicMacroType {
  public static let protocolType = PolymorphicExtensionFactory.PolymorphicProtocolType.codable
  public static let macroType = UnnestedPolymorphicCodeGenerator.MacroType.codable
  public static let macroName = "UnnestedPolymorphicCodable"

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

extension UnnestedPolymorphicCodableMacro: ExtensionMacro {
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
