---
name: laravel-security
description: Seguridad en Laravel 10 o superior - Sanctum (SPA y tokens), sesión, policies, validación, CSRF, CORS, cabeceras, límite de peticiones, ficheros, colas y registro de eventos de seguridad. Úsala al añadir o cambiar autenticación, autorización, endpoints expuestos o configuración de producción.
disable-model-invocation: true
---

# Seguridad en Laravel

Complementa `.claude/rules/comun/seguridad.md` y
`.claude/rules/php/seguridad.md`. Aquí va cómo se configura.

> Aclaración: en Laravel 10 el *middleware* y los límites se registran en
> `app/Http/Kernel.php` y `RouteServiceProvider`; desde Laravel 11, en
> `bootstrap/app.php` y `AppServiceProvider`. Comprueba la versión en
> `composer.json`.

## Autenticación con Sanctum

- **Vistas React con Inertia:** no necesitan Sanctum. Las rutas van en
  `routes/web.php` con el guard de sesión `web`, y el *middleware* `web` ya
  aplica la sesión y el CSRF. Añade Sanctum solo si además hay clientes
  externos.
- **SPA React en el mismo dominio que consume una API REST:** Sanctum en
  modo SPA con sesión. El frontend pide antes `/sanctum/csrf-cookie`, y las
  rutas de la API usan `auth:sanctum` con el *middleware* de estado. Declara
  los dominios en `SANCTUM_STATEFUL_DOMAINS`.
- **Clientes externos:** tokens con capacidades y caducidad.

```php
$token = $user->createToken('integracion', ['pedidos:leer'])->plainTextToken;

Route::middleware(['auth:sanctum', 'abilities:pedidos:leer'])
    ->get('/pedidos', [PedidoController::class, 'index']);
```

- `'expiration'` en `config/sanctum.php`; `null` significa que no caducan.
- Regenera la sesión al iniciar sesión (`$request->session()->regenerate()`)
  e invalídala al cerrarla (`invalidate()` y `regenerateToken()`).
- Cookies de sesión `secure`, `http_only` y `same_site` en
  `config/session.php`.

## Autorización

```php
final class PedidoPolicy
{
    public function update(User $user, Pedido $pedido): bool
    {
        return $pedido->user_id === $user->id;
    }
}

// Controlador
$this->authorize('update', $pedido);

// Ruta
Route::put('/pedidos/{pedido}', ...)->middleware('can:update,pedido');
```

- Una *policy* por modelo, registrada o descubierta por convención.
- `authorize()` del `FormRequest` para la autorización ligada a la petición.
- `Gate::before()` para superadministradores solo si es una decisión
  explícita del proyecto.
- En la API, un recurso ajeno responde 403 o 404, nunca los datos.

## Modelos

- `$hidden` para contraseñas, tokens y secretos de doble factor.
- Contraseñas con `Hash::make()` o el cast `'password' => 'hashed'`; nunca
  `md5()` ni `sha1()`. Casts `'encrypted'` o `'encrypted:array'` para datos
  sensibles en reposo.
- `$request->safe()->only([...])` cuando solo parte de lo validado debe
  llegar al modelo.

## Salida en JavaScript

En Blade, los datos para scripts van con `@js($datos)`, no con
`{{ json_encode(...) }}`. Si hay que permitir HTML de usuario, sanea con una
lista blanca (HTMLPurifier) antes de guardarlo o de mostrarlo.

## CSRF y CORS

- Excluye de CSRF solo rutas con otra verificación, como *webhooks*
  firmados; nunca `api/*` en bloque si hay rutas con sesión.
- `config/cors.php`: `allowed_origins` explícitos desde el entorno y
  `supports_credentials => true` solo si se usa Sanctum en modo SPA.

## Límite de peticiones

```php
RateLimiter::for('login', fn (Request $request) =>
    Limit::perMinute(5)->by($request->input('email').'|'.$request->ip()));
```

Aplícalo con `throttle:login` en el inicio de sesión, la recuperación de
contraseña y los envíos de correo. Configura `TrustProxies` solo con las IP
del proxy: con `*`, cualquiera falsifica la IP de origen.

## Cabeceras y producción

- *Middleware* propio o del servidor con `X-Content-Type-Options: nosniff`,
  `Referrer-Policy`, `Content-Security-Policy` y
  `frame-ancestors 'none'`.
- HTTPS forzado (`URL::forceScheme('https')` en producción o en Apache).
- `php artisan config:cache` en el despliegue; `APP_KEY` definida y nunca
  compartida entre entornos.
- `APP_DEBUG=false` en producción: con `true`, los errores muestran trazas y
  configuración.

## Ficheros

- Reglas `file`, `mimes`, `extensions` y `max` (y `dimensions` en
  imágenes).
- Guárdalos con nombre generado y fuera de `public/`, salvo que deban ser
  públicos.
- Documentos privados en el disco `local`, servidos con una ruta que
  autoriza, o con `Storage::temporaryUrl()` si el disco lo admite.

## Colas

- `ShouldBeEncrypted` en *jobs* con datos sensibles.
- Pasa identificadores, no modelos con datos sensibles serializados.

## Registro de eventos de seguridad

Canal propio (`Log::channel('security')`) para inicios de sesión fallidos,
cambios de rol y accesos denegados, con usuario e IP, y sin contraseñas ni
tokens.

## Dependencias

`composer audit` en CI. `composer.lock` versionado y `composer update` solo
de forma deliberada, nunca en el despliegue.
