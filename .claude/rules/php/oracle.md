---
paths:
  - "**/*.php"
  - "**/*.sql"
---
# PHP: Oracle 19c con yajra/laravel-oci8

- Nada de SQL ni funciones propias de MySQL o PostgreSQL.
- Oracle 19c no tiene tipo `BOOLEAN` en SQL: guarda 0/1 y declara el `cast`
  en el modelo.
- Una lista `IN` admite como máximo 1000 elementos (ORA-01795): divide
  `whereIn` en lotes.
- SQLite en memoria no reproduce Oracle 19c. Lo que dependa de su SQL,
  incluidas las migraciones, se prueba contra Oracle.
