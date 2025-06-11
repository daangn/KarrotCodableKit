//
//  String+removeBackticks.swift
//  KarrotCodableKit
//
//  Created by elon on 6/11/25.
//

import Foundation

extension String {
  var trimmingBackticks: String {
    trimmingCharacters(in: ["`"])
  }
}
