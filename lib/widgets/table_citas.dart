import 'package:flutter/material.dart';
import 'package:front_flutter/objects/cita.dart';
import 'package:front_flutter/objects/estado_cita.dart';
import 'package:front_flutter/utils/utils.dart';

class CitasTable extends StatelessWidget {
  final List<Cita> citas;
  final void Function(Cita) onEditar;
  final void Function(Cita) onEliminar;

  const CitasTable({
    super.key,
    required this.citas,
    required this.onEditar,
    required this.onEliminar,
  });

  String _estadoLabel(EstadoCita e) {
    switch (e) {
      case EstadoCita.pendiente:
        return 'Pendiente';
      case EstadoCita.confirmada:
        return 'Confirmada';
      case EstadoCita.eliminado:
        return 'Rechazada';
    }
  }

  Color _estadoBg(EstadoCita e) {
    switch (e) {
      case EstadoCita.pendiente:
        return const Color(0xFFFFF7ED);
      case EstadoCita.confirmada:
        return const Color(0xFFECFDF5);
      case EstadoCita.eliminado:
        return const Color(0xFFFEF2F2);
    }
  }

  Color _estadoFg(EstadoCita e) {
    switch (e) {
      case EstadoCita.pendiente:
        return const Color(0xFF9A3412);
      case EstadoCita.confirmada:
        return const Color(0xFF166534);
      case EstadoCita.eliminado:
        return const Color(0xFF991B1B);
    }
  }

  Widget _estadoFooterBadge(EstadoCita e) {
    return Container(
      padding: EdgeInsets.all(10),
      color: _estadoBg(e),
      child: Center(
        child: Text(
          _estadoLabel(e),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: _estadoFg(e),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;

        final showTelefonoCol = w >= 520;
        final showEmailCol = w >= 760;

        final headerStyle = TextStyle(
          color: Colors.grey.shade700,
          fontWeight: FontWeight.w700,
          fontSize: 12.5,
        );

        return ListView(
          children: [
            // HEADER (✅ quitamos "Estado")
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Center(child: Text('Fecha', style: headerStyle)),
                  ),
                  SizedBox(
                    height: 30,
                    child: const VerticalDivider(
                      color: Colors.grey,
                      width: 10,
                      thickness: 1,
                    ),
                  ),
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
            ...citas.map((c) {
              final showTelefonoInline = !showTelefonoCol;
              final showEmailInline = !showEmailCol;

              final nombre = c.nombreCliente ?? '(sin nombre)';
              final tel = c.telefonoCliente ?? '-';
              final email = c.emailCliente ?? '-';

              final fechaTxt = obtenerFechaString(c.fechaCita);
              final horaTxt = obtenerHoraString(c.fechaCita);

              return Container(
                margin: const EdgeInsets.only(bottom: 6),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ✅ Contenido principal en Row (como lo tenías)
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // FECHA
                          Expanded(
                            flex: 2,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SelectableText(
                                  fechaTxt,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[800],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                SelectableText(
                                  horaTxt,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(
                            height: 60,
                            child: const VerticalDivider(
                              color: Colors.grey,
                              width: 10,
                              thickness: 1,
                            ),
                          ),

                          // CLIENTE + inline cuando se ocultan columnas
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SelectableText(
                                  nombre,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),

                                if (showTelefonoInline) ...[
                                  const SizedBox(height: 4),
                                  SelectableText.rich(
                                    TextSpan(
                                      children: [
                                        const TextSpan(
                                          text: 'Teléfono: ',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        TextSpan(
                                          text: tel,
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
                                    TextSpan(
                                      children: [
                                        const TextSpan(
                                          text: 'Email: ',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        TextSpan(
                                          text: email,
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

                          // TEL / EMAIL como columnas
                          if (showTelefonoCol)
                            Expanded(flex: 2, child: Text(tel)),
                          if (showEmailCol)
                            Expanded(flex: 3, child: Text(email)),

                          // BOTONES
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
                    ),

                    Container(height: 1, color: Colors.grey.shade200),
                    _estadoFooterBadge(c.estado),
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
