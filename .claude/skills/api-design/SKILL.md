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

- Recursos en plural, minúsculas y `kebab-case`: `/api/v1/pedidos`,
  `/api/v1/lineas-pedido`. Sin verbos en la ruta.
- Relaciones de propiedad como subrecurso: `/api/v1/clientes/{id}/pedidos`.
  No más de un nivel de anidamiento.
- Acciones que no son CRUD, como verbo tras el recurso y con `POST`:
  `/api/v1/pedidos/{id}/cancelar`.
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
  Spring, devuelve un DTO con la misma forma.
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
  estable entre versiones. Usa un DTO propio o
  `@EnableSpringDataWebSupport(pageSerializationMode = VIA_DTO)`.

## Filtros y orden

- Igualdad: `?estado=enviado`; varios valores: `?estado=enviado,cancelado`;
  rangos: `?desde=2026-01-01&hasta=2026-01-31`.
- Orden: `?sort=-fecha,referencia` (el `-` indica descendente), siempre
  contra una lista blanca de campos.
- Búsqueda de texto libre en `?q=`.

## Versionado y compatibilidad

- Versión en la ruta (`/api/v1`) desde el primer endpoint público.
- Compatibles, sin nueva versión: añadir endpoints, campos de respuesta o
  parámetros opcionales.
- Incompatibles, con nueva versión o acuerdo explícito con los clientes:
  quitar o renombrar campos, cambiar tipos o nulabilidad, cambiar rutas o la
  autenticación.
- Como mucho dos versiones activas; anuncia la retirada con la cabecera
  `Sunset`.

## Antes de dar por terminado un endpoint

- [ ] URL, método y códigos según esta guía y los endpoints existentes.
- [ ] Entrada validada y errores en el formato común.
- [ ] Autenticación exigida, o marcado como público de forma explícita.
- [ ] Autorización sobre el recurso concreto, no solo el rol.
- [ ] Listados paginados con tamaño máximo.
- [ ] Sin detalles internos en errores (trazas, SQL, clases).
- [ ] Contrato OpenAPI actualizado, si el proyecto lo mantiene.
