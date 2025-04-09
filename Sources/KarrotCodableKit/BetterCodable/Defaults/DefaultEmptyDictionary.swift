//
//  DefaultEmptyDictionary.swift
//  KarrotCodableKit
//
//  Created by Elon on 4/9/25.
//

import Foundation

public struct DefaultEmptyDictionaryStrategy<
  Key: Decodable & Hashable,
  Value: Decodable
>: DefaultCodableStrategy {
  public static var defaultValue: [Key: Value] { [:] }
}

/// Decodes Dictionaries returning an empty dictionary instead of nil if applicable
///
/// `@DefaultEmptyDictionary` decodes Dictionaries and returns an empty dictionary instead of nil if the Decoder is unable
/// to decode the container.
public typealias DefaultEmptyDictionary<
  Key: Decodable & Hashable,
  Value: Decodable
> = DefaultCodable<DefaultEmptyDictionaryStrategy<Key, Value>>
