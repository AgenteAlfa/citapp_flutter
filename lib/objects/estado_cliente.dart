enum EstadoCliente {
  activo(1),
  inactivo(0);

  final int value;
  const EstadoCliente(this.value);

  static EstadoCliente fromInt(dynamic raw) {
    final v = (raw is num) ? raw.toInt() : int.tryParse(raw?.toString() ?? '');
    return EstadoCliente.values.firstWhere(
      (e) => e.value == v,
      orElse: () => throw ArgumentError('EstadoCliente no válido: "$raw"'),
    );
  }

  int toJson() => value;

  bool get isActivo => this == EstadoCliente.activo;
}
