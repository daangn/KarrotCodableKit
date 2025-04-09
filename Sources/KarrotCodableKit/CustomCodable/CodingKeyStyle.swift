//
//  CodingKeyStyle.swift
//  KarrotCodableKit
//
//  Created by Elon on 11/12/24.
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//
//
    
import Foundation

public enum CodingKeyStyle {
  /// Converts property name to `snake_case` and uses it as CodingKey.
  case snakeCase
  /// Uses property name as is for CodingKey.
  case `default`
}
