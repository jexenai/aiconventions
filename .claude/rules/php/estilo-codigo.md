---
paths:
  - "**/*.php"
---
# PHP: estilo de código

- PSR-12 con `vendor/bin/pint`. Si hay PHPStan o Larastan, el código nuevo no
  añade errores al nivel configurado.
- Tipos en parámetros, retornos y propiedades. `enum` en lugar de constantes
  sueltas, promoción de propiedades en el constructor y `match` en lugar de
  `switch`.
- `declare(strict_types=1);` solo si el proyecto ya lo usa: Laravel no lo
  incluye por defecto.

> Aclaración: comprueba la versión mínima de PHP en `composer.json` antes de
> usar características recientes, como las clases `readonly` de PHP 8.2.

- Nombres de Laravel: clases en `PascalCase`, métodos y variables en
  `camelCase`, modelos en singular (`Pedido`) y tablas en plural
  `snake_case` (`pedidos`). Sufijos `*Controller`, `*Request`, `*Resource` y
  `*Policy`.
- Sin `dd()`, `dump()`, `var_dump()` ni `die()`.
- Lo no previsto lo gestiona el manejador de excepciones de Laravel; no lo
  captures en cada controlador.
- Logs con `Log::` y contexto.
