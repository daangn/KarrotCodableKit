//
//  CodableKitPlugin.swift
//  KarrotCodableKit
//
//  Created by Elon on 10/10/23.
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//
//

import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct KarrotCodableKitPlugin: CompilerPlugin {
  let providingMacros: [Macro.Type] = [
    CodableKeyMacro.self,
    CustomCodableMacro.self,
    CustomEncodableMacro.self,
    CustomDecodableMacro.self,
    PolymorphicCodableStrategyProvidingMacro.self,
    PolymorphicCodableMacro.self,
    PolymorphicEncodableMacro.self,
    PolymorphicDecodableMacro.self,
    PolymorphicEnumCodableMacro.self,
    PolymorphicEnumEncodableMacro.self,
    PolymorphicEnumDecodableMacro.self,
  ]
}
