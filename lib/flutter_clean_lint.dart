import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:flutter_clean_lint/src/rules/avoid_commented_out_code.dart';

/// Plugin entry‑point. custom_lint discovers this automatically.
PluginBase createPlugin() => _GgbCustomLints();

/// Registers all lints contained in this plugin.
class _GgbCustomLints extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs _) => [
        const AvoidCommentedOutCode(),
      ];
}
