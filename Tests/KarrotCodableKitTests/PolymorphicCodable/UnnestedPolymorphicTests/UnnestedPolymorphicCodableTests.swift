//
//  UnnestedPolymorphicCodableTests.swift
//  KarrotCodableKit
//
//  Created by elon on 6/10/25.
//

import Foundation
import Testing

import KarrotCodableKit

struct UnnestedPolymorphicCodableTests {
  @Test func decodingUnnestedPolymorphicCodable() async throws  {
    // given
    let jsonData = #"""
    {
      "items": [
        {
          "type": "TITLE_VIEW_ITEM",
          "data": {
            "id": "1e243b34-b8a6-41c8-b08f-cba8d014021f",
            "item_title": "Hello, world!"
          }
        }
      ]
    }
    """#

    // when
    let result = try JSONDecoder().decode(DummyFeedResponse.self, from: Data(jsonData.utf8))

    // then
    #expect(result.items.count == 1)

    let item = try #require(result.items.first)
    let titleViewItem = try #require(item as? TitleViewItem)
    #expect(titleViewItem.id == "1e243b34-b8a6-41c8-b08f-cba8d014021f")
    #expect(titleViewItem.itemTitle == "Hello, world!")
  }

  @Test func encodingUnnestedPolymorphicCodable() async throws  {
    // given
    let response = DummyFeedResponse(
      items: [
        TitleViewItem(
          id: "1e243b34-b8a6-41c8-b08f-cba8d014021f",
          itemTitle: "Hello, world!"
        )
      ]
    )

    // when
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    let data = try encoder.encode(response)

    // then
    let expectResult = #"""
    {
      "items" : [
        {
          "data" : {
            "id" : "1e243b34-b8a6-41c8-b08f-cba8d014021f",
            "item_title" : "Hello, world!"
          },
          "type" : "TITLE_VIEW_ITEM"
        }
      ]
    }
    """#
    let jsonString = String(decoding: data, as: UTF8.self)
    #expect(jsonString == expectResult)
  }
}
