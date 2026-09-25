---
paths:
  - "**/*.{test,spec}.{js,jsx,ts,tsx}"
  - "**/__tests__/**/*.{js,jsx,ts,tsx}"
  - "**/{vitest,playwright}.config.{js,ts}"
---
# React: pruebas

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
- Extremo a extremo con Playwright; al escribirlas, lee antes
  `.claude/skills/e2e-testing/SKILL.md`, si existe.

> Aclaración: en Laravel con vistas React, las pruebas de extremo a extremo
> son las únicas que recorren backend y frontend juntos. Con Inertia, el
> contrato entre controlador y página se prueba sin navegador con
> `assertInertia` (`.claude/rules/inertia/pruebas.md`, si existe).
