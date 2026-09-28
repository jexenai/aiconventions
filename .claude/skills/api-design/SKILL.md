---
name: api-design
description: Convenciones de diseño de APIs REST en Spring Boot y Laravel - URL, métodos, códigos de estado, formato de respuestas y errores, paginación, filtros, versionado y cambios compatibles.
disable-model-invocation: true
---

# Diseño de APIs REST

Cómo debe ser un endpoint. El proceso para cambiar un contrato compartido
con el frontend está en la skill `contract-first`, si existe. Las decisiones propias
del proyecto (prefijo, formato de error, nombres de campos, paginación) se
registran en la sección "API" de `.ai/project/development.md` y prevalecen
sobre esta guía. Si están `[POR DEFINIR]`, sigue lo que ya hacen los
endpoints existentes; si no hay ninguno, propón la decisión antes de
implementar.

## URL

- Sin prefijo ni versión: la ruta empieza por el recurso (`/pedidos`, no
  `/api/pedidos` ni `/api/v1/pedidos`). El nombre de la aplicación lo añade el
  servidor como contexto del despliegue. En Laravel, `routes/api.php` añade
  `/api` por defecto: quítalo con `apiPrefix: ''` en `withRouting()` de
  `bootstrap/app.php`.
- Excepción: si la API comparte origen con páginas servidas por la misma
  aplicación (páginas de Inertia, una SPA servida por Laravel con una ruta
  comodín en `routes/web.php` o una SPA en `static/` del mismo WAR), sus
  rutas chocarían con las de las páginas (`GET /pedidos` sería a la vez la
  pantalla y el listado JSON). En ese caso, mantén un prefijo (`/api`), sin
  versión, y regístralo en la sección "API" de `development.md`.
- Ningún recurso puede llamarse como una ruta técnica de la raíz (contrato
  OpenAPI, Swagger UI, Actuator).
- Recursos en plural, minúsculas y `kebab-case`: `/pedidos`,
  `/lineas-pedido`. Sin verbos en la ruta.
- Relaciones de propiedad como subrecurso: `/clientes/{id}/pedidos`.
  No más de un nivel de anidamiento.
- Acciones que no son CRUD, como verbo tras el recurso y con `POST`:
  `/pedidos/{id}/cancelar`.
- Filtros, orden y búsqueda en parámetros de consulta, nunca en la ruta.

## Métodos y códigos

| Método | Uso | Respuesta correcta |
| ------ | --- | ------------------ |
| `GET` | Leer; sin efectos | 200 |
| `POST` | Crear o lanzar una acción | 201 con cabecera `Location` al crear; 200 o 202 en acciones |
| `PUT` | Sustituir entero | 200 con el recurso o 204 |
| `PATCH` | Modificar en parte | 200 con el recurso |
| `DELETE` | Borrar | 204 |

| Error | Cuándo |
| ----- | ------ |
| 400 | Petición mal formada (JSON inválido, tipo incorrecto) |
| 401 | Sin autenticar o con credenciales no válidas |
| 403 | Autenticado sin permiso |
| 404 | No existe, o existe pero es ajeno y no debe revelarse |
| 409 | Conflicto de estado: duplicado, versión obsoleta (`@Version`), transición no permitida |
| 422 | Datos bien formados pero no válidos (validación) |
| 429 | Límite de peticiones, con `Retry-After` |
| 500 | Error inesperado, sin detalles internos |

Nunca 200 con un `"success": false` en el cuerpo.

## Respuestas

- Un recurso: `{ "data": { ... } }`. Una colección: `data`, más `meta` y
  `links` si está paginada. Es lo que genera `JsonResource` en Laravel; en
  Spring, define esa forma en el contrato OpenAPI y devuelve el DTO generado,
  rellenado con MapStruct.
- Nombres de campos coherentes en toda la API: `camelCase` es lo natural en
  Spring (Jackson) y `snake_case` en Laravel (Eloquent). No los mezcles.
- Fechas en ISO 8601 con zona (`2026-01-15T10:30:00Z`); importes con
  decimales exactos (`BigDecimal`, `decimal` de Eloquent), nunca `float`.
- Identificadores opacos: el cliente no debe deducir nada de ellos.

## Errores

Un único formato para toda la API, con un código estable que el cliente
pueda interpretar y, en validación, el detalle por campo.

- **Spring Boot:** `ProblemDetail` (RFC 9457), activado con
  `spring.mvc.problemdetails.enabled=true` y ampliado en el
  `@RestControllerAdvice` con un campo `code` y, en validación, `errors`.
  Spring responde 400 por defecto cuando falla `@Valid`: el advice traduce
  `MethodArgumentNotValidException` a 422, igual que Laravel, y deja el 400
  para el JSON mal formado (`HttpMessageNotReadableException`).
- **Laravel:** el formato por defecto (`message` y `errors` por campo) para
  422; para el resto, personalízalo en el manejador de excepciones si el
  proyecto necesita un `code` estable.

## Paginación

- **Por páginas** (`?page=2&size=20`): pantallas con número de página y
  volúmenes moderados. `Pageable` en Spring y `paginate()` en Laravel.
- **Por cursor** (`?after=<id>&limit=20`): volúmenes grandes, *scroll*
  infinito o exportaciones. En Oracle, `WHERE id > :ultimo ORDER BY id
  FETCH FIRST :n ROWS ONLY`; en Laravel, `cursorPaginate()`.
- Tamaño de página con máximo en el servidor, aunque lo pida el cliente.
- En Spring Boot, no serialices `PageImpl` directamente: su JSON no es
  estable entre versiones. Mapea la `Page` con MapStruct al esquema de
  paginación del contrato.

## Filtros y orden

- Igualdad: `?estado=enviado`; varios valores: `?estado=enviado,cancelado`;
  rangos: `?desde=2026-01-01&hasta=2026-01-31`.
- Orden: `?sort=-fecha,referencia` (el `-` indica descendente), siempre
  contra una lista blanca de campos.
- Búsqueda de texto libre en `?q=`.

## Versionado y compatibilidad

- Sin versión en la ruta: la API evoluciona con cambios compatibles.
- Compatibles: añadir endpoints, campos de respuesta o parámetros
  opcionales.
- Incompatibles, solo con acuerdo explícito con los clientes y despliegue
  coordinado: quitar o renombrar campos, cambiar tipos o nulabilidad, cambiar
  rutas o la autenticación. Si ambas formas deben convivir, publica un
  recurso nuevo y anuncia la retirada del antiguo con la cabecera `Sunset`.

## Antes de dar por terminado un endpoint

- [ ] URL, método y códigos según esta guía y los endpoints existentes.
- [ ] Entrada validada y errores en el formato común.
- [ ] Autenticación exigida, o marcado como público de forma explícita.
- [ ] Autorización sobre el recurso concreto, no solo el rol.
- [ ] Listados paginados con tamaño máximo.
- [ ] Sin detalles internos en errores (trazas, SQL, clases).
- [ ] Contrato OpenAPI actualizado, si el proyecto lo mantiene.
