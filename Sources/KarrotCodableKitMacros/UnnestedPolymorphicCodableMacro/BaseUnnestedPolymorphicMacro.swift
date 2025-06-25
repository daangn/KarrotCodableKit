//
//  BaseUnnestedPolymorphicMacro.swift
//  KarrotCodableKit
//
//  Created by Elon on 6/25/25.
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public protocol UnnestedPolymorphicMacroType {
  static var protocolType: PolymorphicExtensionFactory.PolymorphicProtocolType { get }
  static var macroType: UnnestedPolymorphicCodeGenerator.MacroType { get }
  static var macroName: String { get }
}

extension UnnestedPolymorphicMacroType {

  static var nestedDataStructName: String { "__NestedDataStruct" }

  public static func generateMemberDeclarations(
    of node: AttributeSyntax,
    providingMembersOf declaration: some DeclGroupSyntax,
    in context: some MacroExpansionContext,
    for macroType: (some UnnestedPolymorphicMacroType).Type
  ) throws -> [DeclSyntax] {
    try UnnestedPolymorphicValidation.validateDeclarationIsNotEnum(declaration, macroName: macroType.macroName)

    let arguments = try PolymorphicMacroArgumentValidator.extractUnnestedPolymorphicArguments(from: node)
    try UnnestedPolymorphicValidation.validateNestedKey(arguments.nestedKey)

    PropertyDiagnosticHelper.generateConstantWithInitializerDiagnostics(
      for: declaration,
      in: context
    )

    let codingKeyStyleArgument = arguments.codingKeyStyle.map { ".\($0)" }

    return [
      UnnestedPolymorphicCodeGenerator.generateTopLevelCodingKeys(nestedKey: arguments.nestedKey),
      try UnnestedPolymorphicCodeGenerator.generateNestedDataStruct(
        from: declaration,
        structName: nestedDataStructName,
        codingKeyStyle: codingKeyStyleArgument,
        macroType: macroType.macroType
      ),
    ]
  }

  public static func generateExtensionDeclarations(
    of node: AttributeSyntax,
    attachedTo declaration: some DeclGroupSyntax,
    providingExtensionsOf type: some TypeSyntaxProtocol,
    conformingTo protocols: [TypeSyntax],
    in context: some MacroExpansionContext,
    for macroType: (some UnnestedPolymorphicMacroType).Type
  ) throws -> [ExtensionDeclSyntax] {
    try UnnestedPolymorphicValidation.validateDeclarationIsNotEnum(declaration, macroName: macroType.macroName)

    let arguments = try PolymorphicMacroArgumentValidator.extractUnnestedPolymorphicArguments(from: node)
    try UnnestedPolymorphicValidation.validateUnnestedPolymorphicMacroApplication(
      declaration: declaration,
      identifier: arguments.identifier,
      nestedKey: arguments.nestedKey,
      macroName: macroType.macroName
    )

    let accessLevel = AccessLevelModifier.stringValue(from: declaration)

    let initFromDecoder = UnnestedPolymorphicMethodGenerator.generateInitFromDecoder(
      from: declaration,
      nestedKey: arguments.nestedKey,
      accessLevel: accessLevel,
      structName: nestedDataStructName
    )

    let encodeToEncoder: String? = if macroType.protocolType != .decodable {
      UnnestedPolymorphicMethodGenerator.generateEncodeToEncoder(
        from: declaration,
        nestedKey: arguments.nestedKey,
        accessLevel: accessLevel,
        structName: nestedDataStructName
      )
    } else {
      nil
    }

    return [
      try PolymorphicExtensionFactory.makeUnnestedPolymorphicExtension(
        for: type,
        identifier: arguments.identifier,
        protocolType: macroType.protocolType,
        accessLevel: accessLevel,
        initFromDecoder: initFromDecoder,
        encodeToEncoder: encodeToEncoder
      ),
    ]
  }
}
