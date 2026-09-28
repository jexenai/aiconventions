---
paths:
  - "**/*.{js,jsx,ts,tsx}"
---
# React: patrones

> Aclaración: `useActionState`, `useOptimistic` y las *actions* de
> formulario son de React 19. Úsalos solo si `package.json` tiene React 19 o
> superior.

## Carpetas

Aplica a la SPA con API REST. Con Inertia, las páginas están donde fija
`.claude/rules/inertia/patrones.md`, si existe, y la validación la hace el
`FormRequest`.

`<vistas>` es la carpeta de las vistas: `src/` en una SPA y `resources/js/`
en Laravel. Cada entidad tiene su carpeta en plural y en `kebab-case`
(`<vistas>/features/motivos-denegacion/`):

| Carpeta | Contenido |
| ------- | --------- |
| `<vistas>/features/{entidades}/api` | Un caso de uso por operación, con el nombre `Verbo+Entidad+PosibleDetalle` en `camelCase` (`crearConvocatoria.ts`, `buscarConvocatoriasConFiltros.ts`) |
| `<vistas>/features/{entidades}/hooks` | *Hooks* de la entidad (`useCrearConvocatoria`, `useConvocatorias`) |
| `<vistas>/features/{entidades}/validator` | El validador de la entidad: una función por acción (`convocatoriaValidator.ts`, con `validarCreacion`, `validarModificacion`...) |
| `<vistas>/features/{entidades}/components` | Componentes propios de la entidad |
| `<vistas>/components`, `<vistas>/hooks` | Lo compartido por varias entidades |
| `<vistas>/lib` | Cliente HTTP y sus interceptores |

Crea estas solo cuando hagan falta: `<vistas>/auth` (sesión y usuario),
`<vistas>/constants` (valores compartidos; los conjuntos cerrados, como uniones
de literales o objetos `as const`), `<vistas>/types` (tipos compartidos por
varias entidades) y guardas de ruta junto al *router*.

- Los *hooks* y módulos con lógica que no es de presentación van en la
  carpeta de su entidad.
- Cada caso de uso es breve y hace una sola cosa, con el vocabulario
  funcional del dominio (`comun/estilo-codigo.md`).
- El validador de la entidad expone una función por acción
  (`validarCreacion`, `validarModificacion`, `validarBorrado`), que recibe
  los datos del formulario y devuelve los errores por campo, componiendo
  comprobaciones privadas reutilizables cuando haga falta. Se llama al
  enviar, justo antes del caso de uso de API. Adelanta las reglas para el
  usuario, pero no sustituye la validación del backend.
- Las funciones de API y sus tipos siguen el contrato OpenAPI, si existe.

## *Hooks*

- Solo en el nivel superior del componente o de otro *hook*: nunca en
  condiciones, bucles ni tras un `return` anticipado.
- Todas las dependencias en `useEffect`, `useMemo` y `useCallback`. No
  silencies `react-hooks/exhaustive-deps`: corrige la causa.
- `useEffect` solo para sincronizar con el exterior. Lo que se calcula a
  partir de props o estado se calcula en el render, y la respuesta a un
  evento va en su manejador. Limpia lo que abras (suscripciones,
  temporizadores, `AbortController`).

## Estado y datos

- El estado, lo más cerca posible de donde se usa; súbelo solo cuando otro
  componente lo necesite. No guardes en él lo que se puede derivar.
- Context para datos globales que cambian poco (sesión, tema, idioma), no
  como sustituto general de las props.
- Con Inertia, los datos del servidor llegan como props de la página: sigue
  `.claude/rules/inertia/patrones.md`, si existe. Con una API REST, si el
  proyecto usa una librería de datos (TanStack Query, SWR), úsala en lugar de
  `fetch` dentro de `useEffect`, y las llamadas HTTP van en la carpeta `api`
  de su entidad.
- Contempla los estados de carga, error y vacío.

## Composición y rendimiento

- Composición (`children`, componentes compuestos) en lugar de cadenas largas
  de props. Separa los componentes que obtienen datos de los que solo pintan.
- Un componente pinta la interfaz. La lógica que no es de presentación
  (cálculos, reglas, transformación de datos) va en *hooks* propios o en
  módulos.
- `memo`, `useMemo` y `useCallback` solo ante un problema de rendimiento
  medido.
- `lazy()` y `Suspense` para rutas o componentes pesados; *error boundary* en
  las zonas que pueden fallar.

## Accesibilidad básica

- `<button>` para acciones (nunca un `<div>` con `onClick`) y `<a>` para
  navegar.
- Cada campo de formulario con su `<label>`, y `alt` en las imágenes
  informativas.
