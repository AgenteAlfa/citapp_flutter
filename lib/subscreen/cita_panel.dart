import 'package:flutter/material.dart';
import 'package:front_flutter/config/api_config.dart';
import 'package:front_flutter/objects/cita.dart';
import 'package:front_flutter/objects/cliente.dart';
import 'package:front_flutter/objects/estado_cita.dart';
import 'package:front_flutter/utils/api_service.dart';
import 'package:front_flutter/utils/dio_client.dart';
import 'package:front_flutter/widgets/box_tipo.dart';
import 'package:front_flutter/widgets/editor_cita.dart';
import 'package:front_flutter/widgets/table_citas.dart';

enum CitasFiltro { pendientes, confirmadas, rechazadas, todos }

class CitasPanel extends StatefulWidget {
  const CitasPanel({super.key});

  @override
  State<CitasPanel> createState() => _CitasPanelState();
}

class _CitasPanelState extends State<CitasPanel> {
  late final ApiService _api;

  CitasFiltro _filtro = CitasFiltro.pendientes;
  bool _isEditing = false;
  Cita? _editingCita;
  String _search = '';

  bool _loading = false;
  String? _error;

  List<Cita> _citas = [];
  List<Cliente> _clientes = [];

  int get _countPendientes =>
      _citas.where((c) => c.estado == EstadoCita.pendiente).length;

  int get _countConfirmadas =>
      _citas.where((c) => c.estado == EstadoCita.confirmada).length;

  int get _countRechazadas =>
      _citas.where((c) => c.estado == EstadoCita.eliminado).length;

  List<Cita> get _citasFiltradas {
    Iterable<Cita> it = _citas;

    if (_filtro == CitasFiltro.pendientes) {
      it = it.where((c) => c.estado == EstadoCita.pendiente);
    } else if (_filtro == CitasFiltro.confirmadas) {
      it = it.where((c) => c.estado == EstadoCita.confirmada);
    } else if (_filtro == CitasFiltro.rechazadas) {
      it = it.where((c) => c.estado == EstadoCita.eliminado);
    }

    final s = _search.trim().toLowerCase();
    if (s.isNotEmpty) {
      it = it.where((c) {
        final nombre = (c.nombreCliente ?? '').toLowerCase();
        final tel = (c.telefonoCliente ?? '').toLowerCase();
        final email = (c.emailCliente ?? '').toLowerCase();
        final estado = c.estado.value.toLowerCase();
        final fecha = (c.fechaCita?.toLocal().toString() ?? '').toLowerCase();
        return nombre.contains(s) ||
            tel.contains(s) ||
            email.contains(s) ||
            estado.contains(s) ||
            fecha.contains(s) ||
            c.idCita.toString().contains(s);
      });
    }

    return it.toList();
  }

  @override
  void initState() {
    super.initState();
    final dioClient = DioClient(APIconfig.baseUrl);
    _api = ApiService(dioClient);
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final clientes = await _api.getClientes(includeInactivos: false);
      final citas = await _api.getCitas();

      setState(() {
        _clientes = clientes;
        _citas = citas;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  void _openCreate() {
    setState(() {
      _isEditing = true;
      _editingCita = null;
    });
  }

  void _openEdit(Cita c) {
    setState(() {
      _isEditing = true;
      _editingCita = c;
    });
  }

  void _closeEditor() {
    setState(() {
      _isEditing = false;
      _editingCita = null;
    });
  }

  Future<void> _deleteCita(Cita c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Eliminar cita'),
            content: Text('¿Marcar la cita #${c.idCita} como eliminada?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Eliminar'),
              ),
            ],
          ),
    );

    if (ok != true) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await _api.eliminarCita(c.idCita);
      await _loadAll();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _saveCita(
    DateTime fecha,
    int clienteId,
    EstadoCita estado,
  ) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      if (_editingCita == null) {
        await _api.crearCita(
          fecha: fecha,
          clienteId: clienteId,
          estado: estado,
        );
      } else {
        await _api.actualizarCita(
          _editingCita!.idCita,
          fecha: fecha,
          clienteId: clienteId,
          estado: estado,
        );
      }

      await _loadAll();
      _closeEditor();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isEditing) {
      return CitaEditorView(
        cita: _editingCita,
        clientes: _clientes,
        onBack: _closeEditor,
        onDiscard: _closeEditor,
        onSave: _saveCita,
      );
    }

    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            ),

          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              DashboardBox(
                type: DashboardBoxTipe.citasPendientes,
                count: _countPendientes,
                isSelected: _filtro == CitasFiltro.pendientes,
                onTap: () => setState(() => _filtro = CitasFiltro.pendientes),
              ),
              DashboardBox(
                type: DashboardBoxTipe.citasConfirmadas,
                count: _countConfirmadas,
                isSelected: _filtro == CitasFiltro.confirmadas,
                onTap: () => setState(() => _filtro = CitasFiltro.confirmadas),
              ),
              DashboardBox(
                type: DashboardBoxTipe.citasRechazadas,
                count: _countRechazadas,
                isSelected: _filtro == CitasFiltro.rechazadas,
                onTap: () => setState(() => _filtro = CitasFiltro.rechazadas),
              ),
              DashboardBox(
                type: DashboardBoxTipe.clientesActivos,
                label: 'Todas',
                count: _citas.length,
                isSelected: _filtro == CitasFiltro.todos,
                onTap: () => setState(() => _filtro = CitasFiltro.todos),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Expanded(
            child: Card(
              elevation: 0.6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      spacing: 20,
                      children: [
                        const Text(
                          'Citas',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            onChanged: (v) => setState(() => _search = v),
                            decoration: InputDecoration(
                              isDense: true,
                              hintText: 'Buscar...',
                              prefixIcon: const Icon(Icons.search, size: 18),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(22),
                              ),
                            ),
                          ),
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF22C55E),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: _loading ? null : _openCreate,
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Nuevo'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    if (_loading)
                      const Expanded(
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else
                      Expanded(
                        child: CitasTable(
                          citas: _citasFiltradas,
                          onEditar: _openEdit,
                          onEliminar: _deleteCita,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
