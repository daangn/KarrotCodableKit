//
//  CustomEncodable.swift
//  KarrotCodableKit
//
//  Created by Elon on 10/10/23.
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//
//

/**
 A macro that automatically generates `CodingKeys` and adopts the `Codable` protocol.

 This macro simplifies the process of making types Codable by generating all the necessary
 boilerplate code. For properties requiring custom key names, use the `@CodableKey` macro.

 - Parameter codingKeyStyle: Specifies the naming convention to use when generating `CodingKeys`.
   When set to `.snakeCase`, property names will be converted to snake_case in the JSON.
   Default is `.default` which preserves the original property names.

 - Warning: This macro cannot be used with enum types.

 ## Example
 **AS-IS**
 ```swift
 @CustomCodable(codingKeyStyle: .snakeCase)
 struct Person {
   let name: String
   let userAge: Int

   @CodableKey(name: "userProfileUrl")
   let userProfileURL: String
 }
 ```

 **TO-BE**
 ```swift
 struct Person {
   let name: String
   let userAge: Int
   let userProfileURL: String

   enum CodingKeys: String, CodingKey {
     case name
     case userAge = "user_age"
     case userProfileURL = "userProfileUrl"
   }
 }

 extension Person: Codable {
 }
 ```
 */
@attached(extension, conformances: Codable)
@attached(member, names: named(CodingKeys))
public macro CustomCodable(codingKeyStyle: CodingKeyStyle = .default) = #externalMacro(
  module: "KarrotCodableKitMacros",
  type: "CustomCodableMacro"
)
