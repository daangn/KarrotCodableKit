//
//  UnnestedPolymorphicCodableDummy.swift
//  KarrotCodableKit
//
//  Created by elon on 6/10/25.
//

import Foundation

import KarrotCodableKit

struct DummyFeedResponse: Codable {
  @PolymorphicArrayValue<ViewItemCodableStrategy>
  var items: [ViewItem]
}

@PolymorphicCodableStrategyProviding(
  identifierCodingKey: "type",
  matchingTypes: [
    TitleViewItem.self,
  ]
)
protocol ViewItem {
  var id: String { get }
}

@UnnestedPolymorphicCodable(
  identifier: "TITLE_VIEW_ITEM",
  forKey: "data",
  codingKeyStyle: .snakeCase
)
struct TitleViewItem: ViewItem {
  let id: String
  let itemTitle: String?
}
