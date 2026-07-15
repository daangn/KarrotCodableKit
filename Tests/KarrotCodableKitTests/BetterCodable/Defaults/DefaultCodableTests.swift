//
//  DefaultCodableTests.swift
//  KarrotCodableKit
//
//  Created by Elon on 2023/04/25.
//

import Foundation
import Testing

import KarrotCodableKit

// MARK: - Date Decoding Strategy

extension Date {
  fileprivate enum DefaultToNow: DefaultCodableStrategy {
    static var defaultValue: Date { Date() }
  }
}

private let iso8601: DateFormatter = {
  let iso8601 = DateFormatter()
  iso8601.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
  iso8601.timeZone = TimeZone(secondsFromGMT: 0)
  iso8601.locale = Locale(identifier: "en_US_POSIX")
  return iso8601
}()

extension JSONDecoder {
  fileprivate static var iso: JSONDecoder {
    let encoder = JSONDecoder()
    encoder.dateDecodingStrategy = .formatted(iso8601)
    return encoder
  }
}

extension JSONEncoder {
  fileprivate static var iso: JSONEncoder {
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .formatted(iso8601)
    return encoder
  }
}

struct DefaultCodableTest_DateStrategy {
  struct Fixture: Equatable, Codable {
    @DefaultCodable<Date.DefaultToNow>
    fileprivate var discoverDate: Date
  }

  @Test
  func `decoding and encoding with date strategy`() throws {
    let expectedDate = Date(timeIntervalSinceReferenceDate: 222601260)
    let jsonData = #"{ "discoverDate": "2008-01-21T09:41:00.000Z" }"#.data(using: .utf8)!
    let fixture = try JSONDecoder.iso.decode(Fixture.self, from: jsonData)
    #expect(fixture.discoverDate == expectedDate)

    let data = try JSONEncoder.iso.encode(fixture)
    let str = String(data: data, encoding: .utf8)
    #expect(str == #"{"discoverDate":"2008-01-21T09:41:00.000Z"}"#)
  }
}

// MARK: - Nested Property Wrapper

struct DefaultCodableTest_NestedPropertyWrapper {
  enum DefaultToNowTimeStampDateValue: DefaultCodableStrategy {
    static var defaultValue: DateValue<TimestampStrategy> {
      .init(wrappedValue: Date(timeIntervalSince1970: 0))
    }
  }

  struct Fixture: Codable {
    @DefaultCodable<DefaultToNowTimeStampDateValue>
    @DateValue<TimestampStrategy>
    var returnDate: Date
  }

  @Test
  func `nested property wrappers can merge default codable with date strategy`() throws {
    let _1970 = Date(timeIntervalSince1970: 0)
    let _1971 = Date(timeIntervalSince1970: 31536000)

    let jsonData1 = #"{ "returnDate": null }"#.data(using: .utf8)!
    let jsonData2 = #"{ }"#.data(using: .utf8)!
    let jsonData3 = #"{ "returnDate": 31536000 }"#.data(using: .utf8)!

    let fixture1 = try JSONDecoder().decode(Fixture.self, from: jsonData1)
    let fixture2 = try JSONDecoder().decode(Fixture.self, from: jsonData2)
    let fixture3 = try JSONDecoder().decode(Fixture.self, from: jsonData3)

    #expect(fixture1.returnDate == _1970)
    #expect(fixture2.returnDate == _1970)
    #expect(fixture3.returnDate == _1971)
  }
}

// MARK: - Types with Containers

struct DefaultCodableTests_TypesWithContainers {
  struct ArrayContainer: Codable {
    var value: [Int]
  }

  enum DefaultArrayContainerType: DefaultCodableStrategy {
    static var defaultValue: ArrayContainer { .init(value: [3, 7]) }
  }

  struct DictionaryContainer: Codable {
    var value: [String: Int]
  }

  enum DefaultDictionaryContainerType: DefaultCodableStrategy {
    static var defaultValue: DictionaryContainer { .init(value: ["a": 1]) }
  }

  struct Fixture: Codable {
    @DefaultCodable<DefaultArrayContainerType>
    public var type: ArrayContainer
  }

  struct Fixture2: Codable {
    @DefaultCodable<DefaultDictionaryContainerType>
    public var type: DictionaryContainer
  }

  @Test
  func `decoding and encoding with array container`() throws {
    let jsonData = #"{ "type": { "value": [2, 4, 6] } }"#.data(using: .utf8)!
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)
    #expect(fixture.type.value == [2, 4, 6])

    let data = try JSONEncoder().encode(fixture)
    let str = String(data: data, encoding: .utf8)
    #expect(str == #"{"type":{"value":[2,4,6]}}"#)
  }

  @Test
  func `decoding and encoding with dictionary container`() throws {
    let jsonData = #"{ "type": { "value": {"b": 17 } } }"#.data(using: .utf8)!
    let fixture = try JSONDecoder().decode(Fixture2.self, from: jsonData)
    #expect(fixture.type.value == ["b": 17])

    let data = try JSONEncoder().encode(fixture)
    let str = String(data: data, encoding: .utf8)
    #expect(str == #"{"type":{"value":{"b":17}}}"#)
  }
}

// MARK: - Enums with Associated Values

struct DefaultCodableTests_EnumWithAssociatedValue {
  enum Zar: Equatable {
    case ziz(Int)
    case zaz(Int)
  }

  struct CustomType: Codable, Equatable {
    private enum CodingKeys: String, CodingKey {
      case z = "fish"
      case i = "int"
    }

    var z: Zar

    init(z: Zar) {
      self.z = z
    }

    init(from decoder: Decoder) throws {
      let c = try decoder.container(keyedBy: CodingKeys.self)
      let k = try c.decode(String.self, forKey: .z)
      let i = try c.decode(Int.self, forKey: .i)

      if k == "ziz" { z = .ziz(i) }
      else { z = .zaz(i) }
    }

    func encode(to encoder: Encoder) throws {
      var c = encoder.container(keyedBy: CodingKeys.self)
      switch z {
      case .ziz(let i):
        try c.encode("ziz", forKey: .z)
        try c.encode(i, forKey: .i)

      case .zaz(let i):
        try c.encode("zaz", forKey: .z)
        try c.encode(i, forKey: .i)
      }
    }

    enum Default42: DefaultCodableStrategy {
      static var defaultValue: CustomType { .init(z: .zaz(42)) }
    }
  }

  struct Fixture: Equatable, Codable {
    @DefaultCodable<CustomType.Default42>
    public var value: CustomType
  }

  @Test
  func `decoding and encoding custom enum with associated value`() throws {
    let jsonData = #"{ "value": { "fish": "ziz", "int": 4 } }"#.data(using: .utf8)!
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)
    #expect(fixture.value.z == .ziz(4))

    let encoder = JSONEncoder()
    encoder.outputFormatting = .sortedKeys

    let data = try encoder.encode(fixture)
    let str = String(data: data, encoding: .utf8)
    #expect(str == #"{"value":{"fish":"ziz","int":4}}"#)
  }
}
