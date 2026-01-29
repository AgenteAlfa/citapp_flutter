## Requisitos

- **Flutter SDK**: `3.29.3`
- **Dart**: `3.7.2`
- **DevTools**: `2.42.3`

# Frontend – Gestión de Clientes y Citas

Aplicación frontend desarrollada en **Flutter** para la gestión de **clientes** y **citas**, conectada a un backend REST con autenticación JWT.

El proyecto está diseñado como un **dashboard responsivo**, orientado a uso web y móvil, con operaciones CRUD completas y una interfaz clara para administración.

---

## Funcionalidades

### Clientes
- Listado de clientes
- Filtros por:
  - Clientes activos
  - Clientes inactivos
  - Todos
- Crear nuevo cliente
- Editar cliente existente
- Eliminación lógica de clientes
- Búsqueda por nombre, teléfono o email

### Citas
- Listado de citas
- Filtros por estado:
  - Pendientes
  - Confirmadas
  - Rechazadas (estado `eliminado`)
  - Todas
- Crear nuevas citas
- Editar citas
- Eliminación lógica de citas
- Asociación de citas a clientes existentes

---

## Interfaz Responsiva

La interfaz se adapta automáticamente según el ancho disponible por medio de breakpoints

## Autenticación

La aplicación utiliza autenticación **JWT (Bearer Token)**.
Usuario: admin
Contraseña: admin123


El token JWT se almacena en `sessionStorage` con universal html por lo que funciona en cualquier plataforma y se envía automáticamente en cada request mediante **Dio Interceptors**.

---

## Conexión a la API

El frontend está conectado al backend en:
https://wapi.cerobits.com
<br>
Esta conexion abierto al consumo, solo requiere sus credenciales de acceso

## Configuración ubicada en:
 lib/config/api_config.dart
