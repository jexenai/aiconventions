---
name: frontend-a11y
description: Accesibilidad en componentes React - formularios con etiquetas y errores asociados, HTML semántico, ARIA, teclado, foco en diálogos, contenido dinámico, imágenes e iconos y movimiento reducido. Úsala al crear o cambiar formularios o componentes interactivos (diálogos, menús, pestañas, desplegables).
disable-model-invocation: true
---

# Accesibilidad en React

Complementa `.claude/rules/react/patrones.md`, que ya pide `<button>` para
acciones, `<a>` para navegar, `<label>` en cada campo y `alt` en imágenes
informativas. Si el proyecto tiene un sistema de diseño, sus componentes ya
resuelven parte de esto: úsalos antes de construir uno propio.

## Formularios

```tsx
<label htmlFor={id}>
  Email <span aria-hidden="true">*</span>
</label>
<input
  id={id}
  type="email"
  required
  autoComplete="email"
  aria-invalid={Boolean(error)}
  aria-describedby={error ? `${id}-error` : undefined}
/>
{error && <p id={`${id}-error`} role="alert">{error}</p>}
```

- Identificadores con `useId()`, no escritos a mano: se repiten si el
  componente aparece dos veces.
- El asterisco visual va con `aria-hidden`; lo obligatorio lo comunica
  `required`.
- El error se asocia con `aria-describedby` y se anuncia con `role="alert"`.
- `autoComplete` en datos personales y credenciales.
- `placeholder` no sustituye a la etiqueta.
- Al enviar con errores, lleva el foco al primer campo inválido.

## ARIA

ARIA solo cuando no hay un elemento nativo equivalente. Un ARIA incorrecto
es peor que ninguno.

- Botón solo con icono: `aria-label` en el botón y `aria-hidden` en el icono.
- `aria-labelledby` si ya hay un texto visible que sirve de nombre.
- Contenido que se despliega: `aria-expanded` y `aria-controls` en el botón
  que lo controla.
- Nunca `aria-hidden` sobre un elemento que puede recibir foco.
- Nada de `role="button"` en un `<div>`: usa `<button>`.

## Teclado

- Todo lo que se usa con ratón se usa con teclado, y el foco es visible (no
  quites el `outline` sin sustituirlo).
- Nunca `tabIndex` positivo; `0` para hacer enfocable un elemento propio y
  `-1` para mover el foco por código.
- Componentes compuestos (menús, pestañas, listas desplegables): flechas para
  moverse dentro, `Tab` para salir y `Escape` para cerrar, según los
  patrones de ARIA Authoring Practices. Mejor una librería probada (Radix,
  React Aria, Headless UI) que una implementación propia.

## Diálogos

- Al abrir, el foco pasa al diálogo; al cerrar, vuelve al elemento que lo
  abrió.
- El foco no sale del diálogo mientras está abierto (`<dialog>` con
  `showModal()` lo hace de forma nativa, o una librería de *focus trap*).
- `aria-modal="true"`, título con `aria-labelledby` y cierre con `Escape`.

## Contenido dinámico

- Mensajes de estado (guardado, resultados de búsqueda) en una región
  `role="status"` que exista antes de cambiar su texto.
- `role="alert"` solo para errores que requieren atención inmediata.
- Al cambiar de ruta en la SPA, mueve el foco al título de la nueva página
  y actualiza `document.title`.

## Imágenes e iconos

- Imagen decorativa: `alt=""`. Informativa: `alt` que describe lo que
  aporta, no "imagen de".
- Iconos SVG decorativos con `aria-hidden="true"`.

## Movimiento y color

- Respeta `prefers-reduced-motion`, preferiblemente en CSS con
  `@media (prefers-reduced-motion: reduce)`.
- El color no es el único indicador de un estado o error: añade texto o
  icono. Contraste mínimo 4,5:1 en texto normal (WCAG AA).

## Comprobación

- `eslint-plugin-jsx-a11y` en el lint, si el proyecto lo admite.
- axe en las pruebas de componentes (ver la skill `react-testing`).
- Recorrido manual con teclado de los flujos nuevos.
