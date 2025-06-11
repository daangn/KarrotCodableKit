# KarrotCodableKit

[![CI](https://github.com/daangn/KarrotCodableKit/actions/workflows/ci.yml/badge.svg)](https://github.com/daangn/KarrotCodableKit/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://github.com/daangn/KarrotCodableKit/actions/workflows/ci.yml)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fdaangn%2FKarrotCodableKit%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/daangn/KarrotCodableKit)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fdaangn%2FKarrotCodableKit%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/daangn/KarrotCodableKit)

KarrotCodableKit is a library that extends Swift's Codable protocol to provide more powerful and flexible data encoding and decoding capabilities. It helps handle complex JSON structures and enables type-safe transformations for various data formats.

This library includes the following key features:

- `CustomCodable`: Custom encoding/decoding strategies with support for different coding key styles
- `PolymorphicCodable`: Extensions for supporting polymorphic types with Codable
- `AnyCodable`: A type-erased Codable value that can handle various types
- `BetterCodable`: Enhanced Codable functionality with property wrappers for dates, data values, and more

KarrotCodableKit simplifies the conversion of models from various data sources such as network responses, local storage, and enables developers to reduce development time and improve code quality.

See the [documentation](https://swiftpackageindex.com/daangn/KarrotCodableKit/main/documentation/KarrotCodableKit) for more details.

## Installation

You can install this framework using Swift Package Manager:

1. Open Xcode and navigate to `Project` -> `Package dependencies` -> `Add Package Dependency (+)`.
2. Enter the repository URL in the search field: `https://github.com/daangn/KarrotCodableKit.git`
3. Specify the version you want to use - either the latest version or a specific version.
4. Click `Next` and `Finish` to complete the installation. After the package is successfully added to your project

Or add it to your Package.swift file:

```swift
dependencies: [
  .package(url: "https://github.com/daangn/KarrotCodableKit.git", from: "1.1.0")
]
```

Then import the framework in the files where you want to use it:

```swift
import KarrotCodableKit
```

Now you're ready to use the KarrotCodableKit framework.

## Key Features

### CustomCodable

`CustomCodable` is a macro that simplifies implementing Swift's Codable protocol. This feature automatically generates the `CodingKeys` enum and adopts the `Codable` protocol.

- `@CustomCodable`: Adopts the `Codable` protocol and automatically generates CodingKeys
- `@CustomEncodable`: Used when only adopting the `Encodable` protocol
- `@CustomDecodable`: Used when only adopting the `Decodable` protocol
- `@CodableKey`: Customizes the coding key value for specific properties

### Usage Examples

#### Basic Usage

```swift
@CustomCodable
struct Person {
  let name: String
  let age: Int
  @CodableKey(name: "userProfileUrl")
  let userProfileURL: String
}
```

The code above expands to:

```swift
struct Person {
  let name: String
  let age: Int
  let userProfileURL: String
  
  private enum CodingKeys: String, CodingKey {
    case name
    case age
    case userProfileURL = "userProfileUrl"
  }
}

extension Person: Codable {
}
```

#### Snake Case Conversion

Setting `codingKeyStyle` to `.snakeCase` converts property names to snake_case for coding keys:

```swift
@CustomCodable(codingKeyStyle: .snakeCase)
struct User {
  let firstName: String
  let lastLogin: Date
}
```

The code above expands to:

```swift
struct User {
  let firstName: String
  let lastLogin: Date
  
  private enum CodingKeys: String, CodingKey {
    case firstName = "first_name"
    case lastLogin = "last_login"
  }
}

extension User: Codable {
}
```

### PolymorphicCodable

`PolymorphicCodable` provides functionality to easily decode polymorphic types from JSON. It includes several interfaces like `PolymorphicIdentifiable`, `PolymorphicCodableStrategy`, and property wrappers like `PolymorphicValue` and `PolymorphicArrayValue`.

**Parameters:**
- `identifierCodingKey`: Specifies the JSON key used to determine the type of object being decoded. Defaults to "type" if not specified, allowing you to omit this parameter when using the default value.
- `fallbackType`: Defines a default type to use when the identifier in the JSON doesn't match any of the registered types, preventing decoding failures for unknown types. If this parameter is omitted and an unknown type identifier is encountered during decoding, a decoding error will be thrown.

The following example demonstrates how to decode dynamic JSON content where the type of object is determined at runtime:

```json
[
  {
    "type": "IMAGE_VIEW_ITEM",
    "id": "008c377d-9ea0-4fae-9ae3-e2da27be4be7",
    "image_url": "https://example.com/images/banner.jpg"
  },
  {
    "type": "TEXT_VIEW_ITEM",
    "id": "1fdb2bee-394e-4d61-b3b8-73f8b668d47f",
    "title": "Welcome Message",
    "description": "Welcome to Karrot"
  },
  {
    "type": "IMAGE_VIEW_ITEM_V2",
    "id": "acf5644d-dd46-46f4-a497-e0ea3eef23d1",
    "title": "Karrot",
    "banner_image_url": "https://example.com/images/banner2.jpg"
  }
]
```

`PolymorphicCodable` enables you to decode dynamic JSON structures where the concrete type is determined by a type identifier field. The library handles this dynamic type resolution automatically during decoding:

```swift
@PolymorphicCodableStrategyProviding(
  identifierCodingKey: "type",
  matchingTypes: [
    ImageViewItem.self,
    TextViewItem.self,
  ],
  fallbackType: UndefinedViewItem.self
)
protocol ViewItem: Codable {
  var id: String { get }
}

@PolymorphicCodable(
  identifier: "IMAGE_VIEW_ITEM",
  codingKeyStyle: .snakeCase
)
struct ImageViewItem: ViewItem {
  let id: String
  let imageURL: URL
}

@PolymorphicCodable(identifier: "TEXT_VIEW_ITEM")
struct TextViewItem: ViewItem {
  let id: String
  let title: String
  let description: String
}

@PolymorphicCodable(identifier: "UNDEFINED_VIEW_ITEM")
struct UndefinedViewItem: ViewItem {
  let id: String
}
```

### PolymorphicEnumCodable

`PolymorphicEnumCodable` provides a convenient way to handle polymorphic types directly in Swift enums. Unlike `PolymorphicCodable` which works with protocol-conforming types, this macro allows you to define an enum where each case contains an associated value of a different type, and enables seamless JSON encoding and decoding.

When decoding, the macro uses the value of the specified `identifierCodingKey` to determine which enum case to use. It then uses the associated type's `polymorphicIdentifier` to match and decode the data.

**Parameters:**

- `identifierCodingKey`: Specifies the JSON key used to determine the enum case. Defaults to "type" if not specified, making this parameter optional when using the default value.
- `fallbackCaseName`: Defines which enum case to use when the identifier in the JSON doesn't match any of the associated types, providing graceful handling of unknown types. If this parameter is omitted and an unknown type identifier is encountered during decoding, a decoding error will be thrown.

Each enum case must have exactly one associated value of a type that adopts the `PolymorphicCodableType` protocol.

```swift
@PolymorphicEnumCodable(
  identifierCodingKey: "type",
  fallbackCaseName: "undefined"
)
enum ViewItem {
  case image(ImageViewItem)
  case text(TextViewItem)
  case undefined(UndefinedViewItem)
}

@PolymorphicCodable(
  identifier: "IMAGE_VIEW_ITEM",
  codingKeyStyle: .snakeCase
)
struct ImageViewItem {
  let id: String
  let imageURL: URL
}

@PolymorphicCodable(identifier: "TEXT_VIEW_ITEM")
struct TextViewItem {
  let id: String
  let title: String
  let description: String
}

@PolymorphicCodable(identifier: "UNDEFINED_VIEW_ITEM")
struct UndefinedViewItem: ViewItem {
  let id: String
}
```

### AnyCodable

Type-erased wrappers for Encodable, Decodable, and Codable values.

See details [README.md](./Docs/AnyCodable/README.md)

### BetterCodable

Level up your Codable structs through property wrappers. The goal of these property wrappers is to avoid implementing a custom init(from decoder: Decoder) throws and suffer through boilerplate.

See details [README.md](./Docs/BetterCodable/README.md)

## Contributing

We welcome all contributions to this project! Feel free to submit pull requests to enhance the functionality of this project.

## License

This project is licensed under the MIT. See LICENSE for details.

## Acknowledgements

- PolymorphicCodable was inspired by [Encode and decode polymorphic types in Swift](https://nilcoalescing.com/blog/BringingPolymorphismToCodable/).
- AnyCodable was adapted from [Flight-School/AnyCodable](https://github.com/Flight-School/AnyCodable).
- BetterCodable was adapted from [marksands/BetterCodable](https://github.com/marksands/BetterCodable).
