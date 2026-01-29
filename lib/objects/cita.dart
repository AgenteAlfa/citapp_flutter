import 'package:front_flutter/utils/utils.dart';

import 'estado_cita.dart';

class Cita {
  final int idCita;
  final DateTime? fechaCita;
  final int clienteCita;
  final String? nombreCliente;
  final String? telefonoCliente;
  final String? emailCliente;
  final EstadoCita estado;

  Cita({
    required this.idCita,
    required this.fechaCita,
    required this.clienteCita,
    required this.nombreCliente,
    required this.telefonoCliente,
    required this.emailCliente,
    required this.estado,
  });

  factory Cita.fromJson(Map<String, dynamic> json) {
    return Cita(
      idCita: (json['id_cita'] as num).toInt(),
      fechaCita: convertirFecha(json['fecha_cita']?.toString(), toUtc: true),
      clienteCita: (json['cliente_cita'] as num).toInt(),
      nombreCliente: json['nombre_cliente']?.toString(),
      telefonoCliente: json['telefono_cliente']?.toString(),
      emailCliente: json['email_cliente']?.toString(),
      estado: EstadoCita.fromString(json['estado']?.toString()),
    );
  }

  Map<String, dynamic> toJson() => {
    'id_cita': idCita,
    'fecha_cita': fechaCita?.toUtc().toIso8601String(),
    'cliente_cita': clienteCita,
    'nombre_cliente': nombreCliente,
    'telefono_cliente': telefonoCliente,
    'email_cliente': emailCliente,
    'estado': estado.toJson(),
  };

  static List<Cita> fromJsonList(List<dynamic> list) =>
      list.map((e) => Cita.fromJson(e as Map<String, dynamic>)).toList();

  /// Para UI: normalmente quieres mostrar local
  DateTime? get fechaLocal => fechaCita?.toLocal();
}
