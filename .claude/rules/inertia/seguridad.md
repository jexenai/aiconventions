---
paths:
  - "**/app/Http/Controllers/**/*.php"
  - "**/app/Http/Middleware/HandleInertiaRequests.php"
---
# Inertia: seguridad

- Las props son públicas: en la primera carga van incrustadas en el HTML
  (`data-page`) y después en las respuestas XHR. No pases nada que el
  usuario no pueda ver, ni modelos enteros que arrastren columnas nuevas.
- En `share()`, del usuario solo los campos que pinta la interfaz (nombre,
  permisos calculados), nunca el modelo completo.
- Autoriza en el controlador antes de `Inertia::render`. Los permisos que
  se pasan como props (`can`) solo deciden qué se muestra; no sustituyen la
  *policy* en la acción.
- Sesión del guard `web` y CSRF del *middleware* `web`: no añadas Sanctum
  para las propias páginas.
