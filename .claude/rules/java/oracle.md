---
paths:
  - "**/{models,repositories}/**/*.java"
  - "**/*.sql"
  - "**/db/{migration,changelog}/**"
---
# Java: Oracle 19c

- Identificadores con `@GeneratedValue(strategy = GenerationType.SEQUENCE)`,
  sin `@SequenceGenerator`: Hibernate usa la secuencia `{tabla}_seq` con un
  `allocationSize` de 50, así que la migración la crea con
  `INCREMENT BY 50`. Si no coinciden, se generan identificadores duplicados.
- Oracle 19c no tiene tipo `BOOLEAN` en SQL: mapea a `NUMBER(1)` o
  `CHAR(1)` con un convertidor.
- Una lista `IN` admite como máximo 1000 elementos (ORA-01795): divide la
  consulta.
- La cadena vacía es `NULL`: `''` se guarda y se lee como `NULL`, y
  `= ''` nunca coincide. No distingas vacío de nulo en reglas ni consultas,
  y no declares `NOT NULL` una columna de texto que admite vacío.
- Las palabras reservadas no sirven como nombre de tabla o columna
  (`comment`, `level`, `size`, `date`, `number`, `mode`, `row`, `file`...).
  Elige otro nombre para el campo; si el esquema ya existe, declara el
  nombre real (`patrones.md`).
- `LIKE` distingue mayúsculas y minúsculas: para búsquedas que no las
  distingan, aplica `UPPER()` o `LOWER()` a los dos lados.
- H2 no reproduce el dialecto de Oracle 19c. Las consultas nativas y las
  migraciones se prueban contra Oracle, por ejemplo con Testcontainers.
