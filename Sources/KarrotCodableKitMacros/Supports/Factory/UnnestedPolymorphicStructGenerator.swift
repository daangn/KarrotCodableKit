//
//  UnnestedPolymorphicStructGenerator.swift
//  KarrotCodableKit
//
//  Created by Elon on 6/25/25.
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

import SwiftSyntax

public enum UnnestedPolymorphicStructGenerator {

  public static func extractFilteredMembers(from declaration: some DeclGroupSyntax) -> [String] {
    let propertyDeclarations = CodingKeysSyntaxFactory.extractStoredPropertyDeclarations(from: declaration)

    return propertyDeclarations.compactMap { propDecl -> String? in
      guard
        let binding = propDecl.variableDecl.bindings.first(where: { $0.accessorBlock == nil }),
        binding.typeAnnotation?.type != nil || binding.initializer != nil
      else {
        return nil
      }

      return propDecl.variableDecl.trimmed.description
    }
  }
}
