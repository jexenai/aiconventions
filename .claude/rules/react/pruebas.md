---
paths:
  - "**/*.{test,spec}.{js,jsx,ts,tsx}"
  - "**/__tests__/**/*.{js,jsx,ts,tsx}"
  - "**/{vitest,playwright}.config.{js,ts}"
---
# React: pruebas

Antes de escribir o corregir una prueba, lee
`.claude/skills/react-testing/SKILL.md`, si existe.

- Las pruebas de componentes viven dentro de la carpeta de las vistas
  (`src/tests/` en una SPA, `resources/js/tests/` en Laravel), salvo que
  las convenciones de `development.md` fijen otra:
  - `unit`: casos de uso de API, validadores y *hooks* sin componentes.
  - `integration`: componentes y páginas con React Testing Library.
  - `setup`: configuración de Vitest, servidor de MSW y utilidades de
    renderizado; no contiene pruebas.

  Las de extremo a extremo, en `tests/e2e` en la raíz del proyecto, con
  Playwright y solo para los flujos críticos
  (`.claude/skills/e2e-testing/SKILL.md`, si existe).

  > Aclaración: en Laravel, `tests/` de la raíz es de PHP (`tests/Unit`,
  > `tests/Integration`). En Windows, `tests/unit` y `tests/Unit` son la
  > misma carpeta: por eso las de React van dentro de `resources/js/`.

- React Testing Library con el ejecutor del proyecto: con Vite, lo natural
  es Vitest; si ya hay Jest, sigue con Jest. La red se simula con MSW o con
  un doble del módulo de API. MSW con `onUnhandledRequest: "error"`; con
  TanStack Query, un `QueryClient` nuevo y sin reintentos en cada prueba.
- Prueba lo que el usuario ve y hace, no la implementación: nada de
  aserciones sobre estado interno, props de hijos o qué *hooks* se llamaron.
- Busca elementos en este orden: `getByRole`, `getByLabelText`, `getByText`
  y, como último recurso, `getByTestId`.
- Interacción con `userEvent`, no con `fireEvent`; lo asíncrono con
  `findBy*` o `waitFor`.
- *Hooks* propios con `renderHook`. Sin *snapshots* de componentes grandes:
  se aceptan sin revisarlos y no dicen qué se rompió.

> Aclaración: en Laravel con vistas React, las pruebas de extremo a extremo
> son las únicas que recorren backend y frontend juntos. Con Inertia, el
> contrato entre controlador y página se prueba sin navegador con
> `assertInertia` (`.claude/rules/inertia/pruebas.md`, si existe).
