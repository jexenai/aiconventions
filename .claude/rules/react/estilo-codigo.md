---
paths:
  - "**/*.{js,jsx,ts,tsx}"
---
# React: estilo de código

> Aclaración: React como SPA compilada con Vite, no Next.js. Ignora Server
> Components, Server Actions y App Router.

- Solo componentes funcionales, en `PascalCase`, uno exportado por fichero y
  con las props desestructuradas en la firma. *Hooks* propios con prefijo
  `use`.
- Alias de importación del proyecto (`@/` si existe) en lugar de rutas
  relativas largas.
- Nunca mutes el estado ni las props. Si el nuevo estado depende del
  anterior, usa `setX(prev => ...)`.
- En listas, `key` estable y única; no el índice si los elementos cambian de
  orden o se eliminan.
- Sin `console.log` ni código de depuración. ESLint y Prettier si están
  configurados.

## En ficheros `.ts` y `.tsx`

- Tipa las props y los retornos de las funciones exportadas.
- Nada de `any`: usa `unknown` y estrecha el tipo, o define el tipo real.
- `interface` para props y objetos extensibles; `type` para uniones y tipos
  derivados.
