//
//  UnnestedPolymorphicCodeGenerator.swift
//  KarrotCodableKit
//
//  Created by Elon on 6/25/25.
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

import SwiftSyntax
import SwiftSyntaxBuilder

public enum UnnestedPolymorphicCodeGenerator {

  public enum MacroType {
    case codable
    case decodable
    case encodable

    public var macroName: String {
      switch self {
      case .codable: "CustomCodable"
      case .decodable: "CustomDecodable"
      case .encodable: "CustomEncodable"
      }
    }
  }

  public static func generateTopLevelCodingKeys(nestedKey: String) -> DeclSyntax {
    """
    private enum CodingKeys: String, CodingKey {
      case `\(raw: nestedKey.trimmingBackticks)`
    }
    """
  }

  public static func generateNestedDataStruct(
    from declaration: some DeclGroupSyntax,
    structName: String,
    codingKeyStyle: String?,
    macroType: MacroType = .codable
  ) throws -> DeclSyntax {
    guard !declaration.is(EnumDeclSyntax.self) else {
      throw CodableKitError.cannotApplyToEnum
    }

    let filteredMembers = UnnestedPolymorphicStructGenerator.extractFilteredMembers(from: declaration)
    let accessLevel = "fileprivate"

    guard !filteredMembers.isEmpty else {
      return """
        @\(raw: macroType.macroName)\(codingKeyStyle.map { "(codingKeyStyle: \($0))" } ?? "")
        \(raw: accessLevel) struct \(raw: structName) {
        }
        """
    }

    return """
      @\(raw: macroType.macroName)\(codingKeyStyle.map { "(codingKeyStyle: \($0))" } ?? "")
      \(raw: accessLevel) struct \(raw: structName) {
        \(raw: filteredMembers.joined(separator: "\n  "))
      }
      """
  }
}
