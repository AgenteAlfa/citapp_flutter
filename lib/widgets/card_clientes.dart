import 'package:flutter/material.dart';
import 'package:front_flutter/objects/cliente.dart';
import 'package:front_flutter/widgets/table_clientes.dart';

class ClientesCard extends StatelessWidget {
  final String searchHint;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onNuevo;

  final List<Cliente> clientes;
  final void Function(Cliente) onEditar;
  final void Function(Cliente) onEliminar;

  const ClientesCard({
    required this.searchHint,
    required this.onSearchChanged,
    required this.onNuevo,
    required this.clientes,
    required this.onEditar,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // header + Nuevo
            Row(
              children: [
                const Text(
                  'Clientes',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                const Spacer(),
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
                  onPressed: onNuevo,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Nuevo'),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // buscador
            SizedBox(
              width: 320,
              child: TextField(
                onChanged: onSearchChanged,
                decoration: InputDecoration(
                  isDense: true,
                  hintText: searchHint,
                  prefixIcon: const Icon(Icons.search, size: 18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // tabla
            ClientesTable(
              clientes: clientes,
              onEditar: onEditar,
              onEliminar: onEliminar,
            ),
          ],
        ),
      ),
    );
  }
}
