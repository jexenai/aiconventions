---
paths:
  - "**/tests/**/*.php"
  - "**/src/test/**/*.java"
  - "**/*.{test,spec}.{js,jsx,ts,tsx}"
  - "**/__tests__/**/*.{js,jsx,ts,tsx}"
  - "**/phpunit.xml"
  - "**/phpunit.xml.dist"
---
# Pautas comunes de pruebas

Los comandos están en [development.md](../../../.ai/project/development.md).
Con OpenSpec, el orden de pruebas primero lo fija `openspec/config.yaml`.

- Prueba comportamiento observable, límites, errores y permisos.
- Tres carpetas de pruebas, con la ruta concreta de cada lenguaje en su
  `pruebas.md`: `unit` para la lógica aislada, `integration` para endpoints
  y acceso a datos, y `e2e` solo para los flujos críticos.
- Un comportamiento por prueba, con estructura preparar-actuar-comprobar y un
  nombre que describa el caso.
- Pruebas independientes y deterministas: sin estado compartido, sin esperas
  fijas y sin llamadas a servicios externos reales.
- Empieza por el área afectada y amplía si cambian contratos públicos, datos
  persistentes, seguridad, varias capas o dependencias.
- Una prueba automática no sustituye la revisión funcional o de dominio.
- Corrige la implementación y cambia la prueba solo si es ella la que está
  mal.

> Aclaración: el umbral de cobertura lo fija el CI del proyecto. Si no hay
> ninguno, un 80 % es orientativo.
