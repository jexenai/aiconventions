---
paths:
  - "**/resources/js/{pages,features,layouts}/**/*.{js,jsx,ts,tsx}"
  - "**/app/Http/Controllers/**/*.php"
  - "**/app/Http/Middleware/HandleInertiaRequests.php"
  - "**/routes/web.php"
---
# Inertia: patrones

En las páginas de Inertia, estas pautas prevalecen sobre las de datos y
llamadas HTTP de `.claude/rules/react/patrones.md`.

## Carpetas

Sustituyen a las de la SPA de `react/patrones.md`:

| Carpeta | Contenido |
| ------- | --------- |
| `resources/js/pages/{entidades}` | Una página por ruta, con carpetas y ficheros en minúsculas y `kebab-case`: `pages/pedidos/index.tsx` |
| `resources/js/features/{entidades}/components`, `.../hooks` | Componentes y *hooks* propios de la entidad, que usan sus páginas |
| `resources/js/components`, `resources/js/hooks` | Lo compartido por varias entidades |
| `resources/js/layouts` | *Layouts* de las páginas |

No hay carpetas `api` ni `validator`: los datos llegan como props y la
validación la hace el backend.

## Controlador y página

- El controlador devuelve `Inertia::render('pedidos/index', [...])`, y el
  nombre coincide con el fichero de `resources/js/pages/`, todo en
  minúsculas: Apache en Linux distingue mayúsculas aunque Windows no.
- Las props son solo lo que la página pinta: arrays explícitos o
  `JsonResource`, nunca el modelo ni `toArray()`.
- Las props de la página y los tipos del componente cambian en el mismo
  cambio. En TypeScript, tipa las props de cada página con lo que envía su
  controlador.
- Datos compartidos en `HandleInertiaRequests::share()` solo si los usan
  todas las páginas (usuario autenticado, mensajes *flash*), y con
  *closures*: así no se calculan en las recargas parciales que no los piden.
  En una visita completa se calculan siempre, de modo que deben ser baratos.

## Datos y formularios

- Los datos del servidor llegan como props, no con `fetch`, axios ni
  TanStack Query desde la página. Para refrescar una parte, recarga parcial
  con `router.reload({ only: [...] })`; para props costosas, las diferidas u
  opcionales de la versión instalada de `inertiajs/inertia-laravel`.
- Formularios con el componente `<Form>` de `@inertiajs/react`, que es el
  que usa el kit de Laravel, y con `useForm` cuando haga falta manejar el
  estado del formulario desde el código (campos dependientes, pasos,
  envíos programados). Si la versión instalada no trae `<Form>`, `useForm`.
  En un proyecto que ya usa uno, no mezcles sin motivo. La validación la
  hace el `FormRequest`, y los errores llegan en `errors`.
- Tras guardar, el controlador redirige (`redirect()->route(...)` con un
  mensaje *flash*); no devuelve JSON.
- Navegación interna con `<Link>` o `router`, no con `<a>` ni
  `window.location`.
- Rutas de las páginas en `routes/web.php`; `routes/api.php` queda para
  clientes externos.
