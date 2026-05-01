import 'package:analysis_server_plugin/plugin.dart';
import 'package:analysis_server_plugin/registry.dart';

import 'src/rules/avoid_commented_out_code.dart';
import 'src/rules/insert_line_between_sections.dart';

final plugin = FlutterCleanLintPlugin();

class FlutterCleanLintPlugin extends Plugin {
  @override
  String get name => 'flutter_clean_lint';

  @override
  void register(PluginRegistry registry) {
    registry.registerWarningRule(AvoidCommentedOutCode());
    registry.registerWarningRule(InsertLineBetweenSections());
  }
}
