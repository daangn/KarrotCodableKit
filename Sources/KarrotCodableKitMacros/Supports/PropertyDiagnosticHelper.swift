//
//  PropertyDiagnosticHelper.swift
//  KarrotCodableKit
//
//  Created by Elon on 6/25/25.
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

enum PropertyDiagnosticHelper {

  /// Generates diagnostics for constant properties with initializers.
  /// Suggests changing 'let' to 'var' for properties that cannot be decoded properly.
  static func generateConstantWithInitializerDiagnostics(
    for declaration: some DeclGroupSyntax,
    in context: some MacroExpansionContext
  ) {
    let propertyDeclarations = CodingKeysSyntaxFactory.extractStoredPropertyDeclarations(from: declaration)

    for propDecl in propertyDeclarations {
      guard
        let binding = propDecl.variableDecl.bindings
          .first(where: { $0.accessorBlock == nil })
      else {
        continue
      }

      let isVar = propDecl.variableDecl.bindingSpecifier.tokenKind == .keyword(.var)
      let hasInitializer = binding.initializer != nil

      // Generate warning for let properties with initializers
      if !isVar, hasInitializer {
        // Create a FixIt to change 'let' to 'var'
        let letToken = propDecl.variableDecl.bindingSpecifier
        let fixIt = FixIt(
          message: MakePropertyMutableFixIt(),
          changes: [
            FixIt.Change.replace(
              oldNode: Syntax(letToken),
              newNode: Syntax(TokenSyntax.keyword(.var, trailingTrivia: letToken.trailingTrivia))
            ),
          ]
        )

        let diagnostic = Diagnostic(
          node: propDecl.variableDecl,
          message: ConstantWithInitializerWarning(),
          fixIts: [fixIt]
        )
        context.diagnose(diagnostic)
      }
    }
  }
}
