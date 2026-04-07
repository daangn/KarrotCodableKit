//
//  PolymorphicEnumCodableMacro.swift
//  KarrotCodableKit
//
//  Created by Elon on 10/19/24.
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

public struct PolymorphicEnumCodableMacro: MemberMacro {
  public static func expansion(
    of node: AttributeSyntax,
    providingMembersOf declaration: some DeclGroupSyntax,
    in _: some MacroExpansionContext,
  ) throws -> [DeclSyntax] {
    guard let enumDecl = declaration.as(EnumDeclSyntax.self) else {
      throw CodableKitError.message("`@PolymorphicEnumCodable` can only be attached to enums")
    }

    let identifierCodingKey = try PolymorphicEnumCodableFactory.validateIdentifierCodingKey(in: node)
    let caseInfos = try PolymorphicEnumCodableFactory.extractCaseInfos(from: enumDecl)
    let fallbackCaseName = try PolymorphicEnumCodableFactory.validateFallbackCaseName(
      in: node,
      caseInfos: caseInfos,
    )

    let polymorphicMetaCodingKeySyntax = PolymorphicEnumCodableFactory.makePolymorphicMetaCodingKey(
      with: identifierCodingKey
    )

    let accessLevel = AccessLevelModifier.stringValue(from: declaration)

    let initFromDecoderSyntax = PolymorphicEnumCodableFactory.makeInitFromDecoder(
      with: caseInfos,
      identifierCodingKey: identifierCodingKey,
      accessLevel: accessLevel,
      fallbackCaseName: fallbackCaseName,
    )

    let encodeToEncoderSyntax = PolymorphicEnumCodableFactory.makeEncodeToEncoder(
      with: caseInfos,
      accessLevel: accessLevel,
    )

    return [
      "\(raw: polymorphicMetaCodingKeySyntax)",
      "\(raw: initFromDecoderSyntax)",
      "\(raw: encodeToEncoderSyntax)",
    ]
  }
}

extension PolymorphicEnumCodableMacro: ExtensionMacro {
  public static func expansion(
    of node: AttributeSyntax,
    attachedTo declaration: some DeclGroupSyntax,
    providingExtensionsOf type: some TypeSyntaxProtocol,
    conformingTo _: [TypeSyntax],
    in _: some MacroExpansionContext,
  ) throws -> [ExtensionDeclSyntax] {
    guard let enumDecl = declaration.as(EnumDeclSyntax.self) else {
      throw CodableKitError.message("`@PolymorphicEnumCodable` can only be attached to enums")
    }

    try PolymorphicEnumCodableFactory.validateIdentifierCodingKey(in: node)
    let caseInfos = try PolymorphicEnumCodableFactory.extractCaseInfos(from: enumDecl)
    try PolymorphicEnumCodableFactory.validateFallbackCaseName(in: node, caseInfos: caseInfos)

    return try [ExtensionDeclSyntax("extension \(type.trimmed): Codable {}")]
  }
}
