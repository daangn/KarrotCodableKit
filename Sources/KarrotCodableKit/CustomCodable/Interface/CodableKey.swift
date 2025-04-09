//
//  CustomEncodable.swift
//  KarrotCodableKit
//
//  Created by Elon on 3/6/24.
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//
//

/**
 A macro that allows customizing the key name used in CodingKeys when using `@CustomCodable`,
 `@CustomEncodable`, or `@CustomDecodable`.

 - Parameter name: The string value to use as the coding key name.
   (e.g., `@CodableKey(name: "userProfileUrl")`)

 ## Example

 ```swift
 @CustomCodable(codingKeyStyle: .snakeCase)
 struct Person {
   let name: String
   let userAge: Int

   @CodableKey(name: "userProfileUrl")
   let userProfileURL: String
 }
 ```
 */
@attached(peer)
public macro CodableKey(name: String) = #externalMacro(
  module: "KarrotCodableKitMacros",
  type: "CodableKeyMacro"
)
