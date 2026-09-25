---
paths:
  - "**/*.{java,php,sql}"
---
# Pautas comunes de seguridad en el backend

- Valida la entrada y comprueba la autorización en el límite de confianza,
  incluido que el recurso pertenece al usuario, no solo que está autenticado.
- Credenciales, claves y tokens fuera del código y de la configuración
  versionada: variables de entorno o gestor de secretos.
- Consultas con parámetros enlazados. Nunca concatenes entrada externa en
  SQL, comandos del sistema ni rutas de fichero. Para ordenaciones o columnas
  dinámicas, usa una lista blanca de valores permitidos.
- Escapa la salida según su destino (HTML, URL, JSON).
- En aplicaciones con sesión, mantén la protección CSRF en las operaciones
  que cambian datos.
- Limita la frecuencia de los endpoints sensibles o costosos, como el inicio
  de sesión o los envíos de correo.
- Al cliente, mensajes de error genéricos; el detalle va al log del servidor,
  sin secretos ni datos personales.

> Aclaración: solo se carga con código de backend. El frontend tiene sus
> propias pautas en `.claude/rules/react/seguridad.md`.
