import 'package:analysis_server_plugin/plugin.dart';
import 'package:analysis_server_plugin/registry.dart';

import 'src/plugin_name.dart';
import 'src/rules/avoid_commented_out_code.dart';
import 'src/rules/avoid_doc_comments_on_private_members.dart';
import 'src/rules/insert_line_between_sections.dart';
import 'src/rules/order_private_methods_by_usage.dart';

final plugin = FlutterCleanLintPlugin();

class FlutterCleanLintPlugin extends Plugin {
  @override
  String get name => pluginName;

  @override
  void register(PluginRegistry registry) {
    registry.registerWarningRule(AvoidCommentedOutCode());
    registry.registerWarningRule(InsertLineBetweenSections());
    registry.registerLintRule(OrderPrivateMethodsByUsage());
    registry.registerLintRule(AvoidDocCommentsOnPrivateMembers());
  }
}
