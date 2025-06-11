//
//  SyntaxHelper.swift
//  KarrotCodableKit
//
//  Created by Elon on 10/18/24.
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

import SwiftSyntax
import SwiftSyntaxBuilder

struct SyntaxHelper {

  // Helper function to find argument by name in LabeledExprListSyntax
  static func findArgument(
    named name: String,
    in arguments: LabeledExprListSyntax
  ) -> ExprSyntax? {
    arguments.first { $0.label?.text == name }?.expression
  }

  // Helper function to extract string from ExprSyntax (assuming it is a string literal)
  static func extractString(from exprSyntax: ExprSyntax) -> String? {
    guard let stringLiteral = exprSyntax.as(StringLiteralExprSyntax.self) else { return nil }
    return stringLiteral.segments
      .compactMap { $0.as(StringSegmentSyntax.self) }
      .map(\.content.text)
      .joined()
  }
}
