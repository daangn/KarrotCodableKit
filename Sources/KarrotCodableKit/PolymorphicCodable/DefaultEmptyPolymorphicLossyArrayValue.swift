//
//  DefaultEmptyPolymorphicLossyArrayValue.swift
//
//
//  Created by Elon on 10/18/24.
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

import Foundation

@propertyWrapper
public struct DefaultEmptyPolymorphicLossyArrayValue<PolymorphicType: PolymorphicCodableStrategy> {
  public var wrappedValue: [PolymorphicType.ExpectedType]

  public init(wrappedValue: [PolymorphicType.ExpectedType]) {
    self.wrappedValue = wrappedValue
  }
}

extension DefaultEmptyPolymorphicLossyArrayValue: Decodable {
  private struct AnyDecodableValue: Decodable {}

  public init(from decoder: Decoder) throws {
    var container = try decoder.unkeyedContainer()

    var elements = [PolymorphicType.ExpectedType?]()
    while !container.isAtEnd {
      do {
        let value = try container.decode(PolymorphicValue<PolymorphicType>.self).wrappedValue
        elements.append(value)
      } catch {
        print("`DefaultEmptyPolymorphicLossyArrayValue` decode catch error: \(error)")

        // Decoding processing to prevent infinite loops if decoding fails.
        _ = try? container.decode(AnyDecodableValue.self)
      }
    }

    wrappedValue = elements.compactMap { $0 }
  }
}

extension DefaultEmptyPolymorphicLossyArrayValue: Encodable {
  public func encode(to encoder: Encoder) throws {
    let polymorphicValues = wrappedValue.map {
      PolymorphicValue<PolymorphicType>(wrappedValue: $0)
    }
    try polymorphicValues.encode(to: encoder)
  }
}

extension DefaultEmptyPolymorphicLossyArrayValue: Equatable where PolymorphicType.ExpectedType: Equatable {}
extension DefaultEmptyPolymorphicLossyArrayValue: Hashable where PolymorphicType.ExpectedType: Hashable {}
extension DefaultEmptyPolymorphicLossyArrayValue: Sendable where PolymorphicType.ExpectedType: Sendable {}
