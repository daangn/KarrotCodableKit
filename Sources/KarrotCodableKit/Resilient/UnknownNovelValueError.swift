//
//  UnknownNovelValueError.swift
//  KarrotCodableKit
//
//  Created by Elon on 2025/01/23.
//

import Foundation

/// An error that indicates a RawRepresentable type received an unknown raw value during decoding.
///
/// This error is thrown when a RawRepresentable type with `isFrozen == false` encounters a raw value
/// that doesn't correspond to any known case. When `isFrozen == true`, a standard `DecodingError` is thrown instead.
public struct UnknownNovelValueError: Error {
  /// The raw value that could not be matched to any known case
  public let novelValue: Any
  
  public init(novelValue: Any) {
    self.novelValue = novelValue
  }
}

extension UnknownNovelValueError: LocalizedError {
  public var errorDescription: String? {
    "Unknown raw value: \(novelValue)"
  }
}

extension UnknownNovelValueError: CustomStringConvertible {
  public var description: String {
    "UnknownNovelValueError(novelValue: \(novelValue))"
  }
}