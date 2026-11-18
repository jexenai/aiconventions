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
- Sin `console.log` ni código de depuración. Formato y lint con las
  herramientas del proyecto (ESLint y Prettier, o el `check` del kit de
  Laravel), si están configuradas.
- Promesa que se lanza a propósito sin esperarla (p. ej. `invalidateQueries`
  dentro de `onSuccess`, para que la mutación no espere al refresco): márcala
  con `void`. Sonar avisa si no (`javascript:S9383`). Si el resultado importa,
  devuélvela o usa `await`.
- Un fichero de componentes solo exporta componentes: las variantes
  (`cva`), constantes y funciones auxiliares que no se importen desde fuera
  no se exportan, y las que sí, van a su propio fichero
  (`react/only-export-components`, si el linter del proyecto la incluye).

## En ficheros `.ts` y `.tsx`

- Tipa las props y los retornos de las funciones exportadas.
- Nada de `any`: usa `unknown` y estrecha el tipo, o define el tipo real.
- `interface` para props y objetos extensibles; `type` para uniones y tipos
  derivados.
