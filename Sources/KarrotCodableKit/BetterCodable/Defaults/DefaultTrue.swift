//
//  DefaultTrue.swift
//  KarrotCodableKit
//
//  Created by Elon on 4/9/25.
//

import Foundation

public struct DefaultTrueStrategy: BoolCodableStrategy {
  public static var defaultValue: Bool { true }
}

/// Decodes Bools defaulting to `true` if applicable
///
/// `@DefaultTrue` decodes Bools and defaults the value to true if the Decoder is unable to decode the value.
public typealias DefaultTrue = DefaultCodable<DefaultTrueStrategy>
