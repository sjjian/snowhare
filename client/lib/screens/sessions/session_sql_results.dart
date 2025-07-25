import 'package:client/models/sessions.dart';
import 'package:client/repositories/sessions/session_conn.dart';
import 'package:client/screens/sessions/session_drawer_body.dart';
import 'package:client/services/sessions/session_sql_result.dart';
import 'package:client/services/sessions/sessions.dart';
import 'package:db_driver/db_driver.dart';
import 'package:client/widgets/data_type_icon.dart';
import 'package:flutter/material.dart';
import 'package:client/widgets/tab_widget.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:sql_editor/re_editor.dart';
import 'package:client/utils/sql_highlight.dart';
import 'package:sql_parser/parser.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

part 'session_sql_results.g.dart';

@Riverpod(keepAlive: true)
SessionEditorModel sessionEditor(Ref ref, SessionId sessionId) {
  return SessionEditorModel(code: CodeLineEditingController(
      spanBuilder: ({required codeLines, required context, required style}) {
    return TextSpan(
        children: Lexer(codeLines.asString(TextLineBreak.lf))
            .tokens()
            .map<TextSpan>((tok) => TextSpan(
                text: tok.content,
                style: style.merge(getStyle(tok.id) ?? style)))
            .toList());
  }));
}

@Riverpod(keepAlive: true)
class SessionEditorNotifier extends _$SessionEditorNotifier {
  @override
  SessionEditorModel build() {
    SessionModel? sessionIdModel = ref.watch(selectedSessionServicesProvider);
    if (sessionIdModel == null) {
      return ref.watch(sessionEditorProvider(const SessionId(value: 0)));
    }
    return ref.watch(sessionEditorProvider(sessionIdModel.sessionId));
  }
}

@Riverpod(keepAlive: true)
class SelectedSQLResultTabNotifier extends _$SelectedSQLResultTabNotifier {
  @override
  SQLResultListModel? build() {
    SessionModel? sessionIdModel = ref.watch(selectedSessionServicesProvider);
    if (sessionIdModel == null) {
      return null;
    }
    return ref.watch(sQLResultsServicesProvider(sessionIdModel.sessionId));
  }
}

@Riverpod(keepAlive: true)
class SelectedSQLResultNotifier extends _$SelectedSQLResultNotifier {
  @override
  SQLResultModel? build() {
    SessionModel? sessionIdModel = ref.watch(selectedSessionServicesProvider);
    if (sessionIdModel == null) {
      return null;
    }
    ResultId? resultId = ref
        .watch(sQLResultsServicesProvider(sessionIdModel.sessionId).select((m) {
      return m.selected?.resultId;
    }));
    if (resultId == null) {
      return null;
    }
    return ref.watch(sQLResultServicesProvider(resultId));
  }
}

class SqlResultTables extends ConsumerWidget {
  const SqlResultTables({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SQLResultListModel? model = ref.watch(selectedSQLResultTabNotifierProvider);
    CommonTabStyle style = CommonTabStyle(
      maxWidth: 100,
      labelAlign: TextAlign.center,
      selectedColor: Theme.of(context)
          .colorScheme
          .surfaceContainerLow, // sql result tab 的选中颜色
      color:
          Theme.of(context).colorScheme.surfaceContainer, // sql result tab 的背景色
      hoverColor: Theme.of(context)
          .colorScheme
          .surfaceContainer, // sql result tab 的鼠标移入色
    );

    Widget tab;
    if (model == null) {
      tab = const Spacer();
    } else {
      tab = Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        // CommonTab(
        //   label: "执行记录",
        //   selected: false, // todo
        //   width: 100,
        //   style: style,
        //   onTap: () {
        //     // session.selectToRecord();
        //   },
        // ),
        Expanded(
            child: CommonTabBar(
                height: 35,
                color: Theme.of(context).colorScheme.surfaceContainer,
                tabStyle: style,
                onReorder: (oldIndex, newIndex) {
                  ref
                      .read(
                          sQLResultsServicesProvider(model.sessionId).notifier)
                      .reorderSQLResult(oldIndex, newIndex);
                },
                tabs: [
              for (var i = 0; i < model.results.length; i++)
                CommonTabWrap(
                  label: "${model.results[i].resultId.value}",
                  selected: model.results[i] == model.selected,
                  onTap: () {
                    ref
                        .read(sQLResultsServicesProvider(model.sessionId)
                            .notifier)
                        .selectSQLResult(model.results[i].resultId);
                  },
                  onDeleted: () {
                    ref
                        .read(sQLResultsServicesProvider(model.sessionId)
                            .notifier)
                        .deleteSQLResult(model.results[i].resultId);
                  },
                  avatar: const Icon(
                    Icons.grid_on,
                  ),
                )
            ]))
      ]);
    }

    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              Container(
                alignment: Alignment.centerLeft,
                constraints: const BoxConstraints(maxHeight: 35),
                child: tab,
              ),
              const Expanded(child: SqlResultTable())
            ],
          ),
        ),
      ],
    );
  }
}

