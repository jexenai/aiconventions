---
paths:
  - "**/tests/**/*.php"
---
# Inertia: pruebas

- Una prueba de integración por página, en `tests/Feature`, con
  `assertInertia`: comprueba el
  componente, las props que pinta y que no viajan las que no debe.

```php
$this->actingAs($user)
    ->get(route('pedidos.index'))
    ->assertInertia(fn (AssertableInertia $pagina) => $pagina
        ->component('Pedidos/Index')
        ->has('pedidos.data', 3)
        ->missing('pedidos.data.0.user.password'));
```

- Los formularios se prueban con `post()`, `put()`..., no con `postJson()`:
  el error de validación es una redirección con errores en sesión
  (`assertSessionHasErrors`), no un 422, y el éxito, `assertRedirect()`.
- Mantén activa la comprobación de que el componente existe
  (`ensure_pages_exist` en `config/inertia.php`).
- Desactiva el SSR de Inertia en las pruebas (`inertia.ssr.enabled` a
  `false` en el `TestCase` base, o con una variable de entorno en
  `config/inertia.php` fijada en `phpunit.xml`). El kit lo trae activado y,
  con `Http::preventStrayRequests()`, la llamada al servidor SSR hace que
  cada página responda 500.

> Aclaración: `assertInertia` comprueba el contrato entre el controlador y
> la página sin navegador. Las pruebas de extremo a extremo quedan para los
> flujos críticos.
