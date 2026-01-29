import 'package:flutter/material.dart';
import 'package:front_flutter/objects/cita.dart';
import 'package:front_flutter/objects/cliente.dart';
import 'package:front_flutter/objects/estado_cita.dart';
import 'package:front_flutter/utils/utils.dart';

class CitaEditorView extends StatefulWidget {
  final Cita? cita; // null => crear
  final List<Cliente> clientes;

  final VoidCallback onBack;
  final VoidCallback onDiscard;

  final void Function(DateTime fecha, int clienteId, EstadoCita estado) onSave;

  const CitaEditorView({
    super.key,
    required this.cita,
    required this.clientes,
    required this.onBack,
    required this.onDiscard,
    required this.onSave,
  });

  @override
  State<CitaEditorView> createState() => _CitaEditorViewState();
}

class _CitaEditorViewState extends State<CitaEditorView> {
  final _formKey = GlobalKey<FormState>();

  DateTime? _fecha;
  int? _clienteId;
  late EstadoCita _estado;

  @override
  void initState() {
    super.initState();

    _fecha = widget.cita?.fechaCita?.toLocal();
    _clienteId = widget.cita?.clienteCita;
    _estado = widget.cita?.estado ?? EstadoCita.pendiente;

    // Si estás creando y hay clientes, preselecciona el primero
    if (widget.cita == null &&
        _clienteId == null &&
        widget.clientes.isNotEmpty) {
      _clienteId = widget.clientes.first.idCliente;
    }
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final initial = _fecha ?? now;

    final date = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(today) ? today : initial,
      firstDate: today,
      lastDate: today.add(const Duration(days: 365 * 2)),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null) return;

    setState(() {
      _fecha = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  String _estadoLabel(EstadoCita e) {
    switch (e) {
      case EstadoCita.pendiente:
        return 'Pendiente';
      case EstadoCita.confirmada:
        return 'Confirmada';
      case EstadoCita.eliminado:
        return 'Rechazado';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.cita != null;

    return Padding(
      padding: const EdgeInsets.all(14),
      child: Card(
        elevation: 0.6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: widget.onBack,
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isEdit ? 'Cita (Editar)' : 'Cita (Nueva)',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Form(
                key: _formKey,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    children: [
                      _LabeledField(
                        label: 'Fecha',
                        child: TextFormField(
                          readOnly: true,
                          onTap: _pickDateTime,
                          decoration: InputDecoration(
                            isDense: true,
                            border: const OutlineInputBorder(),
                            hintText: 'Seleccionar fecha y hora',
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.calendar_month),
                              onPressed: _pickDateTime,
                            ),
                          ),
                          controller: TextEditingController(
                            text:
                                _fecha == null
                                    ? ''
                                    : "${obtenerFechaString(_fecha)} - ${obtenerHoraString(_fecha)}",
                          ),
                          validator: (_) {
                            if (_fecha == null) return 'Fecha requerida';

                            final now = DateTime.now();
                            if (_fecha!.isBefore(now)) {
                              return 'No puedes seleccionar una fecha/hora anterior a la actual';
                            }
                            return null;
                          },
                        ),
                      ),

                      const SizedBox(height: 10),

                      _LabeledField(
                        label: 'Cliente',
                        child: DropdownButtonFormField<int>(
                          value: _clienteId,
                          isDense: true,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          items:
                              widget.clientes
                                  .map(
                                    (c) => DropdownMenuItem<int>(
                                      value: c.idCliente,
                                      child: Text(c.nombreCliente),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (v) => setState(() => _clienteId = v),
                          validator: (v) {
                            if (v == null) return 'Cliente requerido';
                            return null;
                          },
                        ),
                      ),

                      const SizedBox(height: 10),

                      _LabeledField(
                        label: 'Estado',
                        child: DropdownButtonFormField<EstadoCita>(
                          value: _estado,
                          isDense: true,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          items:
                              EstadoCita.values
                                  .map(
                                    (e) => DropdownMenuItem<EstadoCita>(
                                      value: e,
                                      child: Text(_estadoLabel(e)),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (v) => setState(() => _estado = v!),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                    ),
                    onPressed: widget.onDiscard,
                    child: const Text('Descartar'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1F6FEB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                    ),
                    onPressed: () {
                      if (_formKey.currentState?.validate() != true) return;
                      widget.onSave(_fecha!, _clienteId!, _estado);
                    },
                    child: const Text('Guardar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final Widget child;

  const _LabeledField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: child),
      ],
    );
  }
}
