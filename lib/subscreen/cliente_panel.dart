import 'package:flutter/material.dart';
import 'package:front_flutter/config/api_config.dart';
import 'package:front_flutter/objects/cliente.dart';
import 'package:front_flutter/objects/estado_cliente.dart';
import 'package:front_flutter/utils/api_service.dart';
import 'package:front_flutter/utils/dio_client.dart';
import 'package:front_flutter/widgets/box_tipo.dart';
import 'package:front_flutter/widgets/editor_cliente.dart';
import 'package:front_flutter/widgets/table_clientes.dart';

enum ClientesFiltro { activos, inactivos, todos }

class ClientesPanel extends StatefulWidget {
  const ClientesPanel({super.key});

  @override
  State<ClientesPanel> createState() => _ClientesPanelState();
}

class _ClientesPanelState extends State<ClientesPanel> {
  late final ApiService _api;

  ClientesFiltro _filtro = ClientesFiltro.activos;
  bool _isEditing = false;
  Cliente? _editingCliente;
  String _search = '';

  bool _loading = false;
  String? _error;

  List<Cliente> _clientes = [];

  int get _countActivos =>
      _clientes.where((c) => c.estadoCliente == EstadoCliente.activo).length;

  int get _countInactivos =>
      _clientes.where((c) => c.estadoCliente == EstadoCliente.inactivo).length;

  List<Cliente> get _clientesFiltrados {
    Iterable<Cliente> it = _clientes;

    if (_filtro == ClientesFiltro.activos) {
      it = it.where((c) => c.estadoCliente == EstadoCliente.activo);
    } else if (_filtro == ClientesFiltro.inactivos) {
      it = it.where((c) => c.estadoCliente == EstadoCliente.inactivo);
    }

    final s = _search.trim().toLowerCase();
    if (s.isNotEmpty) {
      it = it.where(
        (c) =>
            c.nombreCliente.toLowerCase().contains(s) ||
            c.telefonoCliente.toLowerCase().contains(s) ||
            c.emailCliente.toLowerCase().contains(s),
      );
    }

    return it.toList();
  }

  @override
  void initState() {
    super.initState();
    final dioClient = DioClient(APIconfig.baseUrl);
    _api = ApiService(dioClient);
    _loadClientes();
  }

  Future<void> _loadClientes() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = await _api.getClientes(includeInactivos: true);
      setState(() => _clientes = data);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  void _openCreate() {
    setState(() {
      _isEditing = true;
      _editingCliente = null;
    });
  }

  void _openEdit(Cliente c) {
    setState(() {
      _isEditing = true;
      _editingCliente = c;
    });
  }

  void _closeEditor() {
    setState(() {
      _isEditing = false;
      _editingCliente = null;
    });
  }

  Future<void> _deleteCliente(Cliente c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Eliminar cliente'),
            content: Text('¿Eliminar a "${c.nombreCliente}"?'),
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
      await _api.eliminarCliente(c.idCliente);
      await _loadClientes();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _saveCliente(
    String nombre,
    String telefono,
    String email,
  ) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      if (_editingCliente == null) {
        await _api.crearCliente(
          Cliente(
            idCliente: 0,
            nombreCliente: nombre,
            telefonoCliente: telefono,
            emailCliente: email,
            estadoCliente: EstadoCliente.activo,
          ),
        );

        await _loadClientes();

        _closeEditor();
      } else {
        await _api.actualizarCliente(_editingCliente!.idCliente, {
          'nombre_cliente': nombre,
          'telefono_cliente': telefono,
          'email_cliente': email,
        });
        await _loadClientes();
        _closeEditor();
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isEditing) {
      return ClienteEditorView(
        cliente: _editingCliente,
        onBack: _closeEditor,
        onDiscard: _closeEditor,
        onSave: _saveCliente,
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
                type: DashboardBoxTipe.clientesActivos,
                count: _countActivos,
                isSelected: _filtro == ClientesFiltro.activos,
                onTap: () => setState(() => _filtro = ClientesFiltro.activos),
              ),
              DashboardBox(
                type: DashboardBoxTipe.clientesInactivos,
                count: _countInactivos,
                isSelected: _filtro == ClientesFiltro.inactivos,
                onTap: () => setState(() => _filtro = ClientesFiltro.inactivos),
              ),
              DashboardBox(
                type: DashboardBoxTipe.citasPendientes,
                label: 'Todos',
                count: _clientes.length,
                isSelected: _filtro == ClientesFiltro.todos,
                onTap: () => setState(() => _filtro = ClientesFiltro.todos),
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
                          'Clientes',
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
                        child: ClientesTable(
                          clientes: _clientesFiltrados,
                          onEditar: _openEdit,
                          onEliminar: _deleteCliente,
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
