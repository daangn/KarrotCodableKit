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

  @Test
  func decodingUnnestedPolymorphicCodable() async throws {
    // given
    let jsonData = #"""
    {
      "items": [
        {
          "type": "IMAGE_VIEW_ITEM",
          "default": {
            "id": "1e243b34-b8a6-41c8-b08f-cba8d014021f",
            "image_url": "https://karrotmarket.com",
            "class": "1-A"
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
    #expect(imageViewItem.`class` == "1-A")
  }

  @Test
  func unnestedPolymorphicDecodableWithOptionalPropertiesMissingKeys() async throws {
    // given
    let json = """
      {
        "type": "OPTIONAL_DECODABLE_VIEW_ITEM",
        "data": {
          "id": "test123"
        }
      }
      """

    // when
    let data = json.data(using: .utf8)!
    let decoder = JSONDecoder()
    let result = try decoder.decode(OptionalDecodableViewItem.self, from: data)

    // then
    #expect(result.id == "test123")
    #expect(result.title == nil)
    #expect(result.count == nil)
    #expect(result.url == nil)
  }

  @Test
  func unnestedPolymorphicDecodableWithOptionalPropertiesPartialData() async throws {
    // given
    let json = """
      {
        "type": "OPTIONAL_DECODABLE_VIEW_ITEM",
        "data": {
          "id": "test123",
          "title": "Test Title",
          "count": 42
        }
      }
      """

    // when
    let data = json.data(using: .utf8)!
    let decoder = JSONDecoder()
    let result = try decoder.decode(OptionalDecodableViewItem.self, from: data)

    // then
    #expect(result.id == "test123")
    #expect(result.title == "Test Title")
    #expect(result.count == 42)
    #expect(result.url == nil)
  }

  @Test
  func unnestedPolymorphicDecodableWithRequiredPropertyMissing() async throws {
    // given
    let json = """
      {
        "type": "OPTIONAL_DECODABLE_VIEW_ITEM",
        "data": {
          "title": "Test Title"
        }
      }
      """

    // when
    let data = json.data(using: .utf8)!
    let decoder = JSONDecoder()

    // then
    #expect(throws: DecodingError.self) {
      try decoder.decode(OptionalDecodableViewItem.self, from: data)
    }
  }

  @Test
  func unnestedPolymorphicDecodableWithMissingNestedDataKey() async throws {
    // given
    let json = """
      {
        "type": "OPTIONAL_DECODABLE_VIEW_ITEM"
      }
      """

    // when
    let data = json.data(using: .utf8)!
    let decoder = JSONDecoder()

    // then
    #expect(throws: DecodingError.self) {
      try decoder.decode(OptionalDecodableViewItem.self, from: data)
    }
  }

  @Test
  func unnestedPolymorphicDecodableWithWrongDataType() async throws {
    // given
    let json = """
      {
        "type": "OPTIONAL_DECODABLE_VIEW_ITEM",
        "data": "wrong_type"
      }
      """

    // when
    let data = json.data(using: .utf8)!
    let decoder = JSONDecoder()

    // then
    #expect(throws: DecodingError.self) {
      try decoder.decode(OptionalDecodableViewItem.self, from: data)
    }
  }
}
