---
paths:
  - "**/*.{js,jsx,ts,tsx}"
---
# React: seguridad

- Todo lo que va en el *bundle* es público y la autorización real la hace el
  backend. Nada de secretos en variables `VITE_`: Vite las incluye en el
  *bundle* (en Laravel con vistas React, son las del `.env` con ese
  prefijo).
- Nada de `dangerouslySetInnerHTML` con datos de usuario o de APIs. Si es
  imprescindible, sanea antes con DOMPurify.
- URL que vienen de datos en `href` o `src`: solo `https:`, `http:` o rutas
  relativas, nunca `javascript:`. Codifica la entrada con
  `encodeURIComponent` al montar URL.
- Los enlaces externos con `target="_blank"` llevan
  `rel="noopener noreferrer"`.
- Sesión en cookies `httpOnly` gestionadas por el backend, no tokens en
  `localStorage`.
- Los avisos de Sonar sobre componentes genéricos de una librería de UI
  copiada al proyecto (p. ej. shadcn/ui en `components/ui`:
  `javascript:S6850` en un encabezado sin contenido, `javascript:S6853` en una
  etiqueta sin control) son falsos positivos si el contenido o el control
  llegan por `children`, `htmlFor` o anidados desde cada uso. Se marcan en
  Sonar con ese motivo, no con `// NOSONAR`. Cualquier otro aviso se corrige
  en el código.

> Aclaración: en Laravel con vistas React y sesión de Laravel (Inertia o
> Sanctum en modo SPA), axios envía el token CSRF desde la cookie
> `XSRF-TOKEN`. No lo desactives ni lo sustituyas por uno propio.
