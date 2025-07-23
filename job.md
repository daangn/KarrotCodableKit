# KarrotCodableKit Resilient Decoding 기능 추가 작업

## 사용자 요청사항 (Initial Prompt)

```
현재 swift package에 존재하는 프로퍼티래퍼들에 Resilient Decoding 기능을 추가하고 싶어 Resilient Decoding 설명은 아래와 같아

---
This package defines mechanisms to partially recover from errors when decoding Decodable types. It also aims to provide an ergonomic API for inspecting decoding errors during development and reporting them in production.

More details follow, but here is a glimpse of what this package enables:

struct Foo: Decodable {
  @Resilient var array: [Int]
  @Resilient var value: Int?
}
let foo = try JSONDecoder().decode(Foo.self, from: """
  {
    "array": [1, "2", 3],
    "value": "invalid",
  }
  """.data(using: .utf8)!)
After running this code, foo will be a Foo where foo.array == [1, 3] and foo.value == nil. In DEBUG, foo.$array.results will be [.success(1), .failure(DecodingError.dataCorrupted(…), .success(3)] and foo.$value.error will be DecodingError.dataCorrupted(…). This functionality is DEBUG-only so that we can maintain no overhead in release builds.
---

Resilient Decoding 설명에 있는 decodingFallback은 이미 DefaultCodableStrategy 을 통해 구현하고 있어
그러므로 현재 패키지에 사용하는 프로퍼티래퍼들에 맞게 적용이 필요한 상황이야
기존 프로퍼티래퍼들에 추가하는게 이 작업의 근본적인 목적이야
DEBUG 빌드에서만 제공하면 돼. 매크로는 지원안해 프로퍼티래퍼에만 해줘

일단 아래 링크를 gh 명령어를 사용해서 탐색해줘
https://github.com/airbnb/ResilientDecoding

그리고 나서 현재 패키지에 있는 코드들을 탐색해서 어떤 프로퍼티래퍼들이 존재하고 Resilient에 있는 ResilientDecodingErrorReporter와 foo.$array.results, foo.$value.error 같은 기능들을 기존 프로퍼티래퍼들에 적용하려면 어떻게 해야할지 단계별로 계획을 작성해야해

계획을 작성하기 전에 추가적인 정보나 방향성등에 대한 내용이 필요하면 먼저 질문을하고 답변을 기반으로 계획을 작성해줘
계획은 단계별로 한글로 작성되어야 해

그리고 계획을 수행할때는 구현하려는 기능에 대한 테스트를 먼저 작성하고 난 뒤에 기능을 구현하고 테스트를 실행시켜서 테스트가 통과할때까지 반복해서 수정하는 방식을 사용해야해.
테스트는 swift-testing을 기반으로 작성해야해, 기존 XCTest 기반 테스트들에는 XCTest를 사용해야해
구현에 필요한 테스트와 구현 코드들은 위에서 전달한 깃허브 링크에 있기 때문에 그걸 활용해서 현재 패키지에 맞게 적용하는게 중요해
같은 역할을 하는 객체나 프로토콜이 있을 수 있는데 그건 현재 패키지에 구현을 더 우선으로해
계획은 한글로 작성해야 하며 질문을 할 때도 한글로 질문해야 해
작업 진행 단계별로 git commit을 하고 커밋 메시지는 작업 내용을 요약하여 작성해야해
```

추가 요청사항:
- "@DefaultCodable<DefaultZeroInt> var value: Int 는 잘못된 구현이야 @DefaultZeroInt var value: Int로 선언되어야지"
- "프로퍼티 래퍼들에도 이어서 같은 방식을 계속 작업 진행해줘 @Sources/KarrotCodableKit/PolymorphicCodable 에 있는 프로퍼티래퍼들에도 작업이 되어야 해"

## 작업 목표

1. KarrotCodableKit 패키지의 모든 property wrapper에 Resilient Decoding 기능 추가
2. DEBUG 빌드에서만 에러 정보 접근 가능 (릴리즈 빌드에서는 오버헤드 없음)
3. Projected value (`$property`)를 통한 에러 정보 접근
4. TDD 방식으로 진행 (swift-testing 사용)
5. 기존 DefaultCodableStrategy와 통합

