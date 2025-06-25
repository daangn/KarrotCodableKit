//
//  UnnestedPolymorphicCodableStrategy.swift
//  KarrotCodableKit
//
//  Created by elon on 6/25/25.
//

import Foundation

import KarrotCodableKit

@PolymorphicCodableStrategyProviding(
  identifierCodingKey: "type",
  matchingTypes: [
    TitleViewItem.self,
    ImageViewItem.self,
    EmptyViewItem.self,
    ConstantPropertyViewItem.self,
    ComputedPropertyViewItem.self,
    StaticPropertyViewItem.self,
    FunctionViewItem.self,
    ComplexTypeViewItem.self,
  ]
)
protocol ViewItem {}
