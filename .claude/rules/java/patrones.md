---
paths:
  - "**/*.java"
---
# Java: patrones de Spring Boot

Al crear un endpoint o cambiar uno ya expuesto, lee antes
`.claude/skills/api-design/SKILL.md`, si existe. Al crear o cambiar una
entidad, un repositorio o una consulta, lee antes
`.claude/skills/jpa-patterns/SKILL.md`, si existe.

## Capas

- `Controller`: HTTP, validación y conversión a DTO con el mapper de
  MapStruct, sin lógica de negocio.
- `Service`: lógica de negocio y `@Transactional` (con `readOnly = true` en
  las lecturas). Nunca transacciones en controladores.
- Un `Service` por funcionalidad del dominio (`ClienteService`: alta, baja y
  consulta de clientes), sin mezclar funcionalidades distintas. Si una
  operación solo guarda lo validado, sin reglas de negocio, no crees un
  servicio que se limite a reenviarla al repositorio.
- `Repository`: acceso a datos, sin reglas de negocio.
- La API devuelve DTO generados del contrato y rellenados con MapStruct
  (`datos.md`), nunca entidades JPA ni proyecciones.
- Errores centralizados en `@RestControllerAdvice`, que traduce cada
  excepción de dominio a su código HTTP.

## Inyección y configuración

- Inyección por constructor con campos `final`; nunca `@Autowired` en campos.
- Configuración en clases `@ConfigurationProperties` tipadas, no en `@Value`
  repartidos.

## JPA

- Relaciones `LAZY`. Carga lo necesario con `JOIN FETCH` o `@EntityGraph`
  para evitar consultas N+1.
- Listados paginados con `Pageable` y `Page<T>`.
- `CascadeType.ALL` y `orphanRemoval` solo si el hijo no existe sin el padre.
