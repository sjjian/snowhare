import 'package:client/models/sessions.dart';
import 'package:client/screens/sessions/session_drawer_body.dart';
import 'package:client/screens/sessions/session_operation_bar.dart';
import 'package:client/screens/sessions/session_sql_editor.dart';
import 'package:client/screens/sessions/session_sql_results.dart';
import 'package:client/services/sessions/sessions.dart';
import 'package:flutter/material.dart';
import 'package:client/widgets/split_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SessionBodyPage extends ConsumerWidget {
  const SessionBodyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SessionEditorModel sessionEditor = ref.watch(sessionEditorNotifierProvider);
    SessionSplitViewModel sessionSplitView =
        ref.watch(sessionSplitViewNotifierProvider);
    SessionDrawerModel sessionDrawer = ref.watch(sessionDrawerNotifierProvider);

    final Widget left = Column(
      children: [
        SessionOpBar(codeController: sessionEditor.code),
        Expanded(
          child: SplitView(
            controller: sessionSplitView.multiSplitViewCtrl,
            axis: Axis.vertical,
            first: SQLEditor(
                key: ValueKey(sessionEditor.code),
                codeController: sessionEditor.code),
            second: const SqlResultTables(),
          ),
        ),
      ],
    );
    return Container(
      alignment: Alignment.topLeft,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
      child: sessionDrawer.isRightPageOpen
          ? SplitView(
              axis: Axis.horizontal,
              controller: sessionSplitView.metaDataSplitViewCtrl,
              first: left,
              second: const SessionDrawerBody(),
            )
          : left,
    );
  }
}
