---
paths:
  - "**/*.php"
  - "**/*.sql"
---
# PHP: Oracle 19c con yajra/laravel-oci8

- Nada de SQL ni funciones propias de un motor (MySQL, PostgreSQL ni
  SQLite): debe valer en Oracle y en la base de desarrollo.
- Oracle 19c no tiene tipo `BOOLEAN` en SQL: guarda 0/1 y declara el `cast`
  en el modelo.
- Una lista `IN` admite como máximo 1000 elementos (ORA-01795): divide
  `whereIn` en lotes.
- La cadena vacía es `NULL`: `''` se guarda y se lee como `NULL`, y
  `= ''` nunca coincide. No distingas vacío de nulo en reglas ni consultas,
  y no declares `NOT NULL` una columna de texto que admite vacío. SQLite sí
  los distingue: una prueba puede pasar ahí y fallar en Oracle.
- Las palabras reservadas no sirven como nombre de tabla o columna
  (`comment`, `level`, `size`, `date`, `number`, `mode`, `row`, `file`...):
  elige otro nombre en la migración.
- `LIKE` distingue mayúsculas y minúsculas en Oracle y no en SQLite: para
  búsquedas que no las distingan, aplica `UPPER()` o `LOWER()` a los dos
  lados.
- SQLite en memoria no reproduce Oracle 19c. Si la "Base de datos de
  pruebas" de `development.md` registra una base Oracle (se decide al
  configurar el proyecto), lo que dependa de su SQL, incluidas las
  migraciones, se prueba contra ella. Si solo registra SQLite, indica al
  entregar que ese cambio queda sin comprobar contra Oracle.
