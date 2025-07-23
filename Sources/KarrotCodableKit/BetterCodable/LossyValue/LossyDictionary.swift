//
//  LossyDictionary.swift
//  KarrotCodableKit
//
//  Created by Elon on 4/9/25.
//

import Foundation

/// Decodes Dictionaries filtering invalid key-value pairs if applicable
///
/// `@LossyDictionary` decodes Dictionaries and filters invalid key-value pairs if the Decoder is unable to decode the value.
///
/// This is useful if the Dictionary is intended to contain non-optional values.
@propertyWrapper
public struct LossyDictionary<Key: Hashable, Value> {
  public var wrappedValue: [Key: Value]
  
  let outcome: ResilientDecodingOutcome

  public init(wrappedValue: [Key: Value]) {
    self.wrappedValue = wrappedValue
    self.outcome = .decodedSuccessfully
  }
  
  init(wrappedValue: [Key: Value], outcome: ResilientDecodingOutcome) {
    self.wrappedValue = wrappedValue
    self.outcome = outcome
  }
  
  #if DEBUG
  @dynamicMemberLookup
  public struct ProjectedValue {
    public let outcome: ResilientDecodingOutcome
    
    public var error: Error? {
      switch outcome {
      case .decodedSuccessfully, .keyNotFound, .valueWasNil:
        return nil
      case .recoveredFrom(let error, _):
        return error
      }
    }
    
    public subscript<U>(
      dynamicMember keyPath: KeyPath<ResilientDecodingOutcome.DictionaryDecodingError<Key, Value>, U>
    ) -> U {
      outcome.dictionaryDecodingError()[keyPath: keyPath]
    }
  }
  
  public var projectedValue: ProjectedValue { ProjectedValue(outcome: outcome) }
  #endif
}

extension LossyDictionary: Decodable where Key: Decodable, Value: Decodable {
  struct DictionaryCodingKey: CodingKey {
    let stringValue: String
    let intValue: Int?

    init?(stringValue: String) {
      self.stringValue = stringValue
      self.intValue = Int(stringValue)
    }

    init?(intValue: Int) {
      self.stringValue = "\(intValue)"
      self.intValue = intValue
    }
  }

  private struct AnyDecodableValue: Decodable {}
  private struct LossyDecodableValue<DecodablValue: Decodable>: Decodable {
    let value: DecodablValue

    public init(from decoder: Decoder) throws {
      let container = try decoder.singleValueContainer()
      self.value = try container.decode(DecodablValue.self)
    }
  }

  public init(from decoder: Decoder) throws {
    // Check for nil first
    do {
      let singleValueContainer = try decoder.singleValueContainer()
      if singleValueContainer.decodeNil() {
        #if DEBUG
        self.init(wrappedValue: [:], outcome: .valueWasNil)
        #else
        self.init(wrappedValue: [:])
        #endif
        return
      }
    } catch {
      // Not nil, continue with dictionary decoding
    }
    
    do {
      var elements: [Key: Value] = [:]
      #if DEBUG
      var results: [Key: Result<Value, Error>] = [:]
      #endif
      
      if Key.self == String.self {
      let container = try decoder.container(keyedBy: DictionaryCodingKey.self)
      let keys = try Self.extractKeys(from: decoder, container: container)

      for (key, stringKey) in keys {
        do {
          let value = try container.decode(LossyDecodableValue<Value>.self, forKey: key).value
          elements[stringKey as! Key] = value
          #if DEBUG
          results[stringKey as! Key] = .success(value)
          #endif
        } catch {
          _ = try? container.decode(AnyDecodableValue.self, forKey: key)
          let decoder = try? container.superDecoder(forKey: key)
          decoder?.reportError(error)
          #if DEBUG
          results[stringKey as! Key] = .failure(error)
          #endif
        }
      }
    } else if Key.self == Int.self {
      let container = try decoder.container(keyedBy: DictionaryCodingKey.self)

      for key in container.allKeys {
        guard key.intValue != nil else {
          // Skip non-integer keys instead of throwing
          continue
        }

        do {
          let value = try container.decode(LossyDecodableValue<Value>.self, forKey: key).value
          elements[key.intValue! as! Key] = value
          #if DEBUG
          results[key.intValue! as! Key] = .success(value)
          #endif
        } catch {
          _ = try? container.decode(AnyDecodableValue.self, forKey: key)
          let decoder = try? container.superDecoder(forKey: key)
          decoder?.reportError(error)
          #if DEBUG
          results[key.intValue! as! Key] = .failure(error)
          #endif
        }
      }
    } else {
      throw DecodingError.dataCorrupted(
        DecodingError.Context(
          codingPath: decoder.codingPath,
          debugDescription: "Unable to decode key type."
        )
      )
    }

      #if DEBUG
      if elements.count == results.count {
        self.init(wrappedValue: elements, outcome: .decodedSuccessfully)
      } else {
        let error = ResilientDecodingOutcome.DictionaryDecodingError(results: results)
        self.init(wrappedValue: elements, outcome: .recoveredFrom(error, wasReported: false))
      }
      #else
      self.init(wrappedValue: elements)
      #endif
    } catch {
      decoder.reportError(error)
      #if DEBUG
      self.init(wrappedValue: [:], outcome: .recoveredFrom(error, wasReported: true))
      #else
      self.init(wrappedValue: [:])
      #endif
    }
  }

  private static func extractKeys(
    from decoder: Decoder,
    container: KeyedDecodingContainer<DictionaryCodingKey>
  ) throws -> [(DictionaryCodingKey, String)] {
    // Decode a dictionary ignoring the values to decode the original keys
    // without using the `JSONDecoder.KeyDecodingStrategy`.
    let keys = try decoder.singleValueContainer().decode([String: AnyDecodableValue].self).keys

    return zip(
      container.allKeys.sorted(by: { $0.stringValue < $1.stringValue }),
      keys.sorted()
    )
    .map { ($0, $1) }
  }
}

extension LossyDictionary: Encodable where Key: Encodable, Value: Encodable {
  public func encode(to encoder: Encoder) throws {
    try wrappedValue.encode(to: encoder)
  }
}

extension LossyDictionary: Equatable where Value: Equatable {
  public static func ==(lhs: Self, rhs: Self) -> Bool {
    lhs.wrappedValue == rhs.wrappedValue
  }
}

extension LossyDictionary: Sendable where Key: Sendable, Value: Sendable {}

// MARK: - KeyedDecodingContainer

extension KeyedDecodingContainer {
  public func decode<DictKey, DictValue>(_: LossyDictionary<DictKey, DictValue>.Type, forKey key: Key) throws -> LossyDictionary<DictKey, DictValue> where DictKey: Hashable & Decodable, DictValue: Decodable {
    if let value = try decodeIfPresent(LossyDictionary<DictKey, DictValue>.self, forKey: key) {
      return value
    } else {
      #if DEBUG
      return LossyDictionary(wrappedValue: [:], outcome: .keyNotFound)
      #else
      return LossyDictionary(wrappedValue: [:])
      #endif
    }
  }
}
