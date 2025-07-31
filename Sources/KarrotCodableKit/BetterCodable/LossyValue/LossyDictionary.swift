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

  public let outcome: ResilientDecodingOutcome

  public init(wrappedValue: [Key: Value]) {
    self.wrappedValue = wrappedValue
    self.outcome = .decodedSuccessfully
  }

  init(wrappedValue: [Key: Value], outcome: ResilientDecodingOutcome) {
    self.wrappedValue = wrappedValue
    self.outcome = outcome
  }

  #if DEBUG
  public var projectedValue: ResilientDictionaryProjectedValue<Key, Value> {
    ResilientDictionaryProjectedValue(outcome: outcome)
  }
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

  private struct ExtractedKey {
    let codingKey: DictionaryCodingKey
    let originalKey: String
  }

  private struct DecodingState {
    var elements: [Key: Value] = [:]
    #if DEBUG
    var results: [Key: Result<Value, Error>] = [:]
    #endif
  }

  private static func decodeNilValue(from decoder: Decoder) -> Bool {
    do {
      let singleValueContainer = try decoder.singleValueContainer()
      return singleValueContainer.decodeNil()
    } catch {
      return false
    }
  }

  private static func decodeStringKeyedDictionary(
    from decoder: Decoder
  ) throws -> DecodingState {
    guard Key.self == String.self else {
      fatalError("This method should only be called for String keys")
    }

    var state = DecodingState()
    let container = try decoder.container(keyedBy: DictionaryCodingKey.self)
    let keys = try extractKeys(from: decoder, container: container)

    for extractedKey in keys {
      decodeSingleKeyValue(
        container: container,
        key: extractedKey.codingKey,
        originalKey: extractedKey.originalKey,
        state: &state
      )
    }

    return state
  }

  private static func decodeIntKeyedDictionary(
    from decoder: Decoder
  ) throws -> DecodingState {
    guard Key.self == Int.self else {
      fatalError("This method should only be called for Int keys")
    }

    var state = DecodingState()
    let container = try decoder.container(keyedBy: DictionaryCodingKey.self)

    for key in container.allKeys {
      guard let intValue = key.intValue else {
        // Skip non-integer keys instead of throwing
        continue
      }

      decodeSingleKeyValueForInt(
        container: container,
        key: key,
        intKey: intValue,
        state: &state
      )
    }

    return state
  }

  private static func decodeSingleKeyValue(
    container: KeyedDecodingContainer<DictionaryCodingKey>,
    key: DictionaryCodingKey,
    originalKey: String,
    state: inout DecodingState
  ) {
    // Safe casting - if it fails, we skip this key entirely
    guard let castKey = originalKey as? Key else { return }

    do {
      let value = try container.decode(LossyDecodableValue<Value>.self, forKey: key).value
      state.elements[castKey] = value
      #if DEBUG
      state.results[castKey] = .success(value)
      #endif
    } catch {
      _ = try? container.decode(AnyDecodableValue.self, forKey: key)
      let decoder = try? container.superDecoder(forKey: key)
      decoder?.reportError(error)
      #if DEBUG
      state.results[castKey] = .failure(error)
      #endif
    }
  }

  private static func decodeSingleKeyValueForInt(
    container: KeyedDecodingContainer<DictionaryCodingKey>,
    key: DictionaryCodingKey,
    intKey: Int,
    state: inout DecodingState
  ) {
    // Safe casting - if it fails, we skip this key entirely
    guard let castKey = intKey as? Key else { return }

    do {
      let value = try container.decode(LossyDecodableValue<Value>.self, forKey: key).value
      state.elements[castKey] = value
      #if DEBUG
      state.results[castKey] = .success(value)
      #endif
    } catch {
      _ = try? container.decode(AnyDecodableValue.self, forKey: key)
      let decoder = try? container.superDecoder(forKey: key)
      decoder?.reportError(error)
      #if DEBUG
      state.results[castKey] = .failure(error)
      #endif
    }
  }

  private static func createFinalResult(from state: DecodingState) -> LossyDictionary {
    #if DEBUG
    if state.elements.count == state.results.count {
      return LossyDictionary(wrappedValue: state.elements, outcome: .decodedSuccessfully)
    } else {
      let error = ResilientDecodingOutcome.DictionaryDecodingError(results: state.results)
      return LossyDictionary(wrappedValue: state.elements, outcome: .recoveredFrom(error, wasReported: false))
    }
    #else
    return LossyDictionary(wrappedValue: state.elements)
    #endif
  }

  public init(from decoder: Decoder) throws {
    // Check for nil first
    if Self.decodeNilValue(from: decoder) {
      #if DEBUG
      self.init(wrappedValue: [:], outcome: .valueWasNil)
      #else
      self.init(wrappedValue: [:])
      #endif
      return
    }

    do {
      let state: DecodingState

      if Key.self == String.self {
        state = try Self.decodeStringKeyedDictionary(from: decoder)
      } else if Key.self == Int.self {
        state = try Self.decodeIntKeyedDictionary(from: decoder)
      } else {
        throw DecodingError.dataCorrupted(
          DecodingError.Context(
            codingPath: decoder.codingPath,
            debugDescription: "Unable to decode key type."
          )
        )
      }

      self = Self.createFinalResult(from: state)
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
  ) throws -> [ExtractedKey] {
    // Decode a dictionary ignoring the values to decode the original keys
    // without using the `JSONDecoder.KeyDecodingStrategy`.
    let keys = try decoder.singleValueContainer().decode([String: AnyDecodableValue].self).keys

    return zip(
      container.allKeys.sorted(by: { $0.stringValue < $1.stringValue }),
      keys.sorted()
    )
    .map { ExtractedKey(codingKey: $0, originalKey: $1) }
  }
}

extension LossyDictionary: Encodable where Key: Encodable, Value: Encodable {
  public func encode(to encoder: Encoder) throws {
    try wrappedValue.encode(to: encoder)
  }
}

extension LossyDictionary: Equatable where Value: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.wrappedValue == rhs.wrappedValue
  }
}

extension LossyDictionary: Sendable where Key: Sendable, Value: Sendable {}

// MARK: - KeyedDecodingContainer

extension KeyedDecodingContainer {
  public func decode<DictKey, DictValue>(
    _: LossyDictionary<DictKey, DictValue>.Type,
    forKey key: Key
  ) throws -> LossyDictionary<DictKey, DictValue>
    where DictKey: Hashable & Decodable, DictValue: Decodable
  {
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
