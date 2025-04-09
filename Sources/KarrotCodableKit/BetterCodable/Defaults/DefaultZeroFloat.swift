//
//  DefaultZeroFloat.swift
//  KarrotCodableKit
//
//  Created by Elon on 4/9/25.
//

import Foundation

public struct DefaultZeroFloatStrategy: DefaultCodableStrategy {
  public static var defaultValue: Float { .zero }
}

/// Decodes Float returning an 0.0 instead of nil if applicable
///
/// `@DefaultZeroFloat` decodes Float and returns an 0 instead of nil if the Decoder is unable to decode the
/// container.
public typealias DefaultZeroFloat = DefaultCodable<DefaultZeroFloatStrategy>
