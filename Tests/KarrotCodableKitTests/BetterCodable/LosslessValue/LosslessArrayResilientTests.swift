//
//  LosslessArrayResilientTests.swift
//  KarrotCodableKitTests
//
//  Created by Elon on 4/9/25.
//

import Testing
import Foundation
@testable import KarrotCodableKit

@Suite("LosslessArray Resilient Decoding")
struct LosslessArrayResilientTests {
  struct Fixture: Decodable {
    @LosslessArray var stringArray: [String]
    @LosslessArray var intArray: [Int]
    @LosslessArray var doubleArray: [Double]
    
    struct NestedObject: Decodable, Equatable, LosslessStringConvertible {
      let id: Int
      let name: String
      
      init?(_ description: String) {
        return nil // Not convertible from string
      }
      
      var description: String {
        "NestedObject(id: \(id), name: \(name))"
      }
    }
    @LosslessArray var objectArray: [String] // 객체는 String으로 변환될 수 없음
  }
  
  @Test("projected value provides error information for each failed element")
  func testProjectedValueProvidesErrorInfo() throws {
    let json = """
    {
      "stringArray": [1, "two", true, null, 5.5],
      "intArray": ["invalid", 2, 3.14, 4, true],
      "doubleArray": [1.5, "2.5", 3, null, "invalid"],
      "objectArray": [{"id": 1, "name": "test"}, "string"]
    }
    """
    
    let decoder = JSONDecoder()
    let data = json.data(using: .utf8)!
    let fixture = try decoder.decode(Fixture.self, from: data)
    
    // 기본 동작 검증 - 변환 가능한 값들만 포함
    #expect(fixture.stringArray == ["1", "two", "true", "5.5"])
    #expect(fixture.intArray == [2, 4])
    #expect(fixture.doubleArray == [1.5, 2.5, 3.0])  // 1.5, "2.5"->2.5, 3->3.0
    #expect(fixture.objectArray == ["string"])
    
    #if DEBUG
    // projected value로 에러 정보 접근
    #expect(fixture.$stringArray.results.count == 5)
    #expect(fixture.$stringArray.errors.count == 1) // null
    
    #expect(fixture.$intArray.results.count == 5)
    #expect(fixture.$intArray.errors.count == 3) // "invalid", 3.14, true
    
    #expect(fixture.$doubleArray.results.count == 5)
    #expect(fixture.$doubleArray.errors.count == 2) // null, "invalid"
    
    #expect(fixture.$objectArray.results.count == 2)
    #expect(fixture.$objectArray.errors.count == 1) // 객체는 String으로 변환 불가
    #endif
  }
  
  @Test("error reporting with JSONDecoder")
  func testErrorReporting() throws {
    let json = """
    {
      "stringArray": [1, null, "three"],
      "intArray": ["not a number", 2],
      "doubleArray": [1.5, "invalid", null],
      "objectArray": []
    }
    """
    
    let decoder = JSONDecoder()
    let errorReporter = decoder.enableResilientDecodingErrorReporting()
    
    let data = json.data(using: .utf8)!
    _ = try decoder.decode(Fixture.self, from: data)
    
    let errorDigest = errorReporter.flushReportedErrors()
    
    #if DEBUG
    // 에러가 리포트되었는지 확인
    #expect(errorDigest != nil)
    if let digest = errorDigest {
      // null과 변환 실패 에러들
      #expect(digest.errors.count >= 3)
      print("Error digest: \(digest.debugDescription)")
    }
    #else
    #expect(errorDigest == nil)
    #endif
  }
  
  @Test("complete failure results in empty array")
  func testCompleteFailure() throws {
    let json = """
    {
      "stringArray": "not an array",
      "intArray": 123,
      "doubleArray": null,
      "objectArray": true
    }
    """
    
    let decoder = JSONDecoder()
    let data = json.data(using: .utf8)!
    
    do {
      _ = try decoder.decode(Fixture.self, from: data)
      #expect(Bool(false), "Should have thrown")
    } catch {
      // 배열이 아닌 값은 디코딩 실패
    }
  }
  
  @Test("missing keys result in decoding error")
  func testMissingKeys() throws {
    let json = "{}"
    
    let decoder = JSONDecoder()
    let data = json.data(using: .utf8)!
    
    do {
      _ = try decoder.decode(Fixture.self, from: data)
      #expect(Bool(false), "Should have thrown")
    } catch {
      // 필수 프로퍼티이므로 디코딩 실패
    }
  }
}