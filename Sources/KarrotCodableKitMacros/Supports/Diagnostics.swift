//
//  Diagnostics.swift
//  KarrotCodableKit
//
//  Created by Elon on 12/27/23.
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//
//

import Foundation
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

enum CodableKitError: Error, CustomStringConvertible {
  case cannotApplyToEnum
  case message(String)

  var description: String {
    switch self {
    case .cannotApplyToEnum:
      "`@CustomCodable`, `@CustomEncodable`, `@CustomDecodable` cannot be applied to enum"
    case .message(let message):
      message
    }
  }
}

// MARK: - Diagnostic Messages

struct ConstantWithInitializerWarning: DiagnosticMessage {
  let message = "Immutable property will not be decoded because it is declared with an initial value which cannot be overwritten"
  let diagnosticID = MessageID(domain: "KarrotCodableKitMacros", id: "constantWithInitializer")
  let severity = DiagnosticSeverity.warning
}

struct MakePropertyMutableFixIt: FixItMessage {
  let message = "Make the property mutable instead"
  let fixItID = MessageID(domain: "KarrotCodableKitMacros", id: "makePropertyMutable")
}
