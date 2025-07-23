//
//  LossyArrayResilientTests.swift
//  KarrotCodableKitTests
//
//  Created by Elon on 4/9/25.
//

import Testing
import Foundation
@testable import KarrotCodableKit

@Suite("LossyArray Resilient Decoding")
struct LossyArrayResilientTests {
  struct Fixture: Decodable {
    @LossyArray var integers: [Int]
    @LossyArray var strings: [String]
    
    struct NestedObject: Decodable, Equatable {
      let id: Int
      let name: String
    }
    @LossyArray var objects: [NestedObject]
  }
  
  @Test("projected value provides error information in DEBUG")
  func testProjectedValueProvidesErrorInfo() throws {
    let json = """
    {
      "integers": [1, "invalid", 3, null, 5],
      "strings": ["hello", 123, "world", null],
      "objects": [
        {"id": 1, "name": "first"},
        {"id": "invalid", "name": "second"},
        {"id": 3, "name": "third"}
      ]
    }
    """
    
    let decoder = JSONDecoder()
    let data = json.data(using: .utf8)!
    let fixture = try decoder.decode(Fixture.self, from: data)
    
    // 기본 동작 검증
    #expect(fixture.integers == [1, 3, 5])
    #expect(fixture.strings == ["hello", "world"])
    #expect(fixture.objects == [
      Fixture.NestedObject(id: 1, name: "first"),
      Fixture.NestedObject(id: 3, name: "third")
    ])
    
    #if DEBUG
    // projected value로 에러 정보 접근
    #expect(fixture.$integers.results.count == 5)
    #expect(fixture.$integers.errors.count == 2) // "invalid"와 null
    
    // 각 요소의 성공/실패 확인
    let intResults = fixture.$integers.results
    #expect(try intResults[0].get() == 1)
    #expect(intResults[1].isFailure == true)
    #expect(try intResults[2].get() == 3)
    #expect(intResults[3].isFailure == true)
    #expect(try intResults[4].get() == 5)
    
    // strings 검증
    #expect(fixture.$strings.results.count == 4)
    #expect(fixture.$strings.errors.count == 2) // 123과 null
    
    // objects 검증
    #expect(fixture.$objects.results.count == 3)
    #expect(fixture.$objects.errors.count == 1) // "invalid" id
    #endif
  }
  
  @Test("error reporting with JSONDecoder")
  func testErrorReporting() throws {
    let json = """
    {
      "integers": [1, "two", 3],
      "strings": ["a", "b", "c"],
      "objects": []
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
      #expect(digest.errors.count >= 1)
      
      // 에러 경로 확인
      print("Error digest: \(digest.debugDescription)")
    }
    #else
    // Release 빌드에서는 에러 정보 없음
    #expect(errorDigest == nil)
    #endif
  }
  
  @Test("decode with reportResilientDecodingErrors")
  func testDecodeWithReportFlag() throws {
    let json = """
    {
      "integers": [1, "invalid", 3],
      "strings": [],
      "objects": []
    }
    """
    
    let decoder = JSONDecoder()
    let data = json.data(using: .utf8)!
    
    let (fixture, errorDigest) = try decoder.decode(
      Fixture.self,
      from: data,
      reportResilientDecodingErrors: true
    )
    
    #expect(fixture.integers == [1, 3])
    
    #if DEBUG
    #expect(errorDigest != nil)
    #expect(errorDigest?.errors.count ?? 0 >= 1)
    #else
    #expect(errorDigest == nil)
    #endif
  }
  
  @Test("empty array on complete failure")
  func testEmptyArrayOnCompleteFailure() throws {
    let json = """
    {
      "integers": "not an array",
      "strings": 123,
      "objects": null
    }
    """
    
    let decoder = JSONDecoder()
    let data = json.data(using: .utf8)!
    
    let fixture = try decoder.decode(Fixture.self, from: data)
    
    #expect(fixture.integers == [])
    #expect(fixture.strings == [])
    #expect(fixture.objects == [])
    
    #if DEBUG
    // 전체 배열 디코딩 실패 시 에러 정보
    #expect(fixture.$integers.error != nil)
    #expect(fixture.$strings.error != nil)
    #expect(fixture.$objects.error == nil) // null은 에러가 아님
    #endif
  }
}

// Result extension for testing
extension Result {
  var isFailure: Bool {
    switch self {
    case .success: return false
    case .failure: return true
    }
  }
}