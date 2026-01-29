import 'package:flutter/material.dart';

/// Tipos soportados
enum DashboardBoxTipe {
  clientesActivos,
  clientesInactivos,
  citasPendientes,
  citasConfirmadas,
  citasRechazadas,
}

class DashboardBox extends StatelessWidget {
  final DashboardBoxTipe type;
  final int count;
  final String? label;
  final double minWidth;
  final VoidCallback? onTap;
  final bool isSelected;

  const DashboardBox({
    super.key,
    required this.type,
    required this.count,
    this.label,
    this.minWidth = 180,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final meta = _meta(type, context);
    final textLabel = label ?? meta.label;

    final bgColor =
        isSelected ? meta.color : meta.color.withAlpha((.88 * 255).round());

    final content = Container(
      constraints: BoxConstraints(minWidth: minWidth, maxWidth: 200),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            blurRadius: 8,
            offset: Offset(0, 2),
            color: Color(0x22000000),
          ),
        ],
        border:
            isSelected
                ? Border.all(
                  color: Colors.white.withAlpha((.65 * 255).round()),
                  width: 1,
                )
                : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(meta.icon, color: Colors.white, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              textLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            count.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return content;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: content,
      ),
    );
  }

  _StatMeta _meta(DashboardBoxTipe t, BuildContext context) {
    switch (t) {
      case DashboardBoxTipe.clientesActivos:
        return _StatMeta(
          label: 'Clientes Activos',
          color: const Color(0xFF1F6FEB), // azul
          icon: Icons.person,
        );
      case DashboardBoxTipe.clientesInactivos:
        return _StatMeta(
          label: 'Clientes Inactivos',
          color: const Color(0xFF6B7280), // gris
          icon: Icons.person_off,
        );
      case DashboardBoxTipe.citasPendientes:
        return _StatMeta(
          label: 'Citas Pendientes',
          color: const Color(0xFFF59E0B), // naranja
          icon: Icons.schedule,
        );
      case DashboardBoxTipe.citasConfirmadas:
        return _StatMeta(
          label: 'Citas Confirmadas',
          color: const Color(0xFF22C55E), // verde
          icon: Icons.check_circle,
        );
      case DashboardBoxTipe.citasRechazadas:
        return _StatMeta(
          label: 'Citas Rechazadas',
          color: const Color(0xFFEF4444), // rojo
          icon: Icons.cancel,
        );
    }
  }
}

class _StatMeta {
  final String label;
  final Color color;
  final IconData icon;

  const _StatMeta({
    required this.label,
    required this.color,
    required this.icon,
  });
}
