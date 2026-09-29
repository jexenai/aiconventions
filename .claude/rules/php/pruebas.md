---
paths:
  - "**/tests/**/*.php"
  - "**/phpunit.xml"
  - "**/phpunit.xml.dist"
---
# PHP: pruebas

Antes de escribir o corregir una prueba, lee
`.claude/skills/laravel-tdd/SKILL.md`, si existe.

- PHPUnit, o Pest si el proyecto ya lo usa; no mezcles los dos.
- Tres carpetas: `tests/Unit` sin arrancar el framework ni acceder a base de
  datos (validadores cuyas reglas no consultan la base, *enums* y lógica
  pura); `tests/Feature`, la carpeta de integración que crea Laravel, para
  HTTP, autorización, validación,
  persistencia y los casos de uso y validadores que usan Eloquent, que no
  se prueban sin framework ni base de datos; el
  extremo a extremo, en `tests/e2e` con Playwright
  (`.claude/skills/e2e-testing/SKILL.md`, si existe), solo para los flujos
  críticos. Cada `testsuite` de `phpunit.xml` apunta a su carpeta.
- Datos con *factories* y aislamiento con `RefreshDatabase` o
  `DatabaseTransactions`, solo contra la base de datos de pruebas de
  `development.md`.
- Lo externo, con los *fakes* de Laravel: `Http::fake()`, `Mail::fake()`,
  `Queue::fake()`, `Storage::fake()`, `Event::fake()`, `Notification::fake()`.
- En la API, `getJson()`, `postJson()`...: sin ellos, los errores 401 y 422
  redirigen en lugar de responder JSON. Con `Http::fake()`, añade
  `Http::preventStrayRequests()` para que falle toda llamada no simulada.
- Autenticación con `actingAs()` o `Sanctum::actingAs()`.
- En las pruebas de integración, comprueba el código de estado y la
  estructura (`assertJson`, `assertJsonStructure`), los casos 401/403 y 422,
  y el efecto en base de datos (`assertDatabaseHas`, `assertDatabaseMissing`).

> Aclaración: la cobertura (`--coverage`) necesita Xdebug o PCOV.
