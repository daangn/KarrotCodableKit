//
//  Decoder+Polymorphic.swift
//  KarrotCodableKit
//
//  Created by Elon on 10/16/24.
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

import Foundation

extension Decoder {
  public func decode<ExpectedType, PolymorphicMetaCodingKey: CodingKey>(
    codingKey: PolymorphicMetaCodingKey,
    matchingTypes: [PolymorphicDecodableType.Type],
    fallbackType: PolymorphicDecodableType.Type?
  ) throws -> ExpectedType {
    let container = try container(keyedBy: PolymorphicMetaCodingKey.self)
    let polymorphicTypeIdentifier = try container.decode(String.self, forKey: codingKey)

    let matchingType = matchingTypes.first { type in
      type.polymorphicIdentifier == polymorphicTypeIdentifier
    } ?? fallbackType

    guard let matchingType else {
      throw PolymorphicCodableError.unableToFindPolymorphicType(polymorphicTypeIdentifier)
    }

    let decodedValue = try matchingType.init(from: self)

    guard let expectedValue = decodedValue as? ExpectedType else {
      throw PolymorphicCodableError.unableToCast(
        decoded: decodedValue,
        into: String(describing: ExpectedType.self)
      )
    }

    return expectedValue
  }
}
