# flutter_clean_lint

## Motivation

Writing clean, readable, and maintainable code is essential for every Flutter project.
While there are many great lint rule sets for Dart and Flutter, sometimes you need more — custom
lint rules tailored for your team or specific workflow. `flutter_clean_lint` was created to fill the
gap.

This package allows you to use custom linter rules that are missing in popular ready-made lint
packages, helping you enforce project-specific standards and practices.

## Requirements

- Dart 3.11+
- Flutter 3.41+

## Setup

**pubspec.yaml** - add `flutter_clean_lint` to your `dev_dependencies`:

```yaml
dev_dependencies:
  flutter_clean_lint:
    git:
      url: https://github.com/valeriinov/flutter_clean_lint
      ref: 1.1.0
```

**analysis_options.yaml** - enable the plugin:

```yaml
plugins:
  flutter_clean_lint: ^1.1.0
```

The rules work through `dart analyze`, `flutter analyze`, and IDE analysis without
`custom_lint`. `avoid_commented_out_code` and `insert_line_between_sections` are warnings and are
enabled by default. `order_private_methods_by_usage` and `avoid_doc_comments_on_private_members`
are lints reported as info and are disabled by default; enable them under `diagnostics`:

```yaml
plugins:
  flutter_clean_lint:
    version: ^1.1.0
    diagnostics:
      order_private_methods_by_usage: true
      avoid_doc_comments_on_private_members: true
```

## Rules

- `avoid_commented_out_code`
- `insert_line_between_sections`
- `order_private_methods_by_usage` (opt-in)
- `avoid_doc_comments_on_private_members` (opt-in)

## Commands

`insert_line_between_sections` violations are fixed by a command, since `dart fix` does not apply
analyzer plugin fixes:

```bash
dart run flutter_clean_lint:fix_blank_lines lib test
```

It resolves the Dart files that `analysis_options.yaml` includes under the given paths, rewrites
their blank lines and prints each file it changed. Violations suppressed with `ignore` or
`ignore_for_file` stay as they are. A path that does not exist stops the command with exit code 64.

ARB localization checks were removed from the analyzer plugin migration and are
planned to return as a standalone CLI command in a later version.

## Suppression

Suppress a rule with the plugin-qualified rule name:

```dart
// ignore: flutter_clean_lint/avoid_commented_out_code
// oldCall();
```
