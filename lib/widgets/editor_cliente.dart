import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:front_flutter/objects/cliente.dart';

class ClienteEditorView extends StatefulWidget {
  final Cliente? cliente; // null => crear
  final VoidCallback onBack;
  final VoidCallback onDiscard;
  final void Function(String nombre, String telefono, String email) onSave;

  const ClienteEditorView({
    super.key,
    required this.cliente,
    required this.onBack,
    required this.onDiscard,
    required this.onSave,
  });

  @override
  State<ClienteEditorView> createState() => _ClienteEditorViewState();
}

class _ClienteEditorViewState extends State<ClienteEditorView> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nombre;
  late final TextEditingController _telefono;
  late final TextEditingController _email;

  // Nombre: [\w\s]+
  final _reNombre = RegExp(r'^[a-zA-ZÀ-ÿ\s]+$');
  // Tel: [\d]+
  final _reTelefono = RegExp(r'^\d{1,9}$');
  final _reEmail = RegExp(r'^[\w.+-]+@[\w.-]+\.\w{2,3}$');

  @override
  void initState() {
    super.initState();
    _nombre = TextEditingController(text: widget.cliente?.nombreCliente ?? '');
    _telefono = TextEditingController(
      text: widget.cliente?.telefonoCliente ?? '',
    );
    _email = TextEditingController(text: widget.cliente?.emailCliente ?? '');
  }

  @override
  void dispose() {
    _nombre.dispose();
    _telefono.dispose();
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.cliente != null;

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
                    isEdit ? 'Cliente (Editar)' : 'Cliente (Nuevo)',
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
                        label: 'Nombre',
                        child: TextFormField(
                          controller: _nombre,
                          decoration: const InputDecoration(
                            isDense: true,
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) {
                            final s = (v ?? '').trim();
                            if (s.isEmpty) return 'Nombre requerido';
                            if (!_reNombre.hasMatch(s)) {
                              return 'Nombre inválido (solo letras/números/espacios)';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      _LabeledField(
                        label: 'Teléfono',
                        child: TextFormField(
                          controller: _telefono,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(9),
                          ],
                          decoration: const InputDecoration(
                            isDense: true,
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) {
                            final s = (v ?? '').trim();
                            if (s.isEmpty) return 'Teléfono requerido';
                            if (!_reTelefono.hasMatch(s)) {
                              return 'Teléfono inválido (máx. 9 dígitos)';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      _LabeledField(
                        label: 'Email',
                        child: TextFormField(
                          controller: _email,
                          decoration: const InputDecoration(
                            isDense: true,
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) {
                            final s = (v ?? '').trim();
                            if (s.isEmpty) return 'Email requerido';
                            if (!_reEmail.hasMatch(s)) return 'Email inválido';
                            return null;
                          },
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
                      widget.onSave(
                        _nombre.text.trim(),
                        _telefono.text.trim(),
                        _email.text.trim(),
                      );
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
