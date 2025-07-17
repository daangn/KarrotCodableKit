//
//  UnnestedPolymorphicDecodableDummy.swift
//  KarrotCodableKit
//
//  Created by elon on 6/25/25.
//

import Foundation

import KarrotCodableKit

// MARK: - Decodable

struct DummyDecodingFeedResponse: Decodable {
  @ViewItem.PolymorphicArray var items: [ViewItem]
}

@UnnestedPolymorphicDecodable(
  identifier: "IMAGE_VIEW_ITEM",
  forKey: "default",
  codingKeyStyle: .snakeCase
)
struct ImageViewItem: ViewItem {
  let id: String
  let imageURL: URL
  let `class`: String
}

@UnnestedPolymorphicDecodable(
  identifier: "SUBTITLE_DECODABLE_VIEW_ITEM",
  forKey: "data"
)
struct SubtitleDecodableViewItem: ViewItem {
  let id: String
  let title: String
  let subtitle: String
}

@UnnestedPolymorphicDecodable(
  identifier: "OPTIONAL_DECODABLE_VIEW_ITEM",
  forKey: "data"
)
struct OptionalDecodableViewItem: ViewItem {
  let id: String
  let title: String?
  let count: Int?
  let url: URL?
}
