---
paths:
  - "**/*.java"
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
- H2 no reproduce el dialecto de Oracle 19c. Las consultas nativas y las
  migraciones se prueban contra Oracle, por ejemplo con Testcontainers.
