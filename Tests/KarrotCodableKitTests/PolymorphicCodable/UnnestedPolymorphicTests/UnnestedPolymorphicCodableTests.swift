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
  @Test
  func decodingUnnestedPolymorphicCodable() async throws {
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
        },
        {
          "type": "EMPTY_VIEW_ITEM",
          "data": {}
        }
      ]
    }
    """#

    // when
    let result = try JSONDecoder().decode(DummyFeedResponse.self, from: Data(jsonData.utf8))

    // then
    #expect(result.items.count == 2)

    let titleViewItem = try #require(result.items[0] as? TitleViewItem)
    #expect(titleViewItem.id == "1e243b34-b8a6-41c8-b08f-cba8d014021f")
    #expect(titleViewItem.itemTitle == "Hello, world!")

    #expect(result.items.last is EmptyViewItem)
  }

  @Test
  func encodingUnnestedPolymorphicCodable() async throws {
    // given
    let response = DummyFeedResponse(
      items: [
        TitleViewItem(
          id: "1e243b34-b8a6-41c8-b08f-cba8d014021f",
          itemTitle: "Hello, world!"
        ),
        EmptyViewItem(),
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
        },
        {
          "data" : {

          },
          "type" : "EMPTY_VIEW_ITEM"
        }
      ]
    }
    """#
    let jsonString = String(decoding: data, as: UTF8.self)
    #expect(jsonString == expectResult)
  }

  @Test
  func unnestedPolymorphicCodableWithOptionalPropertiesMissingKeys() async throws {
    // given
    let json = """
      {
        "type": "OPTIONAL_VIEW_ITEM",
        "data": {
          "id": "test123"
        }
      }
      """

    // when
    let data = try #require(json.data(using: .utf8))
    let decoder = JSONDecoder()
    let result = try decoder.decode(OptionalViewItem.self, from: data)

    // then
    #expect(result.id == "test123")
    #expect(result.title == nil)
    #expect(result.count == nil)
    #expect(result.url == nil)
  }

  @Test
  func unnestedPolymorphicCodableWithOptionalPropertiesPartialData() async throws {
    // given
    let json = """
      {
        "type": "OPTIONAL_VIEW_ITEM",
        "data": {
          "id": "test123",
          "title": "Test Title",
          "count": 42
        }
      }
      """

    // when
    let data = try #require(json.data(using: .utf8))
    let decoder = JSONDecoder()
    let result = try decoder.decode(OptionalViewItem.self, from: data)

    // then
    #expect(result.id == "test123")
    #expect(result.title == "Test Title")
    #expect(result.count == 42)
    #expect(result.url == nil)
  }

  @Test
  func unnestedPolymorphicCodableWithRequiredPropertyMissing() async throws {
    // given
    let json = """
      {
        "type": "OPTIONAL_VIEW_ITEM",
        "data": {
          "title": "Test Title"
        }
      }
      """

    // when
    let data = try #require(json.data(using: .utf8))
    let decoder = JSONDecoder()

    // then
    #expect(throws: DecodingError.self) {
      try decoder.decode(OptionalViewItem.self, from: data)
    }
  }

  @Test
  func unnestedPolymorphicCodableWithMissingNestedDataKey() async throws {
    // given
    let json = """
      {
        "type": "OPTIONAL_VIEW_ITEM"
      }
      """

    // when
    let data = try #require(json.data(using: .utf8))
    let decoder = JSONDecoder()

    // then
    #expect(throws: DecodingError.self) {
      try decoder.decode(OptionalViewItem.self, from: data)
    }
  }

  @Test
  func unnestedPolymorphicCodableEncodingWithOptionalProperties() async throws {
    // given
    let item = OptionalViewItem(id: "test123", title: "Test Title", count: nil, url: nil)

    // when
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    let data = try encoder.encode(item)
    let jsonString = try #require(String(data: data, encoding: .utf8))

    // then
    let expectedJson = """
      {
        "data" : {
          "id" : "test123",
          "title" : "Test Title"
        }
      }
      """
    #expect(jsonString == expectedJson)
  }

  @Test
  func unnestedPolymorphicCodableRoundTripWithOptionalProperties() async throws {
    // given
    let originalItem = OptionalViewItem(
      id: "test123",
      title: "Test Title",
      count: 42,
      url: URL(string: "https://example.com")
    )

    // when
    let encoder = JSONEncoder()
    let data = try encoder.encode(originalItem)

    let decoder = JSONDecoder()
    let decodedItem = try decoder.decode(OptionalViewItem.self, from: data)

    // then
    #expect(originalItem.id == decodedItem.id)
    #expect(originalItem.title == decodedItem.title)
    #expect(originalItem.count == decodedItem.count)
    #expect(originalItem.url == decodedItem.url)
  }

  @Test
  func unnestedPolymorphicCodableWithWrongDataType() async throws {
    // given
    let json = """
      {
        "type": "OPTIONAL_VIEW_ITEM",
        "data": "wrong_type"
      }
      """

    // when
    let data = try #require(json.data(using: .utf8))
    let decoder = JSONDecoder()

    // then
    #expect(throws: DecodingError.self) {
      try decoder.decode(OptionalViewItem.self, from: data)
    }
  }

  // MARK: - Edge Case Tests

  @Test
  func constantPropertiesEncodingTest() async throws {
    // given
    let originalItem = ConstantPropertyViewItem(
      id: "test123",
      title: "Test Title"
    )

    // when - encoding
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    let encodedData = try encoder.encode(originalItem)
    let encodedJson = try #require(String(data: encodedData, encoding: .utf8))

    // then - verify encoding includes constant properties
    let expectedJson = """
      {
        "data" : {
          "constantInt" : 42,
          "constantString" : "defaultValue",
          "id" : "test123",
          "title" : "Test Title"
        }
      }
      """
    #expect(encodedJson == expectedJson)
  }

  @Test
  func constantPropertiesDecodingTest() async throws {
    // given
    let decodingJson = """
      {
        "type": "CONSTANT_PROPERTY_VIEW_ITEM",
        "data": {
          "id": "decoded123",
          "title": "Decoded Title",
          "constantString": "ignoredValue",
          "constantInt": 999
        }
      }
      """

    // when - decoding (constants should be ignored and set to default values)
    let decodingData = try #require(decodingJson.data(using: .utf8))
    let decoder = JSONDecoder()
    let decodedItem = try decoder.decode(ConstantPropertyViewItem.self, from: decodingData)

    // then - verify constants are set to default values (not from JSON)
    #expect(decodedItem.id == "decoded123")
    #expect(decodedItem.title == "Decoded Title")
    #expect(decodedItem.constantString == "defaultValue") // Default value, not from JSON
    #expect(decodedItem.constantInt == 42) // Default value, not from JSON
  }

  @Test
  func computedPropertiesEncodingTest() async throws {
    // given
    let originalItem = ComputedPropertyViewItem(
      id: "test123",
      title: "Test Title"
    )

    // when - encoding
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    let encodedData = try encoder.encode(originalItem)
    let encodedJson = try #require(String(data: encodedData, encoding: .utf8))

    // then - verify computed properties are NOT included in encoding
    #expect(!encodedJson.contains("computedProperty"))
    #expect(!encodedJson.contains("getOnlyProperty"))
    #expect(encodedJson.contains("\"id\" : \"test123\""))
    #expect(encodedJson.contains("\"title\" : \"Test Title\""))
  }

  @Test
  func computedPropertiesDecodingTest() async throws {
    // given
    let decodingJson = """
      {
        "type": "COMPUTED_PROPERTY_VIEW_ITEM",
        "data": {
          "id": "decoded123",
          "title": "Decoded Title"
        }
      }
      """

    // when - decoding
    let decodingData = try #require(decodingJson.data(using: .utf8))
    let decoder = JSONDecoder()
    let decodedItem = try decoder.decode(ComputedPropertyViewItem.self, from: decodingData)

    // then - verify computed properties still work
    #expect(decodedItem.id == "decoded123")
    #expect(decodedItem.title == "Decoded Title")
    #expect(decodedItem.computedProperty == "computed")
    #expect(decodedItem.getOnlyProperty == 42)
  }

  @Test
  func staticPropertiesEncodingTest() async throws {
    // given
    let originalItem = StaticPropertyViewItem(
      id: "test123",
      title: "Test Title"
    )

    // when - encoding
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    let encodedData = try encoder.encode(originalItem)
    let encodedJson = try #require(String(data: encodedData, encoding: .utf8))

    // then - verify static properties are NOT included in encoding
    #expect(!encodedJson.contains("staticConstant"))
    #expect(!encodedJson.contains("staticVariable"))
    #expect(encodedJson.contains("\"id\" : \"test123\""))
    #expect(encodedJson.contains("\"title\" : \"Test Title\""))
  }

  @Test
  func staticPropertiesDecodingTest() async throws {
    // given
    let decodingJson = """
      {
        "type": "STATIC_PROPERTY_VIEW_ITEM",
        "data": {
          "id": "decoded123",
          "title": "Decoded Title"
        }
      }
      """

    // when - decoding
    let decodingData = try #require(decodingJson.data(using: .utf8))
    let decoder = JSONDecoder()
    let decodedItem = try decoder.decode(StaticPropertyViewItem.self, from: decodingData)

    // then - verify static properties are still accessible
    #expect(decodedItem.id == "decoded123")
    #expect(decodedItem.title == "Decoded Title")
    #expect(StaticPropertyViewItem.staticConstant == "static")
    #expect(StaticPropertyViewItem.staticVariable == 100)
  }

  @Test
  func functionsEncodingTest() async throws {
    // given
    let originalItem = FunctionViewItem(
      id: "test123",
      title: "Test Title"
    )

    // when - encoding
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    let encodedData = try encoder.encode(originalItem)
    let encodedJson = try #require(String(data: encodedData, encoding: .utf8))

    // then - verify functions are NOT included in encoding
    #expect(!encodedJson.contains("someFunction"))
    #expect(!encodedJson.contains("mutatingFunction"))
    #expect(encodedJson.contains("\"id\" : \"test123\""))
    #expect(encodedJson.contains("\"title\" : \"Test Title\""))
  }

  @Test
  func functionsDecodingTest() async throws {
    // given
    let decodingJson = """
      {
        "type": "FUNCTION_VIEW_ITEM",
        "data": {
          "id": "decoded123",
          "title": "Decoded Title"
        }
      }
      """

    // when - decoding
    let decodingData = try #require(decodingJson.data(using: .utf8))
    let decoder = JSONDecoder()
    var decodedItem = try decoder.decode(FunctionViewItem.self, from: decodingData)

    // then - verify functions still work
    #expect(decodedItem.id == "decoded123")
    #expect(decodedItem.title == "Decoded Title")
    #expect(decodedItem.someFunction() == "function")
    decodedItem.mutatingFunction() // Should not throw
  }

  @Test
  func complexTypesEncodingTest() async throws {
    // given
    let nestedStruct = NestedStruct(name: "test", value: 123)
    let optionalNested = NestedStruct(name: "optional", value: 456)
    let originalItem = ComplexTypeViewItem(
      id: "test123",
      tags: ["tag1", "tag2", "tag3"],
      metadata: ["key1": "value1", "key2": "value2"],
      nestedStruct: nestedStruct,
      optionalNestedStruct: optionalNested
    )

    // when - encoding
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    let encodedData = try encoder.encode(originalItem)
    let encodedJson = try #require(String(data: encodedData, encoding: .utf8))

    // then - verify complex types are properly encoded
    #expect(encodedJson.contains("\"tags\""))
    #expect(encodedJson.contains("\"tag1\""))
    #expect(encodedJson.contains("\"metadata\""))
    #expect(encodedJson.contains("\"key1\""))
    #expect(encodedJson.contains("\"nestedStruct\""))
    #expect(encodedJson.contains("\"optionalNestedStruct\""))
  }

  @Test
  func complexTypesDecodingTest() async throws {
    // given
    let nestedStruct = NestedStruct(name: "test", value: 123)
    let optionalNested = NestedStruct(name: "optional", value: 456)
    let originalItem = ComplexTypeViewItem(
      id: "test123",
      tags: ["tag1", "tag2", "tag3"],
      metadata: ["key1": "value1", "key2": "value2"],
      nestedStruct: nestedStruct,
      optionalNestedStruct: optionalNested
    )

    // when - encoding to get test data
    let encoder = JSONEncoder()
    let encodedData = try encoder.encode(originalItem)

    // when - decoding
    let decoder = JSONDecoder()
    let decodedItem = try decoder.decode(ComplexTypeViewItem.self, from: encodedData)

    // then - verify complex types are properly decoded
    #expect(decodedItem.id == "test123")
    #expect(decodedItem.tags == ["tag1", "tag2", "tag3"])
    #expect(decodedItem.metadata?["key1"] == "value1")
    #expect(decodedItem.metadata?["key2"] == "value2")
    #expect(decodedItem.nestedStruct.name == "test")
    #expect(decodedItem.nestedStruct.value == 123)
    #expect(decodedItem.optionalNestedStruct?.name == "optional")
    #expect(decodedItem.optionalNestedStruct?.value == 456)
  }

  @Test
  func complexTypesWithMissingOptionalProperties() async throws {
    // given
    let json = """
      {
        "type": "COMPLEX_TYPE_VIEW_ITEM",
        "data": {
          "id": "test123",
          "tags": ["tag1", "tag2"],
          "nestedStruct": {
            "name": "required",
            "value": 789
          }
        }
      }
      """

    // when
    let data = try #require(json.data(using: .utf8))
    let decoder = JSONDecoder()
    let decodedItem = try decoder.decode(ComplexTypeViewItem.self, from: data)

    // then
    #expect(decodedItem.id == "test123")
    #expect(decodedItem.tags == ["tag1", "tag2"])
    #expect(decodedItem.metadata == nil)
    #expect(decodedItem.nestedStruct.name == "required")
    #expect(decodedItem.nestedStruct.value == 789)
    #expect(decodedItem.optionalNestedStruct == nil)
  }
}
