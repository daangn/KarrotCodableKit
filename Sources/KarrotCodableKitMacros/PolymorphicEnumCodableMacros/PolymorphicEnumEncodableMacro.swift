//
//  PolymorphicEnumEncodableMacro.swift
//  KarrotCodableKit
//
//  Created by Elon on 10/21/24.
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

public struct PolymorphicEnumEncodableMacro: MemberMacro {
  public static func expansion(
    of node: AttributeSyntax,
    providingMembersOf declaration: some DeclGroupSyntax,
    in _: some MacroExpansionContext,
  ) throws -> [DeclSyntax] {
    guard let enumDecl = declaration.as(EnumDeclSyntax.self) else {
      throw CodableKitError.message("`@PolymorphicEnumEncodable` can only be attached to enums")
    }

    try PolymorphicEnumCodableFactory.validateIdentifierCodingKey(in: node)

    let caseInfos = try PolymorphicEnumCodableFactory.extractCaseInfos(from: enumDecl)
    let accessLevel = AccessLevelModifier.stringValue(from: declaration)

    let encodeToEncoderSyntax = PolymorphicEnumCodableFactory.makeEncodeToEncoder(
      with: caseInfos,
      accessLevel: accessLevel,
    )

    return [
      "\(raw: encodeToEncoderSyntax)"
    ]
  }
}

extension PolymorphicEnumEncodableMacro: ExtensionMacro {
  public static func expansion(
    of node: AttributeSyntax,
    attachedTo declaration: some DeclGroupSyntax,
    providingExtensionsOf type: some TypeSyntaxProtocol,
    conformingTo _: [TypeSyntax],
    in _: some MacroExpansionContext,
  ) throws -> [ExtensionDeclSyntax] {
    guard let enumDecl = declaration.as(EnumDeclSyntax.self) else {
      throw CodableKitError.message("`@PolymorphicEnumEncodable` can only be attached to enums")
    }

    try PolymorphicEnumCodableFactory.validateIdentifierCodingKey(in: node)
    _ = try PolymorphicEnumCodableFactory.extractCaseInfos(from: enumDecl)

    return try [ExtensionDeclSyntax("extension \(type.trimmed): Encodable {}")]
  }
}
