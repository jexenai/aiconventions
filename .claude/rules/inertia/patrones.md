---
paths:
  - "**/resources/js/{Pages,pages}/**/*.{js,jsx,ts,tsx}"
  - "**/app/Http/Controllers/**/*.php"
  - "**/app/Http/Middleware/HandleInertiaRequests.php"
  - "**/routes/web.php"
---
# Inertia: patrones

En las páginas de Inertia, estas pautas prevalecen sobre las de datos y
llamadas HTTP de `.claude/rules/react/patrones.md`.

## Controlador y página

- El controlador devuelve `Inertia::render('Pedidos/Index', [...])`, y el
  nombre coincide con el fichero de `resources/js/Pages/` respetando las
  mayúsculas: Apache en Linux las distingue aunque Windows no.
- Las props son solo lo que la página pinta: arrays explícitos o
  `JsonResource`, nunca el modelo ni `toArray()`.
- Las props de la página y los tipos del componente cambian en el mismo
  cambio. En TypeScript, tipa las props de cada página con lo que envía su
  controlador.
- Datos compartidos en `HandleInertiaRequests::share()` solo si los usan
  todas las páginas (usuario autenticado, mensajes *flash*), y con *closures*
  para no calcularlos en cada petición.

## Datos y formularios

- Los datos del servidor llegan como props, no con `fetch`, axios ni
  TanStack Query desde la página. Para refrescar una parte, recarga parcial
  con `router.reload({ only: [...] })`; para props costosas, las diferidas u
  opcionales de la versión instalada de `inertiajs/inertia-laravel`.
- Formularios con `useForm` de `@inertiajs/react`. La validación la hace el
  `FormRequest`, y los errores llegan en `form.errors`.
- Tras guardar, el controlador redirige (`redirect()->route(...)` con un
  mensaje *flash*); no devuelve JSON.
- Navegación interna con `<Link>` o `router`, no con `<a>` ni
  `window.location`.
- Rutas de las páginas en `routes/web.php`; `routes/api.php` queda para
  clientes externos.
