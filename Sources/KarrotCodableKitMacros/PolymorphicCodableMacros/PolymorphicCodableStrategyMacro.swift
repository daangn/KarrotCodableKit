//
//  PolymorphicCodableStrategyMacro.swift
//
//
//  Created by Elon on 10/18/24.
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct PolymorphicCodableStrategyProvidingMacro: PeerMacro {
  public static func expansion(
    of node: AttributeSyntax,
    providingPeersOf declaration: some DeclSyntaxProtocol,
    in context: some MacroExpansionContext
  ) throws -> [DeclSyntax] {
    guard let protocolDecl = declaration.as(ProtocolDeclSyntax.self) else {
      throw CodableKitError.message("Macro must be attached to a protocol.")
    }

    guard let arguments = node.arguments?.as(LabeledExprListSyntax.self),
          let identifierCodingKey = SyntaxHelper.findArgument(named: "identifierCodingKey", in: arguments),
          let identifierCodingKeyString = SyntaxHelper.extractString(from: identifierCodingKey),
          let matchingTypes = SyntaxHelper.findArgument(named: "matchingTypes", in: arguments),
          let fallbackType = SyntaxHelper.findArgument(named: "fallbackType", in: arguments)
    else {
      throw CodableKitError.message("Missing required arguments")
    }

    guard !identifierCodingKeyString.isEmpty else {
      throw CodableKitError.message(
        "Invalid or missing identifierCodingKey: expected a non-empty string."
      )
    }

    let accessModifier = accessModifier(from: protocolDecl)
    let identifier = protocolDecl.name.text
    let strategyStructName = "\(identifier)CodableStrategy"

    let formattedMatchingTypes = matchingTypes
      .formatted(using: .init(initialIndentation: .spaces(4)))
      .trimmed

    return [
      DeclSyntax(
        """
        \(raw: accessModifier)struct \(raw: strategyStructName): PolymorphicCodableStrategy {
          enum PolymorphicMetaCodingKey: CodingKey {
            case \(raw: identifierCodingKeyString)
          }

          \(raw: accessModifier)static var polymorphicMetaCodingKey: CodingKey {
            PolymorphicMetaCodingKey.\(raw: identifierCodingKeyString)
          }

          \(raw: accessModifier)static func decode(from decoder: Decoder) throws -> \(raw: identifier) {
            try decoder.decode(
              codingKey: Self.polymorphicMetaCodingKey,
              matchingTypes: \(raw: formattedMatchingTypes),
              fallbackType: \(raw: fallbackType)
            )
          }
        }
        """
      ),
    ]
  }

  private static func accessModifier(from protocolDecl: ProtocolDeclSyntax) -> String {
    guard protocolDecl.accessLevel != .internal else { return "" }
    return protocolDecl.accessLevel.rawValue + " "
  }
}
