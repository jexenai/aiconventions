---
paths:
  - "**/*.{js,jsx,ts,tsx}"
---
# React: patrones

> Aclaración: `useActionState`, `useOptimistic` y las *actions* de
> formulario son de React 19. Úsalos solo si `package.json` tiene React 19 o
> superior.

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
  `fetch` dentro de `useEffect`, y las llamadas HTTP van en un módulo de API.
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
