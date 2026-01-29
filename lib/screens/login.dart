import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:front_flutter/config/api_config.dart';
import 'package:front_flutter/utils/api_service.dart';
import 'package:front_flutter/utils/dio_client.dart';
import 'package:go_router/go_router.dart';
import 'package:universal_html/html.dart' as html;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final ApiService _api;

  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool _obscure = true;
  bool _loading = false;
  bool _hover = false;

  String? _userError;
  String? _passError;
  String? _loginError;

  @override
  void initState() {
    super.initState();
    final dioClient = DioClient(APIconfig.baseUrl);
    _api = ApiService(dioClient);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _redirectIfTokenValid();
    });
  }

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Map<String, dynamic>? _decodeJwtPayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final jsonMap = json.decode(decoded);

      if (jsonMap is Map<String, dynamic>) return jsonMap;
      return null;
    } catch (_) {
      return null;
    }
  }

  bool _isTokenValidByExp(String token) {
    final payload = _decodeJwtPayload(token);
    if (payload == null) return false;

    final exp = payload['exp'];
    if (exp is! num) return false;

    final expMs = (exp * 1000).toInt();
    final nowMs = DateTime.now().millisecondsSinceEpoch;

    return expMs > nowMs;
  }

  void _goDashboard() {
    context.go('/citas');
  }

  void _redirectIfTokenValid() {
    final token = html.window.sessionStorage['token'];
    if (token == null || token.trim().isEmpty) return;

    if (_isTokenValidByExp(token)) {
      _goDashboard();
    } else {
      html.window.sessionStorage.remove('token');
    }
  }

  Future<void> _doLogin() async {
    final username = _userCtrl.text.trim();
    final password = _passCtrl.text;

    setState(() {
      _loginError = null;
      _userError = username.isEmpty ? 'Ingrese usuario' : null;
      _passError = password.isEmpty ? 'Ingrese contraseña' : null;
    });

    if (username.isEmpty || password.isEmpty) return;

    setState(() => _loading = true);

    try {
      final token = await _api.login(username, password);
      html.window.sessionStorage['token'] = token;

      if (!mounted) return;

      if (_isTokenValidByExp(token)) {
        _goDashboard();
      } else {
        html.window.sessionStorage.remove('token');
        setState(() {
          _loginError = 'Token inválido o expirado';
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loginError = 'Usuario o contraseña incorrectos';
        _passError = 'Revisa tu contraseña';
      });
    } finally {
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit = !_loading;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/images/citapp_logo.webp', height: 150),
                const SizedBox(height: 24),

                TextField(
                  controller: _userCtrl,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Usuario',
                    errorText: _userError,
                    prefixIcon: const Icon(Icons.person_outline),
                  ),
                  onChanged: (_) {
                    if (_userError != null || _loginError != null) {
                      setState(() {
                        _userError = null;
                        _loginError = null;
                      });
                    }
                  },
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: _passCtrl,
                  obscureText: _obscure,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => canSubmit ? _doLogin() : null,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    errorText: _passError,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      tooltip: _obscure ? 'Mostrar' : 'Ocultar',
                      onPressed: () => setState(() => _obscure = !_obscure),
                      icon: Icon(
                        _obscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                  onChanged: (_) {
                    if (_passError != null || _loginError != null) {
                      setState(() {
                        _passError = null;
                        _loginError = null;
                      });
                    }
                  },
                ),

                if (_loginError != null) ...[
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _loginError!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 18),

                MouseRegion(
                  cursor:
                      canSubmit
                          ? SystemMouseCursors.click
                          : SystemMouseCursors.basic,
                  onEnter: (_) => setState(() => _hover = true),
                  onExit: (_) => setState(() => _hover = false),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      curve: Curves.easeOut,
                      decoration: BoxDecoration(
                        color: _hover ? Colors.black : Colors.black87,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: canSubmit ? _doLogin : null,
                          child: Center(
                            child:
                                _loading
                                    ? Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        SizedBox(
                                          width: 14,
                                          height: 14,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          'Ingresando...',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    )
                                    : const Text(
                                      'Iniciar sesión',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
