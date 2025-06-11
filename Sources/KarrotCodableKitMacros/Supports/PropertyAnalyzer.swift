//
//  PropertyAnalyzer.swift
//  KarrotCodableKit
//
//  Created by Elon on 6/11/25.
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

import SwiftSyntax

enum PropertyAnalyzer {

  struct PropertyInfo {
    let name: String
    let type: String
  }

  static func extractStoredProperties(from declaration: some DeclGroupSyntax) -> [PropertyInfo] {
    CodingKeysSyntaxFactory.extractStoredPropertyDeclarations(from: declaration)
      .compactMap { propertyDeclaration in
        guard
          let binding = propertyDeclaration.variableDecl.bindings
            .first(where: { $0.accessorBlock == nil }),
          let typeAnnotation = binding.typeAnnotation?.type
        else {
          return nil
        }

        return PropertyInfo(
          name: propertyDeclaration.propertyName,
          type: typeAnnotation.trimmed.description
        )
      }
  }
}
