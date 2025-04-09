//
//  DefaultZeroInt.swift
//  KarrotCodableKit
//
//  Created by Elon on 4/9/25.
//

import Foundation

public struct DefaultZeroIntStrategy: DefaultCodableStrategy {
  public static var defaultValue: Int { .zero }
}

/// Decodes Int returning an 0 instead of nil if applicable
///
/// `@DefaultZeroInt` decodes Int and returns an 0 instead of nil if the Decoder is unable to decode the
/// container.
public typealias DefaultZeroInt = DefaultCodable<DefaultZeroIntStrategy>
