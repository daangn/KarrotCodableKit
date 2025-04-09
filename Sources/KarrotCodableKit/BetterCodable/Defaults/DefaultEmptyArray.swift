//
//  DefaultEmptyArray.swift
//  KarrotCodableKit
//
//  Created by Elon on 4/9/25.
//

import Foundation

public struct DefaultEmptyArrayStrategy<T: Decodable>: DefaultCodableStrategy {
  public static var defaultValue: [T] { [] }
}

/// Decodes Arrays returning an empty array instead of nil if applicable
///
/// `@DefaultEmptyArray` decodes Arrays and returns an empty array instead of nil if the Decoder is unable to decode the
/// container.
public typealias DefaultEmptyArray<T: Decodable> = DefaultCodable<DefaultEmptyArrayStrategy<T>>
