//
//  OptionalDateValueTests.swift
//  KarrotCodableKit
//
//  Created by Ray on 8/9/24.
//  Copyright © 2024 Danggeun Market Inc. All rights reserved.
//

import XCTest

import KarrotCodableKit

final class OptionalDateValueTests: XCTestCase {

  func testDecodingAndEncodingISO8601DateString() throws {
    struct Fixture: Codable {
      @OptionalDateValue<ISO8601Strategy> var iso8601: Date?
    }

    // given
    let jsonData = #"{"iso8601": "1996-12-19T16:39:57-08:00"}"#.data(using: .utf8)!

    // when
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)

    // then
    XCTAssertEqual(fixture.iso8601, Date(timeIntervalSince1970: 851042397))
  }

  func testDecodingAndEncodingOptionalISO8601DateString() throws {
    struct Fixture: Codable {
      @OptionalDateValue<ISO8601Strategy> var iso8601: Date?
    }

    // given
    let jsonData = #"{"iso8601": null}"#.data(using: .utf8)!

    // when
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)

    // then
    XCTAssertNil(fixture.iso8601)
  }

  func testDecodingAndEncodingNotPresentISO8601DateString() throws {
    struct Fixture: Codable {
      @OptionalDateValue<ISO8601Strategy> var iso8601: Date?
    }

    // given
    let jsonData = #"{}"#.data(using: .utf8)!

    // when
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)

    // then
    XCTAssertNil(fixture.iso8601)
  }

  func testDecodingAndEncodingISO8601DateStringWithFractionalSeconds() throws {
    struct Fixture: Codable {
      @OptionalDateValue<ISO8601WithFractionalSecondsStrategy> var iso8601: Date?
      @OptionalDateValue<ISO8601WithFractionalSecondsStrategy> var iso8601Short: Date?
    }

    // given
    let jsonData = """
      {
        "iso8601": "1996-12-19T16:39:57.123456Z",
        "iso8601Short": "1996-12-19T16:39:57.000Z-08:00"
      }
      """.data(using: .utf8)!

    // when
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)

    // then
    XCTAssertEqual(fixture.iso8601Short, Date(timeIntervalSince1970: 851013597.0))
    XCTAssertEqual(fixture.iso8601, Date(timeIntervalSince1970: 851013597.123))
  }

  func testDecodingAndEncodingRFC3339DateString() throws {
    struct Fixture: Codable {
      @OptionalDateValue<RFC3339Strategy> var rfc3339Date: Date?
    }

    // given
    let jsonData = #"{"rfc3339Date": "1996-12-19T16:39:57-08:00"}"#.data(using: .utf8)!

    // when
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)

    // then
    XCTAssertEqual(fixture.rfc3339Date, Date(timeIntervalSince1970: 851042397))
  }

  func testDecodingAndEncodingOptionalRFC3339DateString() throws {
    struct Fixture: Codable {
      @OptionalDateValue<RFC3339Strategy> var rfc3339Date: Date?
    }

    // given
    let jsonData = #"{"rfc3339Date": null}"#.data(using: .utf8)!

    // when
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)

    // then
    XCTAssertNil(fixture.rfc3339Date)
  }

  func testDecodingAndEncodingNotPresentRFC3339DateString() throws {
    struct Fixture: Codable {
      @OptionalDateValue<RFC3339Strategy> var rfc3339Date: Date?
    }

    // given
    let jsonData = #"{}"#.data(using: .utf8)!

    // when
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)

    // then
    XCTAssertNil(fixture.rfc3339Date)
  }

  func testDecodingRFC3339NanoDateString() throws {
    struct Fixture: Codable {
      @OptionalDateValue<RFC3339NanoStrategy> var rfc3339Date1: Date?
      @OptionalDateValue<RFC3339NanoStrategy> var rfc3339Date2: Date?
      @OptionalDateValue<RFC3339NanoStrategy> var rfc3339Date3: Date?
      @OptionalDateValue<RFC3339NanoStrategy> var rfc3339Date4: Date?
      @OptionalDateValue<RFC3339NanoStrategy> var rfc3339Date5: Date?
      @OptionalDateValue<RFC3339NanoStrategy> var rfc3339Date6: Date?
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
    XCTAssertEqual(fixture.rfc3339Date1, Date(timeIntervalSince1970: 851042397.0))
    XCTAssertEqual(fixture.rfc3339Date2, Date(timeIntervalSince1970: 851042397.0))
    XCTAssertEqual(fixture.rfc3339Date3, Date(timeIntervalSince1970: 1720617749.481))
    XCTAssertEqual(fixture.rfc3339Date4, Date(timeIntervalSince1970: 1720588949.481))
    XCTAssertEqual(fixture.rfc3339Date5, Date(timeIntervalSince1970: 1715082540.000))
    XCTAssertEqual(fixture.rfc3339Date6, Date(timeIntervalSince1970: 1715082540.000))
  }

  func testDecodingAndEncodingUTCTimestamp() throws {
    struct Fixture: Codable {
      @OptionalDateValue<TimestampStrategy> var timestamp: Date?
    }

    // given
    let jsonData = #"{"timestamp": 851042397.0}"#.data(using: .utf8)!

    // when
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)

    // then
    XCTAssertEqual(fixture.timestamp, Date(timeIntervalSince1970: 851042397))
  }

  func testDecodingAndEncodingOptionalUTCTimestamp() throws {
    struct Fixture: Codable {
      @OptionalDateValue<TimestampStrategy> var timestamp: Date?
    }

    // given
    let jsonData = #"{"timestamp": null}"#.data(using: .utf8)!

    // when
    let fixture = try JSONDecoder().decode(Fixture.self, from: jsonData)

    // then
    XCTAssertNil(fixture.timestamp)
  }

  func testDecodingAndEncodingWithCustomStrategies() throws {
    struct Fixture: Codable {
      @OptionalDateValue<TimestampStrategy> var timeStamp: Date?
    }

    // given
    let jsonData = #"{"time_stamp": 851042397.0}"#.data(using: .utf8)!

    // when
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    decoder.dateDecodingStrategy = .iso8601
    let fixture = try decoder.decode(Fixture.self, from: jsonData)

    // then
    XCTAssertEqual(fixture.timeStamp, Date(timeIntervalSince1970: 851042397))

    // when
    let encoder = JSONEncoder()
    encoder.keyEncodingStrategy = .convertToSnakeCase
    encoder.dateEncodingStrategy = .iso8601
    let data = try encoder.encode(fixture)
    let fixture2 = try decoder.decode(Fixture.self, from: data)

    // then
    XCTAssertEqual(fixture2.timeStamp, Date(timeIntervalSince1970: 851042397))
  }
}
