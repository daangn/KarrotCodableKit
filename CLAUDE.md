# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

KarrotCodableKit is a Swift package that extends Swift's Codable protocol with enhanced functionality:

- **CustomCodable**: Macro-based custom encoding/decoding with configurable coding key styles
- **PolymorphicCodable**: Support for polymorphic types with automatic type resolution based on identifiers
- **AnyCodable**: Type-erased Codable values for handling various types
- **BetterCodable**: Property wrappers for dates, data values, defaults, and lossy conversions

## Architecture

### Core Modules
- **KarrotCodableKit**: Main library target containing runtime functionality
- **KarrotCodableKitMacros**: Swift macro implementations using SwiftSyntax

### Key Components
- **CustomCodable/**: Macro system for automated Codable implementations with CodingKey generation
- **PolymorphicCodable/**: Runtime polymorphic type resolution system with strategy-based decoding
- **AnyCodable/**: Type erasure wrappers (AnyCodable, AnyEncodable, AnyDecodable)
- **BetterCodable/**: Property wrappers for common Codable patterns (dates, defaults, lossy values)

### Macro System
The project heavily uses Swift macros for code generation:
- Macros are implemented in `KarrotCodableKitMacros` target
- Factory classes in `Supports/Factory/` generate syntax nodes
- `PropertyAnalyzer` and `SyntaxHelper` provide macro development utilities

### UnnestedPolymorphic Macro Architecture
The UnnestedPolymorphic macros use a Template Method pattern with shared components:
- **BaseUnnestedPolymorphicMacro**: Protocol extension providing common functionality
- **UnnestedPolymorphicValidation**: Centralized validation logic with dynamic error messages
- **PolymorphicMacroArgumentValidator**: Argument extraction and validation
- **UnnestedPolymorphicCodeGenerator**: Top-level code generation
- **UnnestedPolymorphicStructGenerator**: Nested struct generation
- **UnnestedPolymorphicMethodGenerator**: Init/encode method generation

Each macro type (`UnnestedPolymorphicCodableMacro`, `UnnestedPolymorphicDecodableMacro`) implements `UnnestedPolymorphicMacroType` with specific protocol and macro type configurations.

## Common Development Commands

### Building
```bash
swift build                   # Build all targets
swift build -c release        # Release build
```

### Testing
```bash
swift test                    # Run all tests
swift test -c debug           # Debug configuration tests
swift test -c release         # Release configuration tests
```

### Running Specific Tests
```bash
swift test --filter TestClassName                          # Run specific test class
swift test --filter TestClassName.testMethodName           # Run specific test method
swift test --filter UnnestedPolymorphic                    # Run tests matching pattern
swift test --filter "UnnestedPolymorphicCodableTests"      # Run macro expansion tests
```

### Package Management
```bash
swift package resolve         # Resolve dependencies
swift package update          # Update dependencies
swift package clean           # Clean build artifacts
swift package reset           # Reset cache and build directory
```

## Testing Structure

- **KarrotCodableKitTests/**: Runtime functionality tests organized by feature
- **KarrotCodableMacrosTests/**: Macro expansion and generation tests
- Uses SwiftSyntaxMacrosTestSupport for macro testing

## Development Notes

### Macro Development
- Macros use SwiftSyntax for AST manipulation
- Test macro expansions using `SwiftSyntaxMacrosTestSupport`
- Factory pattern used for generating complex syntax structures

### Adding New UnnestedPolymorphic Macro Types
When adding new UnnestedPolymorphic macro variants:
1. Implement `UnnestedPolymorphicMacroType` protocol
2. Define `protocolType`, `macroType`, and `macroName` properties
3. Use template methods from protocol extension for common functionality
4. Register macro in `KarrotCodableKitPlugin.swift`

### Polymorphic System
- Uses identifier-based type resolution during decoding
- Strategy pattern for different polymorphic decoding approaches
- Supports both protocol-based and enum-based polymorphic types

### Property Wrappers
- BetterCodable provides specialized property wrappers for common Codable scenarios
- Includes date formatting strategies, default value handling, and lossy conversions