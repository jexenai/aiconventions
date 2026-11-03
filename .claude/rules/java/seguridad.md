---
paths:
  - "**/*.java"
  - "**/application*.yml"
  - "**/application*.yaml"
  - "**/application*.properties"
---
# Java: seguridad

Al crear o cambiar la configuración de Spring Security (cadena de filtros,
autenticación, CSRF, CORS, cabeceras o sesión), lee antes
`.claude/skills/springboot-security/SKILL.md`, si existe.

- `@Valid` en todo `@RequestBody` y restricciones (`required`,
  `maxLength`, `pattern`...) en el contrato OpenAPI, que el generador
  traslada a los DTO como Bean Validation.
- Parámetros enlazados también en `@Query(nativeQuery = true)`: `:param` en
  JPQL y `?` en `JdbcTemplate`.
- SQL con condiciones dinámicas: los fragmentos (columnas, `WHERE`, `AND`,
  `ORDER BY`) salen solo de literales del código o de una lista blanca, y
  todos los valores van como parámetros enlazados. Si el proyecto usa Sonar,
  avisa de estos casos (`java:S2077`); si cumplen lo anterior, se marcan en
  Sonar como falso positivo con ese motivo.
- No deserialices objetos Java nativos (`ObjectInputStream`) de fuentes
  externas.
- Protege las operaciones sensibles con `@PreAuthorize`.
- Nunca `e.getMessage()` ni trazas en las respuestas.
