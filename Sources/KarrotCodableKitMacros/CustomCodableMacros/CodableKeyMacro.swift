//
//  CodableKeyMacro.swift
//  KarrotCodableKit
//
//  Created by Elon on 10/10/23.

//  Based on code from the Swift.org open source project.
//
//  Copyright (c) 2014 - 2023 Apple Inc. and the Swift project authors
//  Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://github.com/daangn/KarrotCodableKit/ThirdPartyLicenses/swiftlang/swift-syntax for license information
//

import SwiftSyntax
import SwiftSyntaxMacros

public struct CodableKeyMacro: PeerMacro {
  public static func expansion(
    of node: AttributeSyntax,
    providingPeersOf declaration: some DeclSyntaxProtocol,
    in context: some MacroExpansionContext
  ) throws -> [DeclSyntax] {
    // Does nothing, used only to decorate members with data
    []
  }
}
