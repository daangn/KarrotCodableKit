//
//  CustomDateCodableValueTests.swift
//  KarrotCodableKit
//
//  Created by Elon on 2023/04/25.
//

import Testing
import Foundation

import KarrotCodableKit

struct DateValueTests {
  @Test func testDecodingAndEncodingISO8601DateString() throws {
    struct Fixture: Codable {
      @DateValue<ISO8601Strategy> var iso8601: Date
    }

    // given
    let jsonData = #"{"iso8601": "1996-12-19T16:39:57-08:00"}"#.data(using: .utf8)!

    // when
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)

    // then
    #expect(fixture.iso8601 == Date(timeIntervalSince1970: 851042397))
  }

  @Test func testDecodingAndEncodingISO8601DateStringWithFractionalSeconds() throws {
    struct Fixture: Codable {
      @DateValue<ISO8601WithFractionalSecondsStrategy> var iso8601: Date
      @DateValue<ISO8601WithFractionalSecondsStrategy> var iso8601Short: Date
    }

    // given
    let jsonData = """
      {
        "iso8601": "1996-12-19T16:39:57.123456Z",
        "iso8601Short": "1996-12-19T16:39:57.000-08:00"
      }
      """.data(using: .utf8)!

    // when
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)

    // then
    #expect(fixture.iso8601Short == Date(timeIntervalSince1970: 851042397.0))
    #expect(fixture.iso8601 == Date(timeIntervalSince1970: 851013597.123))
  }

  @Test func testDecodingAndEncodingRFC3339DateString() throws {
    struct Fixture: Codable {
      @DateValue<RFC3339Strategy> var rfc3339Date: Date
    }

    // given
    let jsonData = #"{"rfc3339Date": "1996-12-19T16:39:57-08:00"}"#.data(using: .utf8)!

    // when
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)

    // then
    #expect(fixture.rfc3339Date == Date(timeIntervalSince1970: 851042397))
  }

  @Test func testDecodingRFC3339NanoDateString() throws {
    struct Fixture: Codable {
      @DateValue<RFC3339NanoStrategy> var rfc3339Date1: Date
      @DateValue<RFC3339NanoStrategy> var rfc3339Date2: Date
      @DateValue<RFC3339NanoStrategy> var rfc3339Date3: Date
      @DateValue<RFC3339NanoStrategy> var rfc3339Date4: Date
      @DateValue<RFC3339NanoStrategy> var rfc3339Date5: Date
      @DateValue<RFC3339NanoStrategy> var rfc3339Date6: Date
    }

    // given
    let jsonData = """
      {
        "rfc3339Date1": "1996-12-19T16:39:57-08:00",
        "rfc3339Date2": "1996-12-19T16:39:57-0800",
        "rfc3339Date3": "2024-07-10T05:22:29.481633-08:00",
        "rfc3339Date4": "2024-07-10T05:22:29.481633Z",
        "rfc3339Date5": "2024-05-07T11:49:00+0000",
        "rfc3339Date6": "2024-05-07T11:49:00Z",
      }
      """.data(using: .utf8)!

    // when
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)

    // then
    #expect(fixture.rfc3339Date1 == Date(timeIntervalSince1970: 851042397.0))
    #expect(fixture.rfc3339Date2 == Date(timeIntervalSince1970: 851042397.0))
    #expect(fixture.rfc3339Date3 == Date(timeIntervalSince1970: 1720617749.481))
    #expect(fixture.rfc3339Date4 == Date(timeIntervalSince1970: 1720588949.481))
    #expect(fixture.rfc3339Date5 == Date(timeIntervalSince1970: 1715082540.000))
    #expect(fixture.rfc3339Date6 == Date(timeIntervalSince1970: 1715082540.000))
  }

  @Test func testEncodingRFC3339NanoDateToString() throws {
    // given
    let date = Date(timeIntervalSince1970: 1720588949.481)

    // when
    let result = RFC3339NanoStrategy.encode(date)

    // then
    #expect(result == "2024-07-10T05:22:29.481000Z")
  }

  @Test func testDecodingAndEncodingUTCTimestamp() throws {
    struct Fixture: Codable {
      @DateValue<TimestampStrategy> var timestamp: Date
    }
    let jsonData = #"{"timestamp": 851042397.0}"#.data(using: .utf8)!

    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)
    #expect(fixture.timestamp == Date(timeIntervalSince1970: 851042397))
  }

  @Test func testDecodingAndEncodingWithCustomStrategies() throws {
    struct Fixture: Codable {
      @DateValue<TimestampStrategy> var timeStamp: Date
    }
    let jsonData = #"{"time_stamp": 851042397.0}"#.data(using: .utf8)!

    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    decoder.dateDecodingStrategy = .iso8601
    let fixture = try decoder.decode(Fixture.self, from: jsonData)
    #expect(fixture.timeStamp == Date(timeIntervalSince1970: 851042397))

    let encoder = JSONEncoder()
    encoder.keyEncodingStrategy = .convertToSnakeCase
    encoder.dateEncodingStrategy = .iso8601
    let data = try encoder.encode(fixture)
    let fixture2 = try decoder.decode(Fixture.self, from: data)
    #expect(fixture2.timeStamp == Date(timeIntervalSince1970: 851042397))
  }
}
