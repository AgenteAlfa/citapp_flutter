import 'package:flutter/material.dart';
import 'package:front_flutter/subscreen/cita_panel.dart';
import 'package:front_flutter/subscreen/cliente_panel.dart';
import 'package:go_router/go_router.dart';
import 'package:universal_html/html.dart' as html;

enum DashboardSection { clientes, citas }

class DashboardShell extends StatefulWidget {
  final DashboardSection section;

  const DashboardShell({super.key, required this.section});

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  bool _sidebarOpen = false;

  String get _title =>
      widget.section == DashboardSection.clientes
          ? 'Dashboard - Clientes'
          : 'Dashboard - Citas';

  void _logout(BuildContext context) {
    html.window.sessionStorage.remove('token');
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isCompact = width < 600;

    final sidebar = _Sidebar(
      selected: widget.section,
      onGoClientes: () {
        setState(() => _sidebarOpen = false);
        context.go('/clientes');
      },
      onGoCitas: () {
        setState(() => _sidebarOpen = false);
        context.go('/citas');
      },
      onLogout: () {
        setState(() => _sidebarOpen = false);
        _logout(context);
      },
    );

    return Scaffold(
      backgroundColor: const Color(0xFFE9EEF3),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Stack(
            children: [
              Row(
                children: [
                  if (!isCompact) ...[sidebar, const SizedBox(width: 18)],
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [
                          BoxShadow(
                            blurRadius: 22,
                            spreadRadius: 0,
                            offset: Offset(0, 10),
                            color: Color(0x22000000),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            height: 56,
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            decoration: const BoxDecoration(
                              color: Color(0xFFF6F8FA),
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(10),
                              ),
                            ),
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                if (isCompact) ...[
                                  InkWell(
                                    borderRadius: BorderRadius.circular(8),
                                    onTap:
                                        () =>
                                            setState(() => _sidebarOpen = true),
                                    child: const Padding(
                                      padding: EdgeInsets.all(6),
                                      child: Icon(Icons.menu, size: 22),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                ],
                                Text(
                                  _title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2B2F36),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child:
                                widget.section == DashboardSection.clientes
                                    ? ClientesPanel()
                                    : CitasPanel(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Sidebar overlay en compacto (<400)
              if (isCompact && _sidebarOpen) ...[
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () => setState(() => _sidebarOpen = false),
                    child: Container(color: Colors.black38),
                  ),
                ),
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Material(color: Colors.transparent, child: sidebar),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  final DashboardSection selected;
  final VoidCallback onGoClientes;
  final VoidCallback onGoCitas;
  final VoidCallback onLogout;

  const _Sidebar({
    required this.selected,
    required this.onGoClientes,
    required this.onGoCitas,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(22, 34, 65, 1),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            blurRadius: 16,
            offset: Offset(0, 8),
            color: Color(0x22000000),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Image.asset(
              'assets/images/citapp_icon.webp',
              height: 60,
              width: 60,
              fit: BoxFit.contain,
            ),
          ),
          const Divider(
            height: 0,
            thickness: 1,
            color: Color.fromARGB(76, 158, 158, 158),
          ),
          const SizedBox(height: 8),

          _NavItem(
            icon: Icons.group_outlined,
            label: 'Clientes',
            selected: selected == DashboardSection.clientes,
            onTap: onGoClientes,
          ),
          const SizedBox(height: 8),
          _NavItem(
            icon: Icons.event_available_outlined,
            label: 'Citas',
            selected: selected == DashboardSection.citas,
            onTap: onGoCitas,
          ),

          const Spacer(),

          _NavItem(
            icon: Icons.logout_outlined,
            label: 'Salir',
            selected: false,
            onTap: onLogout,
          ),

          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg =
        selected
            ? const Color.fromARGB(255, 105, 130, 165)
            : Colors.transparent;
    final fg = selected ? Colors.white : const Color(0xFFB8C3D2);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: SizedBox(
              width: 80,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: fg, size: 34),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    style: TextStyle(
                      color: fg,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
