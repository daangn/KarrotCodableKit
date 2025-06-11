//
//  PolymorphicExtensionFactory.swift
//  KarrotCodableKit
//
//  Created by Elon on 6/11/25.
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

import SwiftSyntax
import SwiftSyntaxBuilder

enum PolymorphicExtensionFactory {

  enum PolymorphicProtocolType {
    case codable
    case decodable
    case encodable

    var protocolName: String {
      switch self {
      case .codable: "PolymorphicCodableType"
      case .decodable: "PolymorphicDecodableType"
      case .encodable: "PolymorphicEncodableType"
      }
    }
  }

  static func makeBasicPolymorphicExtension(
    for type: some TypeSyntaxProtocol,
    identifier: String,
    protocolType: PolymorphicProtocolType,
    accessLevel: String
  ) throws -> ExtensionDeclSyntax {
    try ExtensionDeclSyntax(
      """
      extension \(type.trimmed): \(raw: protocolType.protocolName) {
        \(raw: accessLevel)static var polymorphicIdentifier: String { "\(raw: identifier)" }
      }
      """
    )
  }

  static func makeUnnestedPolymorphicExtension(
    for type: some TypeSyntaxProtocol,
    identifier: String,
    protocolType: PolymorphicProtocolType,
    accessLevel: String,
    initFromDecoder: String? = nil,
    encodeToEncoder: String? = nil
  ) throws -> ExtensionDeclSyntax {
    var extensionBody = "\(accessLevel)static var polymorphicIdentifier: String { \"\(identifier)\" }"

    if let initFromDecoder {
      extensionBody += "\n\n\(initFromDecoder)"
    }

    if let encodeToEncoder {
      extensionBody += "\n\n\(encodeToEncoder)"
    }

    return try ExtensionDeclSyntax(
      """
      extension \(type.trimmed): \(raw: protocolType.protocolName) {
        \(raw: extensionBody)
      }
      """
    )
  }
}
