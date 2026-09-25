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

- `@Valid` en todo `@RequestBody` y restricciones de Bean Validation
  (`@NotBlank`, `@Size`...) en los DTO.
- Parámetros enlazados también en `@Query(nativeQuery = true)`: `:param` en
  JPQL y `?` en `JdbcTemplate`.
- No deserialices objetos Java nativos (`ObjectInputStream`) de fuentes
  externas.
- Protege las operaciones sensibles con `@PreAuthorize`.
- Nunca `e.getMessage()` ni trazas en las respuestas.
