//
//  UnnestedPolymorphicSyntaxFactory.swift
//  KarrotCodableKit
//
//  Created by Elon on 6/11/25.
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

import SwiftSyntax
import SwiftSyntaxBuilder

enum UnnestedPolymorphicSyntaxFactory {
  static func makeTopLevelCodingKeysSyntax(nestedKey: String) -> DeclSyntax {
    """
    private enum CodingKeys: String, CodingKey {
      case `\(raw: nestedKey.trimmingBackticks)`
    }
    """
  }

  static func makeNestedDataCodingKeysSyntax(
    from declaration: some DeclGroupSyntax
  ) throws -> DeclSyntax {
    guard !declaration.is(EnumDeclSyntax.self) else {
      throw CodableKitError.cannotApplyToEnum
    }

    let cases = CodingKeysSyntaxFactory.makeCodingKeysCases(from: declaration)
    guard !cases.isEmpty else {
      return "private enum NestedDataCodingKeys: CodingKey {}"
    }

    return """
      private enum NestedDataCodingKeys: String, CodingKey {
        \(raw: cases.joined(separator: "\n"))
      }
      """
  }

  static func makeUnnestedInitFromDecoder(
    from declaration: some DeclGroupSyntax,
    nestedKey: String,
    accessLevel: String
  ) -> String {
    let properties = PropertyAnalyzer.extractStoredProperties(from: declaration)
    let dataInitializations = properties.map { property in
      "self.\(property.name) = try dataContainer.decode(\(property.type).self, forKey: NestedDataCodingKeys.\(property.name))"
    }

    var functionBody: String {
      guard !dataInitializations.isEmpty else { return "" }
      return """
          let container = try decoder.container(keyedBy: CodingKeys.self)
          let dataContainer = try container.nestedContainer(
            keyedBy: NestedDataCodingKeys.self,
            forKey: CodingKeys.\(nestedKey)
          )
        
          \(dataInitializations.joined(separator: "\n  "))
        """
    }

    return """
      \(accessLevel)init(from decoder: any Decoder) throws {
      \(functionBody)
      }
      """
  }

  static func makeUnnestedEncodeToEncoder(
    from declaration: some DeclGroupSyntax,
    nestedKey: String,
    accessLevel: String
  ) -> String {
    let properties = PropertyAnalyzer.extractStoredProperties(from: declaration)
    let dataEncodings = properties.map { property in
      "try dataContainer.encode(\(property.name), forKey: NestedDataCodingKeys.\(property.name))"
    }

    let functionBody = if dataEncodings.isEmpty {
      """
        var container = encoder.container(keyedBy: CodingKeys.self)
        _ = container.nestedContainer(
          keyedBy: NestedDataCodingKeys.self,
          forKey: CodingKeys.\(nestedKey)
        )
      """
    } else {
      """
        var container = encoder.container(keyedBy: CodingKeys.self)
        var dataContainer = container.nestedContainer(
          keyedBy: NestedDataCodingKeys.self,
          forKey: CodingKeys.\(nestedKey)
        )
        
        \(dataEncodings.joined(separator: "\n  "))
      """
    }

    return """
      \(accessLevel)func encode(to encoder: any Encoder) throws {
      \(functionBody)
      }
      """
  }
}
