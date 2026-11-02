## 1.3.1

- Fixed `fix_blank_lines`: it no longer removes a correct blank line after a statement with a
  trailing comment (`a(); // note`). It leaves that case to be fixed by hand, as RULES.md states.

## 1.3.0

- Added the opt-in `avoid_hardcoded_style_values` lint: flags hard-coded colours and style
  numbers in widget code. It checks `Widget` and `State` class bodies and top-level variables in
  files outside `test/`, and depends on no theme library.
- The lint is registered at info level and stays off until enabled under
  `plugins: flutter_clean_lint: diagnostics:`.
- No changes to existing rules.

## 1.2.0

- Added the opt-in `order_private_methods_by_usage` lint: private methods follow the order of
  their latest usage in the file, call sites above implementations.
- Added the opt-in `avoid_doc_comments_on_private_members` lint: flags `///` and `/** */`
  comments on library-private declarations.
- Both are registered as lints reported at info level and stay off until enabled under
  `plugins: flutter_clean_lint: diagnostics:`.
- No changes to existing rules.

## 1.1.0

- Added the `fix_blank_lines` command:
  `dart run flutter_clean_lint:fix_blank_lines <path>...` fixes
  `insert_line_between_sections` violations in place. It keeps suppressed violations and the
  comment cases that need manual fixes unchanged.
- The `insert_line_between_sections` message now names the statement kinds it compares.
- The `pubspec.yaml` SDK constraint is now `>=3.11.0`, matching what `analyzer` 13.3.0
  already required (Dart 3.11 / Flutter 3.41).
- No rule behavior changes.

## 1.0.3

- Updated the analyzer toolchain: `analyzer` 13.3.0, `analysis_server_plugin` 0.3.18,
  and `analyzer_testing` 0.3.2 (`analyzer_plugin` 0.14.12 resolved transitively).
- No rule behavior changes.

## 1.0.2

- Updated `insert_line_between_sections` to enforce blank-line rules before comments
  while keeping comments attached to the statement they describe.
- Comments now require exactly one blank line before them when the statement kind changes,
  and zero blank lines when the statement is the same kind as the previous one.
- Updated tests and documentation to reflect the new comment attachment behavior.

## 1.0.1

- Improved `insert_line_between_sections` handling for statements with leading comments.
- Updated marker-based rule tests so expectation comments are not analyzed as source code.
- Clarified rule documentation for commented-out code detection and section spacing behavior.

## 1.0.0 - BREAKING

- Migrated from `custom_lint` to `analysis_server_plugin`.
- Rules now integrate directly into `dart analyze`, `flutter analyze`, and IDE
  analysis.
- Minimum SDK: Dart 3.9 / Flutter 3.38.
- New configuration format: top-level `plugins:` in `analysis_options.yaml`.
- Suppression format: `// ignore: flutter_clean_lint/<rule_name>`.
- Removed ARB rules (`localization_keys_consistency`,
  `duplicate_localization_keys`). They are planned to return as a CLI tool in
  a later version.
