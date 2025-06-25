//
//  UnnestedPolymorphicValidation.swift
//  KarrotCodableKit
//
//  Created by Elon on 6/25/25.
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

import SwiftSyntax
import SwiftSyntaxMacros

public enum UnnestedPolymorphicValidation {

  public static func validateDeclarationIsNotEnum(
    _ declaration: some DeclGroupSyntax,
    macroName: String
  ) throws {
    guard declaration.is(EnumDeclSyntax.self) else { return }
    let enumMacroName = macroName.replacingOccurrences(of: "UnnestedPolymorphic", with: "PolymorphicEnum")
    throw CodableKitError.message(
      "`@\(macroName)` cannot be applied to enum types. Use `@\(enumMacroName)` instead."
    )
  }

  public static func validateIdentifier(_ identifier: String) throws {
    guard identifier.isEmpty else { return }
    throw CodableKitError.message("Invalid polymorphic identifier: expected a non-empty string.")
  }

  public static func validateNestedKey(_ nestedKey: String) throws {
    guard nestedKey.isEmpty else { return }
    throw CodableKitError.message("Invalid nested key: expected a non-empty string.")
  }

  public static func validateUnnestedPolymorphicMacroApplication(
    declaration: some DeclGroupSyntax,
    identifier: String,
    nestedKey: String,
    macroName: String
  ) throws {
    try validateDeclarationIsNotEnum(declaration, macroName: macroName)
    try validateIdentifier(identifier)
    try validateNestedKey(nestedKey)
  }
}
