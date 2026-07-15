//
//  Encodable+ToDictionaryTests.swift
//  KarrotCodableKit
//
//  Created by Kanghoon Oh on 7/10/23.
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

import Foundation
import Testing

import KarrotCodableKit

struct Encodable_ToDictionaryTests {

  @Test
  func `to dictionary`() throws {
    // given
    let dummy = ObjectDummy(
      id: 1,
      name: "ray",
      wallet: ObjectDummy.Wallet(money: 1000),
    )

    // when
    let dict = try dummy.toDictionary()

    // then
    #expect(dict["id"] as? Int == 1)
    #expect(dict["name"] as? String == "ray")

    let wallet = dict["wallet"] as? [String: Any]
    #expect(wallet?["money"] as? Int == 1000)
  }

  @Test
  func `as dictionary optional`() throws {
    // given
    let dummy = OptionalDummy(value: nil)

    // when
    let dict = try dummy.toDictionary()

    // then
    #expect(dict.count == 0)
  }
}

private struct ObjectDummy: Codable {
  let id: Int
  let name: String
  let wallet: Wallet

  struct Wallet: Codable {
    let money: Int
  }
}

private struct OptionalDummy: Codable {
  let value: Int?
}
