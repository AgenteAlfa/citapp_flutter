import 'package:flutter/material.dart';
import 'package:front_flutter/screens/dashboard.dart';
import 'package:front_flutter/screens/login.dart';
import 'package:go_router/go_router.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, __) => const LoginPage()),
    GoRoute(
      path: '/clientes',
      builder:
          (_, __) => const DashboardShell(section: DashboardSection.clientes),
    ),
    GoRoute(
      path: '/citas',
      builder: (_, __) => const DashboardShell(section: DashboardSection.citas),
    ),
  ],
);

void main() {
  runApp(MaterialApp.router(routerConfig: router));
}
