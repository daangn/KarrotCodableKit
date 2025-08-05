//
//  Result+Extension.swift
//  KarrotCodableKit
//
//  Created by elon on 7/31/25.
//

import Foundation

extension Result {
  package var isSuccess: Bool {
    switch self {
    case .success: true
    case .failure: false
    }
  }

  package var isFailure: Bool {
    !isSuccess
  }

  package var success: Success? {
    try? get()
  }

  package var failure: Failure? {
    switch self {

    case .success:
      nil
    case .failure(let error):
      error
    }
  }
}
