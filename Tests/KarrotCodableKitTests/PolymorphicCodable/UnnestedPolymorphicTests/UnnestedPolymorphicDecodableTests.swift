//
//  UnnestedPolymorphicDecodableTests.swift
//  KarrotCodableKit
//
//  Created by elon on 6/11/25.
//

import Foundation
import Testing

import KarrotCodableKit

struct UnnestedPolymorphicDecodableTests {
  
  @Test func decodingUnnestedPolymorphicCodable() async throws  {
    // given
    let jsonData = #"""
    {
      "items": [
        {
          "type": "IMAGE_VIEW_ITEM",
          "info": {
            "id": "1e243b34-b8a6-41c8-b08f-cba8d014021f",
            "image_url": "https://karrotmarket.com"
          }
        }
      ]
    }
    """#

    // when
    let result = try JSONDecoder().decode(DummyDecodingFeedResponse.self, from: Data(jsonData.utf8))

    // then
    #expect(result.items.count == 1)

    let item = try #require(result.items.first)
    let imageViewItem = try #require(item as? ImageViewItem)
    #expect(imageViewItem.id == "1e243b34-b8a6-41c8-b08f-cba8d014021f")
    #expect(imageViewItem.imageURL.absoluteString == "https://karrotmarket.com")
  }
}
