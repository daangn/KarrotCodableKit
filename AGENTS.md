# AGENTS.md

Canonical instructions for AI coding agents working in this repository.
`CLAUDE.md` and `GEMINI.md` import this file — edit this file, not those.
Human-facing contribution docs live in [CONTRIBUTING.md](CONTRIBUTING.md).

## Project Overview

KarrotCodableKit is a public Swift package that extends Swift's `Codable` protocol:

- **CustomCodable**: Macro-based custom encoding/decoding with configurable coding key styles
- **PolymorphicCodable**: Polymorphic types with automatic type resolution based on identifiers
- **AnyCodable**: Type-erased Codable values for handling various types
- **BetterCodable**: Property wrappers for dates, data values, defaults, and lossy conversions

Package facts:

- Library product `KarrotCodableKit`; targets `KarrotCodableKit` (runtime) and `KarrotCodableKitMacros` (SwiftSyntax macro plugin)
- `swift-tools-version: 5.9`, dependency `swift-syntax` `509.0.0..<604.0.0`
- Platforms: macOS 11, iOS 13, tvOS 13, watchOS 6, macCatalyst 13
- Building the test suite requires a **Swift 6.2+ toolchain** (raw-identifier test names, SE-0451); CI uses macOS 15 + Xcode 26.3

## Commands

```bash
swift build                   # Build all targets
swift test                    # Run all tests (debug)
swift test -c release         # Release configuration tests
swift test --filter TestClassName                 # Specific test class
swift test --filter TestClassName.testMethodName  # Specific test method
swift test --filter UnnestedPolymorphic           # Tests matching pattern
swiftformat .                 # Format (config: .swiftformat in repo root)
swiftformat --lint .          # Verify formatting (must report 0 files requiring formatting)
swift package resolve|update|clean|reset          # Package management
```

Done criteria for any code change: `swift test` passes in **both `-c debug` and `-c release`** with zero failures. The debug count is higher than release (DEBUG-only APIs such as `outcome`/projected values have DEBUG-only tests) — that difference is expected. `swiftformat .` must produce no diff before committing.

## Architecture

### Core Modules
- **KarrotCodableKit**: Main library target containing runtime functionality
- **KarrotCodableKitMacros**: Swift macro implementations using SwiftSyntax

