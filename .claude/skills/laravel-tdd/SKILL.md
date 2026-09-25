---
name: laravel-tdd
description: Ejemplos de pruebas en Laravel que no están en las reglas - factories con estados y relaciones, validación y tokens en la API, ficheros subidos, respuestas externas encadenadas, comandos Artisan y entorno de phpunit.xml.
disable-model-invocation: true
---

# Pruebas en Laravel

Complementa `.claude/rules/php/pruebas.md`. Con OpenSpec, el orden de
pruebas primero lo fija `openspec/config.yaml`.

## Factories

```php
public function enviado(): static
{
    return $this->state(fn () => ['estado' => EstadoPedido::Enviado]);
}

Pedido::factory()->enviado()->for($user)->create();
User::factory()->has(Pedido::factory()->count(3))->create();
User::factory()->count(3)->sequence(['rol' => 'admin'], ['rol' => 'user'])->create();
```

Estados con nombre en lugar de repetir atributos; `make()` si no hace falta
persistir.

## API

```php
$this->actingAs($user)
    ->postJson('/api/pedidos', [])
    ->assertUnprocessable()
    ->assertJsonValidationErrors(['referencia']);

$this->withToken($user->createToken('prueba', ['pedidos:leer'])->plainTextToken)
    ->getJson('/api/pedidos')
    ->assertOk();
```

## Ficheros y servicios externos

```php
Storage::fake('local');
$this->actingAs($user)->postJson('/api/adjuntos', [
    'fichero' => UploadedFile::fake()->create('doc.pdf', 100, 'application/pdf'),
])->assertCreated();

Http::fake(['pasarela.test/*' => Http::sequence()->pushStatus(503)->push(['ok' => true])]);
```

## Comandos Artisan

```php
$this->artisan('pedidos:caducar')
    ->expectsOutputToContain('3 pedidos caducados')
    ->assertExitCode(0);
```

## Entorno

- `phpunit.xml` con `BCRYPT_ROUNDS=4`, `QUEUE_CONNECTION=sync`,
  `MAIL_MAILER=array` y la caché en `array` (`CACHE_DRIVER` en Laravel 10,
  `CACHE_STORE` desde Laravel 11).
- Una sola prueba: `php artisan test --filter=PedidoApiTest`.
- La conexión de pruebas es la de la tabla "Base de datos de pruebas" de
  `development.md`. Con Oracle, hacen falta la extensión `oci8` y el Instant
  Client en el equipo y en la imagen de CI; la skill `setup-testing` indica
  qué falta y propone el job de CI.
