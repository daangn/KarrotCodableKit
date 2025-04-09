//
//  DefaultEmptyString.swift
//  KarrotCodableKit
//
//  Created by Elon on 4/9/25.
//

import Foundation

public struct DefaultEmptyStringStrategy: DefaultCodableStrategy {
  public static var defaultValue: String { "" }
}

/// Decodes String returning an empty string instead of nil if applicable
///
/// `@DefaultEmptyString` decodes String and returns an empty string instead of nil if the Decoder is unable to decode the
/// container.
public typealias DefaultEmptyString = DefaultCodable<DefaultEmptyStringStrategy>
