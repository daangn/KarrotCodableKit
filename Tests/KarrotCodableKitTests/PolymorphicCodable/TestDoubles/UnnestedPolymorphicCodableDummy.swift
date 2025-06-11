//
//  UnnestedPolymorphicCodableDummy.swift
//  KarrotCodableKit
//
//  Created by elon on 6/10/25.
//

import Foundation

import KarrotCodableKit

@PolymorphicCodableStrategyProviding(
  identifierCodingKey: "type",
  matchingTypes: [
    TitleViewItem.self,
    ImageViewItem.self,
  ]
)
protocol ViewItem {
  var id: String { get }
}

// MARK: - Codable

struct DummyFeedResponse: Codable {
  @PolymorphicArrayValue<ViewItemCodableStrategy>
  var items: [ViewItem]
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

// MARK: - Decodable

struct DummyDecodingFeedResponse: Decodable {
  @PolymorphicArrayValue<ViewItemCodableStrategy>
  var items: [ViewItem]
}

@UnnestedPolymorphicDecodable(
  identifier: "IMAGE_VIEW_ITEM",
  forKey: "info",
  codingKeyStyle: .snakeCase
)
struct ImageViewItem: ViewItem {
  let id: String
  let imageURL: URL
}
