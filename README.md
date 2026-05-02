# flutter_clean_lint

## Motivation

Writing clean, readable, and maintainable code is essential for every Flutter project.
While there are many great lint rule sets for Dart and Flutter, sometimes you need more — custom
lint rules tailored for your team or specific workflow. `flutter_clean_lint` was created to fill the
gap.

This package allows you to use custom linter rules that are missing in popular ready-made lint
packages, helping you enforce project-specific standards and practices.

## Requirements

- Dart 3.9+
- Flutter 3.38+

## Setup

**pubspec.yaml** - add `flutter_clean_lint` to your `dev_dependencies`:

```yaml
dev_dependencies:
  flutter_clean_lint:
    git:
      url: https://github.com/valeriinov/flutter_clean_lint
      ref: 1.0.2
```

**analysis_options.yaml** - enable the plugin:

```yaml
plugins:
  flutter_clean_lint: ^1.0.2
```

The Dart rules are registered as warnings and work through `dart analyze`,
`flutter analyze`, and IDE analysis without `custom_lint`.

## Rules

- `avoid_commented_out_code`
- `insert_line_between_sections`

ARB localization checks were removed from the analyzer plugin migration and are
planned to return as a standalone CLI command in v1.1.0.

## Suppression

Suppress a rule with the plugin-qualified rule name:

```dart
// ignore: flutter_clean_lint/avoid_commented_out_code
// oldCall();
```
