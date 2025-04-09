//
//  PolymorphicIdentifiable.swift
//  KarrotCodableKit
//
//  Created by Elon on 10/16/24.
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

import Foundation

public protocol PolymorphicIdentifiable {
  static var polymorphicIdentifier: String { get }
}

public typealias PolymorphicCodableType = Codable & PolymorphicIdentifiable
public typealias PolymorphicEncodableType = Encodable & PolymorphicIdentifiable
public typealias PolymorphicDecodableType = Decodable & PolymorphicIdentifiable
