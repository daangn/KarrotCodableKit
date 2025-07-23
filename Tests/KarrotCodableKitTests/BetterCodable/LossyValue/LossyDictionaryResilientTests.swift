//
//  LossyDictionaryResilientTests.swift
//  KarrotCodableKitTests
//
//  Created by Elon on 4/9/25.
//

import Testing
import Foundation
@testable import KarrotCodableKit

@Suite("LossyDictionary Resilient Decoding")
struct LossyDictionaryResilientTests {
  struct Fixture: Decodable {
    @LossyDictionary var stringDict: [String: Int]
    @LossyDictionary var intDict: [Int: String]
    
    struct NestedObject: Decodable, Equatable {
      let id: Int
      let name: String
    }
    @LossyDictionary var objectDict: [String: NestedObject]
  }
  
  @Test("projected value provides error information for each failed key-value pair")
  func testProjectedValueProvidesErrorInfo() throws {
    let json = """
    {
      "stringDict": {
        "one": 1,
        "two": "invalid",
        "three": 3,
        "four": null
      },
      "intDict": {
        "1": "first",
        "2": "second",
        "3": "third",
        "invalid": "should be ignored"
      },
      "objectDict": {
        "obj1": {"id": 1, "name": "first"},
        "obj2": {"id": "invalid", "name": "second"},
        "obj3": {"id": 3, "name": "third"}
      }
    }
    """
    
    let decoder = JSONDecoder()
    let data = json.data(using: .utf8)!
    let fixture = try decoder.decode(Fixture.self, from: data)
    
    // 기본 동작 검증 - 유효한 키-값 쌍만 포함
    #expect(fixture.stringDict == ["one": 1, "three": 3])
    #expect(fixture.intDict == [1: "first", 2: "second", 3: "third"]) // Int 키는 모두 유효
    #expect(fixture.objectDict == [
      "obj1": Fixture.NestedObject(id: 1, name: "first"),
      "obj3": Fixture.NestedObject(id: 3, name: "third")
    ])
    
    #if DEBUG
    // projected value로 에러 정보 접근
    #expect(fixture.$stringDict.results.count == 4)
    #expect(fixture.$stringDict.errors.count == 2) // "invalid"와 null
    
    // 각 키의 성공/실패 확인
    let stringResults = fixture.$stringDict.results
    #expect(stringResults["one"] != nil)
    if let result = stringResults["one"], case .success(let value) = result {
      #expect(value == 1)
    }
    #expect(stringResults["two"] != nil)
    if let result = stringResults["two"], case .failure = result {
      // Expected failure
    }
    
    // intDict 검증 - Int 키 타입  
    #expect(fixture.$intDict.errors.count == 0) // 모든 키가 유효
    
    // objectDict 검증
    #expect(fixture.$objectDict.results.count == 3)
    #expect(fixture.$objectDict.errors.count == 1) // "invalid" id
    #endif
  }
  
  @Test("error reporting with JSONDecoder")
  func testErrorReporting() throws {
    let json = """
    {
      "stringDict": {
        "a": "not a number",
        "b": 2,
        "c": false
      },
      "intDict": {},
      "objectDict": {}
    }
    """
    
    let decoder = JSONDecoder()
    let errorReporter = decoder.enableResilientDecodingErrorReporting()
    
    let data = json.data(using: .utf8)!
    let fixture = try decoder.decode(Fixture.self, from: data)
    
    let errorDigest = errorReporter.flushReportedErrors()
    
    #if DEBUG
    // 에러가 리포트되었는지 확인
    #expect(errorDigest != nil)
    if let digest = errorDigest {
      #expect(digest.errors.count >= 2) // "a"와 "c" 키의 에러
      print("Error digest: \(digest.debugDescription)")
    }
    #else
    #expect(errorDigest == nil)
    #endif
  }
  
  @Test("complete failure results in empty dictionary")
  func testCompleteFailure() throws {
    let json = """
    {
      "stringDict": "not a dictionary",
      "intDict": 123,
      "objectDict": null
    }
    """
    
    let decoder = JSONDecoder()
    let data = json.data(using: .utf8)!
    
    let fixture = try decoder.decode(Fixture.self, from: data)
    
    #expect(fixture.stringDict == [:])
    #expect(fixture.intDict == [:])
    #expect(fixture.objectDict == [:])
    
    #if DEBUG
    // 전체 딕셔너리 디코딩 실패 시 에러 정보
    #expect(fixture.$stringDict.error != nil)
    #expect(fixture.$intDict.error != nil)
    #expect(fixture.$objectDict.error == nil) // null은 에러가 아님
    #endif
  }
  
  @Test("missing keys result in empty dictionary")
  func testMissingKeys() throws {
    let json = "{}"
    
    let decoder = JSONDecoder()
    let data = json.data(using: .utf8)!
    
    let fixture = try decoder.decode(Fixture.self, from: data)
    
    #expect(fixture.stringDict == [:])
    #expect(fixture.intDict == [:])
    #expect(fixture.objectDict == [:])
    
    #if DEBUG
    // 키가 없을 때 에러 없음
    #expect(fixture.$stringDict.error == nil)
    #expect(fixture.$intDict.error == nil)
    #expect(fixture.$objectDict.error == nil)
    #endif
  }
}