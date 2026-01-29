enum EstadoCita {
  pendiente('pendiente'),
  confirmada('confirmada'),
  eliminado('rechazado');

  final String value;
  const EstadoCita(this.value);

  static EstadoCita fromString(String? raw) {
    final v = (raw ?? '').trim().toLowerCase();
    return EstadoCita.values.firstWhere(
      (e) => e.value == v,
      orElse: () => throw ArgumentError('EstadoCita no válido: "$raw"'),
    );
  }

  String toJson() => value;
}
