import 'estado_cliente.dart';

class Cliente {
  final int idCliente;
  final String nombreCliente;
  final String telefonoCliente;
  final String emailCliente;
  final EstadoCliente estadoCliente;

  Cliente({
    required this.idCliente,
    required this.nombreCliente,
    required this.telefonoCliente,
    required this.emailCliente,
    required this.estadoCliente,
  });

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      idCliente: (json['id_cliente'] as num).toInt(),
      nombreCliente: (json['nombre_cliente'] ?? '').toString(),
      telefonoCliente: (json['telefono_cliente'] ?? '').toString(),
      emailCliente: (json['email_cliente'] ?? '').toString(),
      estadoCliente: EstadoCliente.fromInt(json['activo_cliente']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id_cliente': idCliente,
    'nombre_cliente': nombreCliente,
    'telefono_cliente': telefonoCliente,
    'email_cliente': emailCliente,
    'activo_cliente': estadoCliente.toJson(),
  };

  static List<Cliente> fromJsonList(List<dynamic> list) =>
      list.map((e) => Cliente.fromJson(e as Map<String, dynamic>)).toList();

  bool get isActivo => estadoCliente.isActivo;
}
