//
//  RawRepresentableTests.swift
//  CodableKitTests
//
//  Created by Elon on 2023/04/25.
//  Copyright © 2023 Danggeun Market Inc. All rights reserved.
//

import XCTest

@testable import KarrotCodableKit

class RawRepresentableTests: XCTestCase {

  func testEnumDecodingWithDefaultValue() throws {
    enum VehicleType: String, Codable, DefaultCodableStrategy {
      case car
      case motorcycle
      case unknown

      static var defaultValue: VehicleType {
        .unknown
      }
    }

    struct Vehicle: Codable {
      let name: String
      @DefaultCodable<VehicleType>
      var vehicleType: VehicleType
    }

    let json = "{ \"name\": \"Tesla\", \"vehicleType\": \"electric\" }".data(using: .utf8)!

    let car = try JSONDecoder().decode(Vehicle.self, from: json)
    XCTAssertEqual(car.vehicleType, .unknown)
  }
}
