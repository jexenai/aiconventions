---
paths:
  - "**/*.java"
---
# Java: estilo de código

- `record` para DTO y objetos de valor; `switch` como expresión y *pattern
  matching* en `instanceof` en lugar del cast.

> Aclaración: los *record patterns* y el *pattern matching* en `switch` son
> de Java 21; con Java 17 no están disponibles.

- Formateo y análisis con Spotless y Checkstyle si están configurados.
- Clases, records y enums en `PascalCase`; métodos y campos en `camelCase`;
  constantes en `UPPER_SNAKE_CASE`; paquetes en minúsculas. Sufijos por rol
  (`*Controller`, `*Service`, `*Repository`, `*Mapper`, `*Exception`) y una
  clase pública por fichero.
- Campos `final` por defecto; sin *setters* salvo en entidades JPA.
- Colecciones vacías en lugar de `null`. `Optional` solo como retorno, nunca
  en campos ni parámetros, y sin `get()`: usa `orElseThrow()`, `map()` u
  `orElse()`.
- Excepciones de dominio no comprobadas y con el nombre del caso
  (`PedidoNoEncontradoException`). Al envolver una excepción, conserva la
  causa. Solo el manejador centralizado captura `Exception`.
- Logs con SLF4J y marcadores `{}`; nunca `System.out` ni
  `printStackTrace()`.
