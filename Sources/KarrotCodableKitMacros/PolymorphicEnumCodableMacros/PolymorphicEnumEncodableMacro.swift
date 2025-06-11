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

public struct PolymorphicEnumEncodableMacro: ExtensionMacro {
  public static func expansion(
    of node: AttributeSyntax,
    attachedTo declaration: some DeclGroupSyntax,
    providingExtensionsOf type: some TypeSyntaxProtocol,
    conformingTo protocols: [TypeSyntax],
    in context: some MacroExpansionContext
  ) throws -> [ExtensionDeclSyntax] {
    // Ensure the declaration is an enum and extract case information
    guard let enumDecl = declaration.as(EnumDeclSyntax.self) else {
      throw CodableKitError.message("`@PolymorphicEnumEncodable` can only be attached to enums")
    }

    // Validate identifierCodingKey
    try PolymorphicEnumCodableFactory.validateIdentifierCodingKey(in: node)

    // Extract case information from the enum
    let caseInfos = try PolymorphicEnumCodableFactory.extractCaseInfos(from: enumDecl)

    let accessLevel = AccessLevelModifier.stringValue(from: declaration)

    let encodeToEncoderSyntax = PolymorphicEnumCodableFactory.makeEncodeToEncoder(
      with: caseInfos,
      accessLevel: accessLevel
    )

    return [
      try ExtensionDeclSyntax("extension \(raw: enumDecl.name.text): Encodable") {
        """
        \(raw: encodeToEncoderSyntax)
        """
      },
    ]
  }
}
