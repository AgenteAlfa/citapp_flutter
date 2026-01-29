import 'dart:io';

import 'package:intl/intl.dart';

String obtenerFechaString(
  DateTime? fecha, {
  String mensajePorDefecto = "Sin Fecha",
}) {
  if (fecha == null) return mensajePorDefecto;

  final localFecha = fecha.toLocal();
  return DateFormat('dd/MM/yyyy').format(localFecha);
}

String obtenerHoraString(
  DateTime? fecha, {
  String mensajePorDefecto = "Sin Hora",
}) {
  if (fecha == null) return mensajePorDefecto;

  final localFecha = fecha.toLocal();
  return DateFormat('HH:mm').format(localFecha);
}

DateTime? convertirFecha(
  String? fecha, {
  bool throwOnError = false,
  bool toUtc = false,
}) {
  DateTime finish(DateTime dt) => toUtc ? dt.toUtc() : dt;

  DateTime? fail(String msg) {
    if (throwOnError) throw FormatException(msg);
    return null;
  }

  if (fecha == null) return fail('Fecha nula');
  final raw = fecha.trim();
  if (raw.isEmpty) return fail('Fecha vacía');

  final onlyDigits = RegExp(r'^\d+$');
  if (onlyDigits.hasMatch(raw)) {
    try {
      final n = int.parse(raw);
      if (raw.length == 10) {
        return finish(
          DateTime.fromMillisecondsSinceEpoch(n * 1000, isUtc: true),
        );
      } else if (raw.length == 13) {
        return finish(DateTime.fromMillisecondsSinceEpoch(n, isUtc: true));
      }
    } catch (_) {
      /* sigue */
    }
  }

  try {
    return finish(DateTime.parse(raw));
  } catch (_) {
    /* sigue */
  }

  final isoSpace = RegExp(r'^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}(\.\d+)?$');
  if (isoSpace.hasMatch(raw)) {
    final normalized = raw.replaceFirst(' ', 'T');
    try {
      return finish(DateTime.parse(normalized));
    } catch (_) {
      /* sigue */
    }
  }

  try {
    return finish(HttpDate.parse(raw));
  } catch (_) {
    /* sigue */
  }

  final isoSpaceNoSec = RegExp(r'^\d{4}-\d{2}-\d{2} \d{2}:\d{2}$');
  if (isoSpaceNoSec.hasMatch(raw)) {
    try {
      return finish(DateTime.parse(raw.replaceFirst(' ', 'T') + ':00'));
    } catch (_) {
      /* sigue */
    }
  }

  return fail('Formato de fecha no soportado: "$raw"');
}

String formatoPorcentaje(double? v) =>
    v == null ? '-' : '${(v * 100).toStringAsFixed(1)}%';

double round2(double value) => double.parse(value.toStringAsFixed(2));
