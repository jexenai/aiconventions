---
paths:
  - "**/tests/**/*.php"
  - "**/phpunit.xml"
  - "**/phpunit.xml.dist"
---
# PHP: pruebas

- PHPUnit, o Pest si el proyecto ya lo usa; no mezcles los dos.
- `tests/Unit` sin arrancar el framework ni acceder a base de datos;
  `tests/Feature` para HTTP, autorización, validación y persistencia.
- Datos con *factories* y aislamiento con `RefreshDatabase` o
  `DatabaseTransactions`, solo contra la base de datos de pruebas de
  `development.md`.
- Lo externo, con los *fakes* de Laravel: `Http::fake()`, `Mail::fake()`,
  `Queue::fake()`, `Storage::fake()`, `Event::fake()`, `Notification::fake()`.
- En la API, `getJson()`, `postJson()`...: sin ellos, los errores 401 y 422
  redirigen en lugar de responder JSON. Con `Http::fake()`, añade
  `Http::preventStrayRequests()` para que falle toda llamada no simulada.
- Autenticación con `actingAs()` o `Sanctum::actingAs()`.
- En las pruebas de *feature*, comprueba el código de estado y la estructura
  (`assertJson`, `assertJsonStructure`), los casos 401/403 y 422, y el efecto
  en base de datos (`assertDatabaseHas`, `assertDatabaseMissing`).

> Aclaración: la cobertura (`--coverage`) necesita Xdebug o PCOV.
