# AnyCodable

Type-erased wrappers for `Encodable`, `Decodable`, and `Codable` values.

This functionality is discussed in Chapter 3 of
[Flight School Guide to Swift Codable](https://flight.school/books/codable).

## Usage

### AnyEncodable

```swift
import AnyCodable

let dictionary: [String: AnyEncodable] = [
    "boolean": true,
    "integer": 1,
    "double": 3.141592653589793,
    "string": "string",
    "array": [1, 2, 3],
    "nested": [
        "a": "alpha",
        "b": "bravo",
        "c": "charlie"
    ],
    "null": nil
]

let encoder = JSONEncoder()
let json = try! encoder.encode(dictionary)
```

### AnyDecodable

```swift
let json = """
{
    "boolean": true,
    "integer": 1,
    "double": 3.141592653589793,
    "string": "string",
    "array": [1, 2, 3],
    "nested": {
        "a": "alpha",
        "b": "bravo",
        "c": "charlie"
    },
    "null": null
}
""".data(using: .utf8)!

let decoder = JSONDecoder()
let dictionary = try! decoder.decode([String: AnyDecodable].self, from: json)
```

### AnyCodable

`AnyCodable` can be used to wrap values for encoding and decoding.

## License

[MIT](https://github.com/daangn/KarrotCodableKit/ThirdPartyLicenses/AnyCodable/LICENSE)

## Attributions

[Flight-School/AnyCodable](https://github.com/Flight-School/AnyCodable)
