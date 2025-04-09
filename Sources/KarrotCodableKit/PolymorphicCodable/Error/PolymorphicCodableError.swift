//
//  PolymorphicCodableError.swift
//  KarrotCodableKit
//
//  Created by Elon on 10/16/24.
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

import Foundation

public enum PolymorphicCodableError: LocalizedError {
  case unableToFindPolymorphicType(String)
  case unableToCast(decoded: PolymorphicDecodableType, into: String)
  case unableToRepresentAsPolymorphicForEncoding(String)

  public var errorDescription: String? {
    switch self {
    case .unableToFindPolymorphicType(let polymorphicTypeIdentifier):
      "No matching type found for polymorphic type identifier \"\(polymorphicTypeIdentifier)\"."
    case .unableToCast(let decodeValue, let into):
      "Unable to cast decoded value '\(decodeValue)' to type '\(into)'."
    case .unableToRepresentAsPolymorphicForEncoding(let encodeValue):
      "Unable to cast value '\(encodeValue)' to PolymorphicEncodable for encoding."
    }
  }
}
