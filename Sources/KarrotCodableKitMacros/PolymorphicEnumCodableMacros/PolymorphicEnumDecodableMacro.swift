//
//  PolymorphicEnumDecodableMacro.swift
//  KarrotCodableKit
//
//  Created by Elon on 10/21/24.
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

import Foundation

import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

public struct PolymorphicEnumDecodableMacro: ExtensionMacro {
  public static func expansion(
    of node: AttributeSyntax,
    attachedTo declaration: some DeclGroupSyntax,
    providingExtensionsOf type: some TypeSyntaxProtocol,
    conformingTo protocols: [TypeSyntax],
    in context: some MacroExpansionContext
  ) throws -> [ExtensionDeclSyntax] {
    // Ensure the declaration is an enum and extract case information
    guard let enumDecl = declaration.as(EnumDeclSyntax.self) else {
      throw CodableKitError.message("`@PolymorphicEnumDecodable` can only be attached to enums")
    }

    // Validate and extract identifierCodingKey
    let identifierCodingKey = try PolymorphicEnumCodableFactory.validateIdentifierCodingKey(in: node)

    // Extract case information from the enum
    let caseInfos = try PolymorphicEnumCodableFactory.extractCaseInfos(from: enumDecl)

    // Validate and extract fallbackCaseName if provided
    let fallbackCaseName = try PolymorphicEnumCodableFactory.validateFallbackCaseName(
      in: node,
      caseInfos: caseInfos
    )

    let polymorphicMetaCodingKeySyntax = PolymorphicEnumCodableFactory.makePolymorphicMetaCodingKey(
      with: identifierCodingKey
    )

    let accessLevel = AccessLevelModifier.stringValue(from: declaration)

    let initFromDecoderSyntax = PolymorphicEnumCodableFactory.makeInitFromDecoder(
      with: caseInfos,
      identifierCodingKey: identifierCodingKey,
      accessLevel: accessLevel,
      fallbackCaseName: fallbackCaseName
    )

    return [
      try ExtensionDeclSyntax("extension \(raw: enumDecl.name.text): Decodable") {
        """
        \(raw: polymorphicMetaCodingKeySyntax)

        \(raw: initFromDecoderSyntax)
        """
      },
    ]
  }
}
