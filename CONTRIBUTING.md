# Contributing to KarrotCodableKit

Thanks for your interest in contributing! Issues and pull requests are welcome.

This guide covers the human workflow. The operational facts (commands,
architecture, conventions) that both humans and AI coding agents rely on live
in [AGENTS.md](AGENTS.md) — please skim it before your first change.

English is the default language for code, comments, commits, and docs.
Issues and PR descriptions in Korean are also welcome.

## Prerequisites

- A Swift 6.2+ toolchain is required to build the test suite (the tests use
  raw-identifier test names). CI runs macOS 15 with Xcode 26.3.
- No additional tooling is required; [SwiftFormat](https://github.com/nicklockwood/SwiftFormat)
  (0.62+) is recommended for formatting.

Getting started:

```bash
git clone https://github.com/daangn/KarrotCodableKit.git
cd KarrotCodableKit
swift build
open Package.swift   # or open the folder in Xcode
```

## Building and Testing

```bash
swift test               # debug configuration
swift test -c release    # release configuration
swift test --filter SomeTestClass
```

A change is done when **both** debug and release test runs pass with zero
failures. The debug run has more tests than release because DEBUG-only APIs
(the Resilient `outcome` reporting) have DEBUG-gated tests — that difference
is expected.

CI runs on pull requests that touch `Package.swift`, `Package.resolved`,
`Sources/**`, or `Tests/**`: the test matrix (debug/release) plus a macro
compatibility check across swift-syntax versions.

## Development Workflow

This project follows TDD:

1. Write a failing test that captures the bug or the new behavior.
2. Make it pass.
3. Refactor while keeping tests green.

Bug fixes should start with a regression test written against the old
behavior. Test conventions (Swift Testing vs XCTest, naming, fixtures) are
described in [AGENTS.md](AGENTS.md#testing).

## Code Style

Formatting is defined by `.swiftformat` in the repo root — run `swiftformat .`
before committing; it must produce no diff on a clean tree. The basics:
2-space indent, 120-column limit. There is no lint step in CI; style is
checked in review.

## Branches, Commits, and Pull Requests

- Branch names: `<type>/<short-slug>`, e.g. `fix/lossy-array-null-outcome`,
  `feature/optional-polymorphic-value`, `docs/update-readme`.
- Commit subjects: lowercase [Conventional Commits](https://www.conventionalcommits.org/):

  | Type | Use for | Example |
  |---|---|---|
  | `feat` | New functionality | `feat: omit nil optional fields on encode` |
  | `fix` | Bug fixes | `fix(polymorphic): align lossy array recovery with BetterCodable policy` |
  | `perf` | Performance | `perf(polymorphic): drop the intermediate Result array` |
  | `refactor` | No behavior change | `refactor: extract KeyedDecodingContainer extension` |
  | `test` | Tests only | `test: cover RFC 3339 legacy offset decoding` |
  | `docs` | Documentation | `docs: correct DefaultEmptyPolymorphicArrayValue docs` |
  | `style` | Formatting only | `style: apply swiftformat across the codebase` |
  | `chore` | Tooling, CI, meta | `chore: add issue templates` |

- PRs are merged with a merge commit (not squashed), so structure your branch
  as one logical commit per unit of change — each commit should build and pass
  tests on its own.
- Fill in the PR template, and report exact test counts for both
  configurations, e.g. "`swift test` passes in debug (303) and release (295),
  0 failures".
- Keep PRs focused; put unrelated improvements in a follow-up PR.

## Review Process

- [CodeRabbit](https://coderabbit.ai) reviews every PR automatically and
  applies a category label (Bug / Feature / Improvement / Update / Docs /
  Breaking Changes / CI). A maintainer then reviews and merges.
- Please reply to review comments in their thread (not as top-level PR
  comments), and feel free to push back with reasoning — review is a
  conversation.

## Releases

Releases are SemVer git tags without a `v` prefix (e.g. `2.1.0`), created by
the maintainers. Pushing a tag drafts GitHub release notes grouped by PR
label, so the label on your PR determines where it appears in the notes.

## Reporting Issues

Please use the issue templates. For bugs, a minimal reproducible code sample
plus the JSON payload involved makes fixes dramatically faster.
