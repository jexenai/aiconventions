---
paths:
  - "**/*.java"
  - "**/*.sql"
  - "**/db/{migration,changelog}/**"
---
# Java: Oracle 19c

- Identificadores con `GenerationType.SEQUENCE` y una secuencia explícita.
- Oracle 19c no tiene tipo `BOOLEAN` en SQL: mapea a `NUMBER(1)` o
  `CHAR(1)` con un convertidor.
- Una lista `IN` admite como máximo 1000 elementos (ORA-01795): divide la
  consulta.
- H2 no reproduce el dialecto de Oracle 19c. Las consultas nativas y las
  migraciones se prueban contra Oracle, por ejemplo con Testcontainers.
