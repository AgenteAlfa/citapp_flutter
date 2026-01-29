import 'package:flutter/material.dart';
import 'package:front_flutter/objects/cliente.dart';

class ClientesTable extends StatelessWidget {
  final List<Cliente> clientes;
  final void Function(Cliente) onEditar;
  final void Function(Cliente) onEliminar;

  const ClientesTable({
    super.key,
    required this.clientes,
    required this.onEditar,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;

        final showEmailCol = w >= 800;
        final showTelefonoCol = w >= 450;

        final headerStyle = TextStyle(
          color: Colors.grey.shade700,
          fontWeight: FontWeight.w700,
          fontSize: 12.5,
        );

        return ListView(
          children: [
            // HEADER
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(flex: 3, child: Text('Cliente', style: headerStyle)),
                  if (showTelefonoCol)
                    Expanded(
                      flex: 2,
                      child: Text('Teléfono', style: headerStyle),
                    ),
                  if (showEmailCol)
                    Expanded(flex: 3, child: Text('Email', style: headerStyle)),
                  const SizedBox(width: 180),
                ],
              ),
            ),

            const SizedBox(height: 6),

            // ROWS
            ...clientes.map((c) {
              final showTelefonoInline = !showTelefonoCol;
              final showEmailInline = !showEmailCol;

              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cliente + info extra debajo cuando se ocultan columnas
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SelectableText(
                            c.nombreCliente,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          if (showTelefonoInline) ...[
                            const SizedBox(height: 4),
                            SelectableText.rich(
                              maxLines: 1,

                              TextSpan(
                                children: [
                                  const TextSpan(
                                    text: 'Teléfono: ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  TextSpan(
                                    text: c.telefonoCliente,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],

                          if (showEmailInline) ...[
                            const SizedBox(height: 2),
                            SelectableText.rich(
                              maxLines: 1,

                              TextSpan(
                                children: [
                                  const TextSpan(
                                    text: 'Email: ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  TextSpan(
                                    text: c.emailCliente,

                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ],
                      ),
                    ),

                    if (showTelefonoCol)
                      Expanded(flex: 2, child: Text(c.telefonoCliente)),

                    if (showEmailCol)
                      Expanded(flex: 3, child: Text(c.emailCliente)),

                    // Botones
                    SizedBox(
                      width: 180,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1F6FEB),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            onPressed: () => onEditar(c),
                            child: const Text('Editar'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFEF4444),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            onPressed: () => onEliminar(c),
                            child: const Text('Eliminar'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        );
      },
    );
  }
}
