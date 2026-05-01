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
  v1.1.0.
