# KarrotCodableKit

KarrotCodableKit is a framework that extends Swift's Codable protocol to provide more powerful and flexible data encoding and decoding capabilities. It helps handle complex JSON structures and enables type-safe transformations for various data formats.

This framework includes the following core components:

- `CustomCodable`: Custom encoding/decoding strategies with support for different coding key styles
- `PolymorphicCodable`: Extensions for supporting polymorphic types with Codable
- `AnyCodable`: A type-erased Codable value that can handle various types
- `BetterCodable`: Enhanced Codable functionality with property wrappers for dates, data values, and more


KarrotCodableKit simplifies the conversion of models from various data sources such as network responses, local storage, and enables developers to reduce development time and improve code quality.

## Installation

You can install this framework using Swift Package Manager:

1. Open Xcode and navigate to `Project` -> `Package dependencies` -> `Add Package Dependency (+)`.
2. Enter the repository URL in the search field: `https://github.com/daangn/KarrotCodableKit`
3. Specify the version you want to use - either the latest version or a specific version.
4. Click `Next` and `Finish` to complete the installation. After the package is successfully added to your project, import the framework in the files where you want to use it:

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
  
  enum CodingKeys: String, CodingKey {
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
  
  enum CodingKeys: String, CodingKey {
    case firstName = "first_name"
    case lastLogin = "last_login"
  }
}

extension User: Codable {
}
```

### PolymorphicCodable

`PolymorphicCodable` provides functionality to easily decode polymorphic types from JSON. It includes several interfaces like `PolymorphicIdentifiable`, `PolymorphicCodableStrategy`, and property wrappers like `PolymorphicValue` and `PolymorphicArrayValue`.

```swift
@PolymorphicCodableStrategyProviding(
  identifierCodingKey: "type",
  matchingTypes: [
    ImageViewItem.self,
    TextViewItem.self,
  ],
  fallbackType: UndefinedViewItem.self
)
protocol ViewItem {
  var id: String { get }
}

@PolymorphicCodable(identifier: "IMAGE_VIEW_ITEM")
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

When decoding, the macro uses the value of the specified `identifierCodingKey` (in this example, "type") to determine which enum case to use. It then uses the associated type's `polymorphicIdentifier` to match and decode the data.

Each enum case must have exactly one associated value of a type that has `PolymorphicCodable` applied to it.

```swift
@PolymorphicEnumCodable(identifierCodingKey: "type")
enum ViewItem {
  case image(ImageViewItem)
  case text(TextViewItem)
}

@PolymorphicCodable(identifier: "IMAGE_VIEW_ITEM")
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
