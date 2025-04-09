//
//  DefaultZeroDouble.swift
//  KarrotCodableKit
//
//  Created by Elon on 4/9/25.
//

import Foundation

public struct DefaultZeroDoubleStrategy: DefaultCodableStrategy {
  public static var defaultValue: Double { .zero }
}

/// Decodes Double returning an 0.0 instead of nil if applicable
///
/// `@DefaultZeroDouble` decodes Double and returns an 0 instead of nil if the Decoder is unable to decode the
/// container.
public typealias DefaultZeroDouble = DefaultCodable<DefaultZeroDoubleStrategy>