### Key Components
- **CustomCodable/**: Macro system for automated Codable implementations with CodingKey generation
- **PolymorphicCodable/**: Runtime polymorphic type resolution system with strategy-based decoding
  - **Value Wrappers**: `PolymorphicValue`, `OptionalPolymorphicValue`, `LossyOptionalPolymorphicValue`
  - **Array Wrappers**: `PolymorphicArrayValue`, `OptionalPolymorphicArrayValue`, `DefaultEmptyPolymorphicArrayValue`, `PolymorphicLossyArrayValue`, `OptionalPolymorphicLossyArrayValue`
- **AnyCodable/**: Type erasure wrappers (AnyCodable, AnyEncodable, AnyDecodable)
- **BetterCodable/**: Property wrappers for common Codable patterns
  - **DateValue/OptionalDateValue**: Date formatting strategies (ISO8601, RFC3339, Timestamp, etc.)
  - **LosslessValue**: Lossless type conversion (preserves original type, restores on encoding)
  - **LossyArray/LossyDictionary/LossyOptional**: Lossy decoding (filters out failed elements)
  - **Defaults**: Default value handling (DefaultCodable, DefaultEmptyArray, etc.)
- **Resilient/**: DEBUG mode decoding error tracking and reporting system
  - `ResilientDecodingOutcome`: Decoding result states (decodedSuccessfully, keyNotFound, valueWasNil, recoveredFrom)
  - `ResilientDecodingErrorReporter`: Error collection and hierarchical storage by coding path
  - Accessible via `outcome` property on all BetterCodable and PolymorphicCodable property wrappers

Wrapper policy: Polymorphic wrappers follow the same recovery policy as their BetterCodable counterparts. `Optional*` variants treat only `keyNotFound`/`valueWasNil` as nil; `Lossy*` variants recover from all decoding errors. `Optional*` variants differ from their base wrapper only in optionality.

### Macro System
- Macros are implemented in the `KarrotCodableKitMacros` target
- Factory classes in `Supports/Factory/` generate syntax nodes
- `PropertyAnalyzer` and `SyntaxHelper` provide macro development utilities

### PolymorphicEnumCodable Macro
- **PolymorphicEnumCodableMacro/Decodable/Encodable**: Auto-generates Codable conformance for enums
- **PolymorphicEnumCodableFactory**: Generates CodingKey and init/encode methods
- Each case must have exactly one associated value (conforming to `PolymorphicIdentifiable`)

### UnnestedPolymorphic Macros
Template Method pattern with shared components:
- **BaseUnnestedPolymorphicMacro**: Protocol extension providing common functionality
- **UnnestedPolymorphicValidation**: Centralized validation logic with dynamic error messages
- **PolymorphicMacroArgumentValidator**: Argument extraction and validation
- **UnnestedPolymorphicCodeGenerator / StructGenerator / MethodGenerator**: Code generation layers

Each macro type (`UnnestedPolymorphicCodableMacro`, `UnnestedPolymorphicDecodableMacro`) implements `UnnestedPolymorphicMacroType` with specific protocol and macro type configurations.

Adding a new UnnestedPolymorphic macro variant:
1. Implement the `UnnestedPolymorphicMacroType` protocol
2. Define `protocolType`, `macroType`, and `macroName` properties
3. Use template methods from the protocol extension for common functionality
4. Register the macro in `KarrotCodableKitPlugin.swift`

### Documentation & Provenance
- Feature docs: `Docs/AnyCodable/README.md`, `Docs/BetterCodable/README.md`; the README "Key Features" section holds macro-expansion examples. Update these when the public API changes.
- API reference (DocC) is built and hosted by Swift Package Index via `.spi.yml` — there is no local DocC catalog.
- AnyCodable, BetterCodable, and Resilient are ports of Flight-School/AnyCodable, marksands/BetterCodable, and airbnb/ResilientDecoding. Keep behavior parity with BetterCodable when touching wrapper policies, and add attribution under `ThirdPartyLicenses/` when vendoring upstream code.

## Code Style

- `.swiftformat` (repo root) is the source of truth: rule whitelist, 2-space indent, 120-column limit. Run `swiftformat .` before committing — it must produce no diff.
- Claude Code auto-formats edited Swift files via the PostToolUse hook in `.claude/settings.json` — an unexpected post-edit diff is usually just the formatter.
- Multiline string literals (JSON fixtures, expected macro expansions) indent their content and closing `"""` two spaces past the opening line; `--indent-strings true` preserves this — do not "fix" it.
- `#if DEBUG` blocks add no extra indentation (`--ifdef no-indent`).
- propertyTypes rule gotchas:
  - Write `CodingUserInfoKey.resilientDecodingErrorReporter` as `: CodingUserInfoKey = .init(...)!` — the rule miscompiles the multiline `= CodingUserInfoKey(...)!` form into a tuple.
  - Keep the `// swiftformat:disable propertyTypes` regions around `@DefaultCodable` test doubles — explicit type annotations break the wrapper's generic parameter inference.
- Code, comments, and documentation are written in English.
- Follow the Swift API Design Guidelines; prefer dedicated structs/enums over tuples in public API.

## Testing

Test targets:
- **Tests/KarrotCodableKitTests/**: Runtime functionality tests, organized by feature. Uses **Swift Testing** (`import Testing`, `struct` suites, `@Test`, `#expect`/`#require`).
- **Tests/KarrotCodableMacrosTests/**: Macro expansion tests. Uses **XCTest** with `assertMacroExpansion` (`SwiftSyntaxMacrosTestSupport` is XCTest-based — do not migrate these to Swift Testing).

Conventions (see existing tests for reference):
- TDD: write a failing test first (red), then make it pass. Bug fixes start with a regression test reproducing the bug against the old behavior.
- Test method names are backtick raw identifiers in natural language: ``func `decodes valid JSON`()``.
- Structure test bodies with `// given` / `// when` / `// then` comments.
- Use realistic, real-world JSON payloads as fixtures; name test doubles `*Dummy` / `TestDouble*`.
- Cover edge cases: missing key, null value, type mismatch, empty collections, and encode→decode round-trips.
- Assert concrete error cases (e.g. specific `DecodingError`), not just "throws".
- DEBUG-only features (Resilient `outcome`, projected values) get `#if DEBUG`-gated test files (`*ResilientTests.swift`).

## Git & PR Conventions

- Commit subjects: lowercase Conventional Commits — `feat:`, `fix:`, `docs:`, `test:`, `style:`, `refactor:`, `perf:`, `chore:`; optional scope, e.g. `fix(polymorphic):`. Imperative mood.
- Branch names: `<type>/<slug>`, e.g. `fix/polymorphic-lossy-array-null-outcome`, `docs/update-readme`.
- PRs are landed with **merge commits** (not squash). Structure work as one logical commit per unit of change — each commit should build and pass tests.
- Fill in the PR template. Report exact test counts for both configurations in Testing Methods, e.g. "`swift test` passes in debug (303) and release (295), 0 failures".
- Keep PRs focused: defer unrelated changes (renames, drive-by cleanups) to follow-up PRs.
- CodeRabbit reviews every PR automatically and applies one of the labels Bug / Feature / Improvement / Update / Docs / Breaking Changes / CI. These labels determine the release-note category (release-drafter) — verify the label matches the change.
- Reply to review comments in their thread, not as top-level PR comments.
- CI runs only when `Package.swift`, `Package.resolved`, `Sources/**`, or `Tests/**` change.

## Gotchas

- A type-inference error in the macros module can cascade into unrelated `'@const' value should be initialized with a compile-time value` errors on `@Test` functions. Fix the first real error before trusting the rest of the diagnostics.
- Release builds strip DEBUG-only API (`outcome` reporting, projected values), so `swift test -c release` runs fewer tests than debug. Always run both.
- Releases are SemVer git tags without a `v` prefix (e.g. `2.1.0`); pushing a tag drafts release notes from PR labels. Do not create tags or releases unless explicitly asked.
