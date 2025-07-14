# flutter_clean_lint

## Motivation

Writing clean, readable, and maintainable code is essential for every Flutter project.
While there are many great lint rule sets for Dart and Flutter, sometimes you need more — custom
lint rules tailored for your team or specific workflow.`flutter_clean_lint` was created to fill the
gap.

This package allows you to use custom linter rules that are missing in popular ready-made lint
packages, helping you enforce project-specific standards and practices.

## Setup

**pubspec.yaml** - add the `custom_lint` and the `flutter_clean_lint` to your `dev_dependencies`:

```yaml
dev_dependencies:
  custom_lint: ^0.7.5
flutter_clean_lint:
  git:
    url: https://github.com/valeriinov/flutter_clean_lint
    ref: main
```

**analysis_options.yaml** - enable the plugin and activate rules:

```yaml
analyzer:
  plugins:
    - custom_lint

custom_lint:
  rules:
    - avoid_commented_out_code
```

## Running

Run the linter in this directory with:

```bash
dart run custom_lint
```