## 구현 패턴

각 property wrapper에 다음 요소들을 추가:

1. **outcome 속성 추가**
   ```swift
   let outcome: ResilientDecodingOutcome
   ```

2. **DEBUG 모드에서 ProjectedValue 구현**
   ```swift
   #if DEBUG
   public struct ProjectedValue {
     public let outcome: ResilientDecodingOutcome
     
     public var error: Error? {
       // outcome에서 에러 추출
     }
   }
   
   public var projectedValue: ProjectedValue {
     return ProjectedValue(outcome: outcome)
   }
   #else
   public var projectedValue: Never {
     fatalError("@\(Self.self) projectedValue should not be used in non-DEBUG builds")
   }
   #endif
   ```

3. **Decodable init에서 에러 추적 및 보고**
   ```swift
   do {
     // 디코딩 시도
     self.outcome = .decodedSuccessfully
   } catch {
     // 에러 보고
     ResilientDecodingErrorReporter.errorDigest(error: error, at: decoder.codingPath)
     self.outcome = .recoveredFrom(error, wasReported: true)
   }
   ```

4. **Equatable/Hashable 명시적 구현** (필요시)

## 진행 상황

### 완료된 작업

1. **에러 리포팅 인프라 구축**
   - ResilientDecodingErrorReporter.swift
   - ResilientDecodingOutcome.swift
   - DictionaryDecodingError.swift
   - 커밋: `feat: Resilient Decoding 에러 리포팅 인프라 구축`

2. **BetterCodable property wrapper들**
   - LossyArray (+ ArrayDecodingError)
   - DefaultCodable 관련 wrapper들 (DefaultZeroInt, DefaultTrue 등)
   - LossyOptional
   - LossyDictionary
   - LosslessArray
   - LosslessValue
   - DateValue
   - DataValue
   - 커밋: `feat: LossyArray에 Resilient Decoding 기능 추가`, `feat: DefaultCodable에 Resilient Decoding 기능 추가` 등

3. **PolymorphicCodable property wrapper들**
   - PolymorphicValue
   - OptionalPolymorphicValue
   - LossyOptionalPolymorphicValue
   - PolymorphicArrayValue
   - PolymorphicLossyArrayValue
   - DefaultEmptyPolymorphicArrayValue
   - 커밋: `feat: PolymorphicValue에 Resilient Decoding 기능 추가`, `feat: OptionalPolymorphicValue에 Resilient Decoding 기능 추가`, `feat: PolymorphicLossyArrayValue에 Resilient Decoding 기능 추가`, `feat: DefaultEmptyPolymorphicArrayValue에 Resilient Decoding 기능 추가` 등

### 작업 완료 ✅

모든 property wrapper에 Resilient Decoding 기능 추가 완료!

## 테스트 구조

각 property wrapper마다 Resilient 테스트 파일 생성:
- `Tests/KarrotCodableKitTests/BetterCodable/[Wrapper]/[Wrapper]ResilientTests.swift`
- `Tests/KarrotCodableKitTests/PolymorphicCodable/[Wrapper]ResilientTests.swift`

테스트 항목:
1. 정상 디코딩 시 outcome 확인
2. 에러 발생 시 projected value로 에러 접근
3. ResilientDecodingErrorReporter에 에러 보고 확인
4. 배열/딕셔너리의 경우 부분 실패 처리

## 기술적 고려사항

1. **Generic parameter 충돌**: 내부 스코프에서 다른 이름 사용
2. **Decodable 제약 조건**: 필요한 곳에 명시적 추가
3. **Equatable/Hashable**: ResilientDecodingOutcome 때문에 명시적 구현 필요
4. **조건부 컴파일**: #if DEBUG로 릴리즈 빌드 오버헤드 제거
5. **nil vs keyNotFound**: Optional 타입에서 구분 처리