class SqlResultTable extends ConsumerWidget {
  const SqlResultTable({super.key});

  List<PlutoColumn> buildColumns(List<BaseQueryColumn> columns) {
    return columns
        .map<PlutoColumn>((e) => PlutoColumn(
            title: e.name,
            field: e.name,
            type: switch (e.dataType()) {
              DataType.number => PlutoColumnType.number(),
              _ => PlutoColumnType.text(),
            },
            titleSpan: WidgetSpan(
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 2),
                    child: DataTypeIcon(type: e.dataType(), size: 20),
                  ),
                  Expanded(
                      child: Text(e.name, overflow: TextOverflow.ellipsis)),
                ],
              ),
            )))
        .toList();
  }

  List<PlutoRow> buildRows(List<QueryResultRow> rows) {
    return rows.map<PlutoRow>((e) {
      return PlutoRow(cells: <String, PlutoCell>{
        for (int i = 0; i < e.columns.length; i++)
          e.columns[i].name: PlutoCell(value: e.values[i].getSummary())
      });
    }).toList();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = Theme.of(context)
        .colorScheme
        .surfaceContainerLow; // sql result body 的背景色

    final model = ref.watch(selectedSQLResultNotifierProvider);
    if (model == null) {
      return Container(
          alignment: Alignment.center,
          color: color,
          child: Text(AppLocalizations.of(context)!.display_msg_no_data));
    }
    if (model.state == SQLExecuteState.done) {
      return PlutoGrid(
        key: ObjectKey(model),
        mode: PlutoGridMode.selectWithOneTap,
        onSelected: (event) {
          ref.read(sessionDrawerNotifierProvider.notifier).showSQLResult(
                result: model.data!.rows[event.rowIdx!]
                    .getValue(event.cell!.column.title),
                column: model.data!.rows[event.rowIdx!]
                    .getColumn(event.cell!.column.title),
              );
        },
        configuration: PlutoGridConfiguration(
          localeText: const PlutoGridLocaleText.china(),
          style: PlutoGridStyleConfig(
            rowHeight: 30,
            columnHeight: 36,
            gridBorderColor: color,
            rowColor: color,
            activatedColor: Theme.of(context)
                .colorScheme
                .surfaceContainer, // sql result table 行选中的颜色
            gridBackgroundColor: color,
          ),
        ),
        columns: buildColumns(model.data!.columns),
        rows: buildRows(model.data!.rows),
      );
    } else if (model.state == SQLExecuteState.error) {
      return Container(
          alignment: Alignment.topLeft,
          color: color,
          child: Text('${model.error}'));
    } else {
      return Container(
          alignment: Alignment.topLeft,
          color: color,
          child: const Center(
            child: SizedBox(
              height: 40,
              width: 40,
              child: CircularProgressIndicator(),
            ),
          ));
    }
  }
}
