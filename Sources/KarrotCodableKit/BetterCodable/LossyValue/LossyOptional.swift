//
//  DefaultNilStrategy.swift
//  KarrotCodableKit
//
//  Created by Elon on 4/9/25.
//


import Foundation

public struct DefaultNilStrategy<T: Decodable>: DefaultCodableStrategy {
  public static var defaultValue: T? { nil }
}

/// Decodes optional types, defaulting to `nil` instead of throwing an error, if applicable.
///
/// `@LossyOptional` decodes optionals, and defaults to `nil` in cases where the decoder fails
/// (e.g. decoding a non-url string to the `URL` type)
public typealias LossyOptional<T: Decodable> = DefaultCodable<DefaultNilStrategy<T>>
