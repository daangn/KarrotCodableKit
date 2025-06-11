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
      case \(raw: nestedKey)
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
    }.joined(separator: "\n  ")

    return """
      \(accessLevel)init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let dataContainer = try container.nestedContainer(
          keyedBy: NestedDataCodingKeys.self,
          forKey: CodingKeys.\(nestedKey)
        )

        \(dataInitializations)
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
    }.joined(separator: "\n  ")

    return """
      \(accessLevel)func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var dataContainer = container.nestedContainer(
          keyedBy: NestedDataCodingKeys.self,
          forKey: CodingKeys.\(nestedKey)
        )

        \(dataEncodings)
      }
      """
  }
}
