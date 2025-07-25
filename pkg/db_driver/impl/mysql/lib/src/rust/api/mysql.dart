// This file is automatically generated, so please do not edit it.
// @generated by `flutter_rust_bridge`@ 2.9.0.

// ignore_for_file: invalid_use_of_internal_member, unused_import, unnecessary_import

import '../frb_generated.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'package:freezed_annotation/freezed_annotation.dart' hide protected;
part 'mysql.freezed.dart';

// These types are ignored because they are neither used by any `pub` functions nor (for structs and enums) marked `#[frb(unignore)]`: `DataType`
// These functions are ignored (category: IgnoreBecauseExplicitAttribute): `from_column`, `from_value`

// Rust type: RustOpaqueMoi<flutter_rust_bridge::for_generated::RustAutoOpaqueInner<ConnWrapper>>
abstract class ConnWrapper implements RustOpaqueInterface {
  Future<void> close();

  static Future<ConnWrapper> open({required String dsn}) =>
      RustLib.instance.api.crateApiMysqlConnWrapperOpen(dsn: dsn);

  Future<QueryResult> query({required String query});
}

class QueryColumn {
  final String name;
  final int columnType;

  const QueryColumn({
    required this.name,
    required this.columnType,
  });

  @override
  int get hashCode => name.hashCode ^ columnType.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QueryColumn &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          columnType == other.columnType;
}

class QueryResult {
  final List<QueryColumn> columns;
  final List<QueryRow> rows;
  final BigInt affectedRows;

  const QueryResult({
    required this.columns,
    required this.rows,
    required this.affectedRows,
  });

  @override
  int get hashCode => columns.hashCode ^ rows.hashCode ^ affectedRows.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QueryResult &&
          runtimeType == other.runtimeType &&
          columns == other.columns &&
          rows == other.rows &&
          affectedRows == other.affectedRows;
}

class QueryRow {
  final List<QueryValue> values;

  const QueryRow({
    required this.values,
  });

  @override
  int get hashCode => values.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QueryRow &&
          runtimeType == other.runtimeType &&
          values == other.values;
}

@freezed
sealed class QueryValue with _$QueryValue {
  const QueryValue._();

  const factory QueryValue.null_() = QueryValue_NULL;
  const factory QueryValue.bytes(
    Uint8List field0,
  ) = QueryValue_Bytes;
  const factory QueryValue.int(
    PlatformInt64 field0,
  ) = QueryValue_Int;
  const factory QueryValue.uInt(
    BigInt field0,
  ) = QueryValue_UInt;
  const factory QueryValue.float(
    double field0,
  ) = QueryValue_Float;
  const factory QueryValue.double(
    double field0,
  ) = QueryValue_Double;
  const factory QueryValue.dateTime(
    PlatformInt64 field0,
  ) = QueryValue_DateTime;
}
