//
//  LosslessBoolValue.swift
//  KarrotCodableKit
//
//  Created by Elon on 4/9/25.
//

import Foundation

public struct LosslessBooleanStrategy<Value: LosslessStringCodable>: LosslessDecodingStrategy {
  public static var losslessDecodableTypes: [(Decoder) -> LosslessStringCodable?] {
    @inline(__always)
    func decode<T: LosslessStringCodable>(_: T.Type) -> (Decoder) -> LosslessStringCodable? {
      { try? T(from: $0) }
    }

    @inline(__always)
    func decodeTruthyString() -> (Decoder) -> LosslessStringCodable? {
      {
        (try? String(from: $0)).flatMap { value in
          if ["true", "yes", "1", "y", "t"].contains(value.lowercased()) {
            return true
          } else {
            let positiveNumber = NSNumber(value: (Int(value) ?? 0) > 0)
            return Bool(truncating: positiveNumber)
          }
        }
      }
    }

    @inline(__always)
    func decodeBoolFromNSNumber() -> (Decoder) -> LosslessStringCodable? {
      { (try? Int(from: $0)).flatMap { Bool(exactly: NSNumber(value: $0 > 0)) } }
    }

    return [
      decodeTruthyString(),
      decodeBoolFromNSNumber(),
      decode(Bool.self),
      decode(Int.self),
      decode(Int8.self),
      decode(Int16.self),
      decode(Int64.self),
      decode(UInt.self),
      decode(UInt8.self),
      decode(UInt16.self),
      decode(UInt64.self),
      decode(Double.self),
      decode(Float.self),
    ]
  }
}

/// Decodes Codable values into their respective preferred types.
///
/// `@LosslessBoolValue` attempts to decode Codable types into their respective preferred types while preserving the data.
///
/// - Note:
///  This uses a `LosslessBooleanStrategy` in order to prioritize boolean values, and as such, some integer values will be lossy.
///
///  For instance, if you decode `{ "some_type": 1 }` then `some_type` will be `true` and not `1`. If you do not want this
///  behavior then use `@LosslessValue` or create a custom `LosslessDecodingStrategy`.
///
/// ```
/// struct Example: Codable {
///   @LosslessBoolValue var foo: Bool
///   @LosslessValue var bar: Int
/// }
///
/// // json: { "foo": 1, "bar": 2 }
/// let value = try JSONDecoder().decode(Fixture.self, from: json)
/// // value.foo == true
/// // value.bar == 2
/// ```
public typealias LosslessBoolValue<
  T: LosslessStringCodable
> = LosslessValueCodable<LosslessBooleanStrategy<T>>
