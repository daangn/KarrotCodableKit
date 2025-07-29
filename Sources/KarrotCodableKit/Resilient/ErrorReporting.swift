//
//  ErrorReporting.swift
//  KarrotCodableKit
//
//  Created by Elon on 4/9/25.
//

import Foundation

// MARK: - Enabling Error Reporting

extension CodingUserInfoKey {
  public static let resilientDecodingErrorReporter = CodingUserInfoKey(
    rawValue: "ResilientDecodingErrorReporter"
  )!
}

extension [CodingUserInfoKey: Any] {
  public mutating func enableResilientDecodingErrorReporting() -> ResilientDecodingErrorReporter {
    let errorReporter = ResilientDecodingErrorReporter()
    _ = replaceResilientDecodingErrorReporter(with: errorReporter)
    return errorReporter
  }

  fileprivate mutating func replaceResilientDecodingErrorReporter(
    with errorReporter: ResilientDecodingErrorReporter
  ) -> Any? {
    if let existingValue = self[.resilientDecodingErrorReporter] {
      assertionFailure()
      if let existingReporter = existingValue as? ResilientDecodingErrorReporter {
        existingReporter.currentDigest.mayBeMissingReportedErrors = true
      }
    }
    self[.resilientDecodingErrorReporter] = errorReporter
    return errorReporter
  }
}

extension JSONDecoder {
  public func enableResilientDecodingErrorReporting() -> ResilientDecodingErrorReporter {
    userInfo.enableResilientDecodingErrorReporting()
  }

  public func decode<T: Decodable>(
    _ type: T.Type,
    from data: Data,
    reportResilientDecodingErrors: Bool
  ) throws -> (T, ErrorDigest?) {
    guard reportResilientDecodingErrors else {
      return (try decode(T.self, from: data), nil)
    }
    let errorReporter = ResilientDecodingErrorReporter()
    let oldValue = userInfo.replaceResilientDecodingErrorReporter(with: errorReporter)
    let value = try decode(T.self, from: data)
    userInfo[.resilientDecodingErrorReporter] = oldValue
    return (value, errorReporter.flushReportedErrors())
  }
}

// MARK: - Accessing Reported Errors

public final class ResilientDecodingErrorReporter {
  public init() {}

  public func flushReportedErrors() -> ErrorDigest? {
    #if DEBUG
    let digest = hasErrors ? currentDigest : nil
    hasErrors = false
    currentDigest = ErrorDigest()
    return digest
    #else
    // Release 빌드에서는 성능 최적화를 위해 에러 정보를 반환하지 않음
    hasErrors = false
    currentDigest = ErrorDigest()
    return nil
    #endif
  }

  func resilientDecodingHandled(_ error: Error, at path: [String]) {
    hasErrors = true
    currentDigest.root.insert(error, at: path)
  }

  fileprivate var currentDigest = ErrorDigest()
  private var hasErrors = false
}

public struct ErrorDigest {
  public var errors: [Error] {
    errors(includeUnknownNovelValueErrors: false)
  }

  public func errors(includeUnknownNovelValueErrors: Bool) -> [Error] {
    let allErrors: [Error] =
      if mayBeMissingReportedErrors {
        [MayBeMissingReportedErrors()] + root.errors
      } else {
        root.errors
      }

    return allErrors.filter { includeUnknownNovelValueErrors || !($0 is UnknownNovelValueError) }
  }

  fileprivate var mayBeMissingReportedErrors = false

  fileprivate struct Node {
    private var children: [String: Node] = [:]
    private var shallowErrors: [Error] = []

    mutating func insert(_ error: Error, at path: some Collection<String>) {
      if let next = path.first {
        children[next, default: Node()].insert(error, at: path.dropFirst())
      } else {
        shallowErrors.append(error)
      }
    }

    var errors: [Error] {
      shallowErrors + children.flatMap { $0.value.errors }
    }
  }

  fileprivate var root = Node()
}

// MARK: - Reporting Errors

extension Decoder {
  public func reportError(_ error: Swift.Error) {
    guard let errorReporterAny = userInfo[.resilientDecodingErrorReporter] else {
      return
    }

    guard let errorReporter = errorReporterAny as? ResilientDecodingErrorReporter else {
      assertionFailure()
      return
    }

    errorReporter.resilientDecodingHandled(error, at: codingPath.map { $0.stringValue })
  }
}

// MARK: - Pretty Printing

#if DEBUG
extension ErrorDigest: CustomDebugStringConvertible {
  public var debugDescription: String {
    root.debugDescriptionLines.joined(separator: "\n")
  }
}

extension ErrorDigest.Node {
  var debugDescriptionLines: [String] {
    let errorLines = shallowErrors.map { "- " + $0.abridgedDescription }.sorted()
    let childrenLines = children
      .sorted(by: { $0.key < $1.key })
      .flatMap { child in
        [child.key] + child.value.debugDescriptionLines.map { "  " + $0 }
      }

    return errorLines + childrenLines
  }
}

extension Error {
  fileprivate var abridgedDescription: String {
    switch self {
    case let decodingError as DecodingError:
      switch decodingError {
      case .dataCorrupted:
        return "Data corrupted"
      case .keyNotFound(let key, _):
        return "Key \"\(key.stringValue)\" not found"
      case .typeMismatch(let attempted, _):
        return "Could not decode as `\(attempted)`"
      case .valueNotFound(let attempted, _):
        return "Expected `\(attempted)` but found null instead"
      @unknown default:
        return localizedDescription
      }

    case let error as UnknownNovelValueError:
      return "Unknown novel value \"\(error.novelValue)\" (this error is not reported by default)"

    default:
      return localizedDescription
    }
  }
}
#endif

// MARK: - Specific Errors

private struct MayBeMissingReportedErrors: Error {}

public struct UnknownNovelValueError: Error {
  public let novelValue: Any

  public init<T>(novelValue: T) {
    self.novelValue = novelValue
  }
}
