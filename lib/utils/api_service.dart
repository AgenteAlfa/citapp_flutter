import 'package:dio/dio.dart';
import 'package:front_flutter/config/api_config.dart';
import 'package:front_flutter/objects/cita.dart';
import 'package:front_flutter/objects/cliente.dart';
import 'package:front_flutter/objects/estado_cita.dart';

import 'dio_client.dart';

class ApiService {
  final Dio _dio;

  ApiService(DioClient client) : _dio = client.dio;

  // ---------- AUTH ----------

  Future<String> login(String username, String password) async {
    final res = await _dio.post(
      APIconfig.login,
      data: {'username': username, 'password': password},
    );

    final token = res.data['token'] as String;
    return token;
  }

  // ---------- CLIENTES ----------

  Future<List<Cliente>> getClientes({bool includeInactivos = false}) async {
    final res = await _dio.get(
      includeInactivos ? APIconfig.clientesConInactivos : APIconfig.clientes,
    );

    return Cliente.fromJsonList(res.data as List);
  }

  Future<Cliente> getClienteById(int id) async {
    final res = await _dio.get(APIconfig.clienteById(id));
    return Cliente.fromJson(res.data);
  }

  Future<Cliente> crearCliente(Cliente cliente) async {
    final res = await _dio.post(APIconfig.clientes, data: cliente.toJson());
    return Cliente.fromJson(res.data);
  }

  Future<Cliente> actualizarCliente(int id, Map<String, dynamic> data) async {
    final res = await _dio.put(APIconfig.clienteById(id), data: data);
    return Cliente.fromJson(res.data);
  }

  Future<void> eliminarCliente(int id) async {
    await _dio.delete(APIconfig.clienteById(id));
  }

  // ---------- CITAS ----------

  Future<List<Cita>> getCitas() async {
    final res = await _dio.get(APIconfig.citas);
    return Cita.fromJsonList(res.data as List);
  }

  Future<List<Cita>> getCitasPorEstado(EstadoCita estado) async {
    final res = await _dio.get(APIconfig.citasPorEstado(estado.value));
    return Cita.fromJsonList(res.data as List);
  }

  Future<Cita> getCitaById(int id) async {
    final res = await _dio.get(APIconfig.citaById(id));
    return Cita.fromJson(res.data);
  }

  Future<Cita> crearCita({
    required DateTime fecha,
    required int clienteId,
    EstadoCita estado = EstadoCita.pendiente,
  }) async {
    print("Estado -> ${estado.value}");
    final res = await _dio.post(
      APIconfig.citas,
      data: {
        'fecha_cita': fecha.toUtc().toIso8601String(),
        'cliente_cita': clienteId,
        'estado': estado.value,
      },
    );

    return Cita.fromJson(res.data);
  }

  Future<Cita> actualizarCita(
    int id, {
    DateTime? fecha,
    int? clienteId,
    EstadoCita? estado,
  }) async {
    final data = <String, dynamic>{};
    if (fecha != null) {
      data['fecha_cita'] = fecha.toUtc().toIso8601String();
    }
    if (clienteId != null) {
      data['cliente_cita'] = clienteId;
    }
    if (estado != null) {
      data['estado'] = estado.value;
    }

    final res = await _dio.put(APIconfig.citaById(id), data: data);

    return Cita.fromJson(res.data);
  }

  Future<void> eliminarCita(int id) async {
    await _dio.delete(APIconfig.citaById(id));
  }
}
