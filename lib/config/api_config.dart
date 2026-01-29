class APIconfig {
  static const String baseUrl = "https://wapi.cerobits.com";

  // ---------- Auth ----------
  static const String login = "$baseUrl/auth/login";

  // ---------- Clientes ----------
  static const String clientes = "$baseUrl/clientes";
  static String clienteById(int id) => "$baseUrl/clientes/$id";

  static const String clientesConInactivos =
      "$baseUrl/clientes?include_inactive=true";

  // ---------- Citas ----------
  static const String citas = "$baseUrl/citas";
  static String citaById(int id) => "$baseUrl/citas/$id";
  static String citasPorEstado(String estado) =>
      "$baseUrl/citas/estado/$estado";
}
