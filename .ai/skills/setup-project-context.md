# Preparar el contexto del proyecto

Utiliza este procedimiento cuando se incorpore la plantilla a un repositorio,
se solicite completar los campos `[POR DEFINIR]` o sea necesario actualizar la
ficha de `AGENTS.md` y la documentación estable de `.ai/project/` tras cambios
estructurales importantes.

El resultado debe describir el proyecto real con evidencia suficiente, sin
convertir convenciones habituales ni preferencias del agente en decisiones del
equipo.

## Límites

- No instales dependencias, levantes servicios, conectes con bases de datos ni
  accedas a entornos externos para completar la documentación.
- No inicialices, sincronices ni archives cambios de OpenSpec. Si el usuario lo
  solicita, sigue después `.ai/project/openspec.md`.
- No modifiques código de aplicación ni configuración funcional salvo que el
  usuario amplíe expresamente el alcance. En `AGENTS.md` edita solo su ficha.
- No sobrescribas cambios ajenos ni sustituyas datos existentes sin comprobar
  que han quedado obsoletos.
- No reproduzcas secretos ni datos personales encontrados durante la revisión.

## Recopilar evidencia

1. Lee `AGENTS.md`, el `README` principal, `.ai/project/context.md` y
   `.ai/project/development.md`.
2. Comprueba si OpenSpec está inicializado buscando `openspec/config.yaml` o
   el directorio `openspec/`. Lee `.ai/project/openspec.md` solo si existe.
3. Revisa el estado de Git para distinguir el contenido existente de cambios
   locales que deban preservarse.
4. Obtén un mapa acotado del repositorio, excluyendo dependencias descargadas,
   binarios generados y resultados de compilación.
5. Consulta únicamente las fuentes necesarias para completar cada dato:
   manifiestos, archivos de bloqueo, scripts, configuración, CI, pruebas,
   contenedores, despliegue y documentación vigente.
6. Comprueba que las rutas y comandos citados existen. Distingue claramente
   entre comandos observados y comandos realmente ejecutados.

Usa primero operaciones de lectura. Solo ejecuta comprobaciones locales rápidas
y sin efectos cuando aporten evidencia necesaria, como consultar la versión de
una herramienta ya instalada.

## Resolver los campos pendientes

Clasifica cada `[POR DEFINIR]` antes de editarlo:

- **Demostrable:** complétalo a partir de una fuente verificable del repositorio.
- **Decisión de equipo:** conserva el marcador hasta que el usuario confirme la
  opción; no elijas por conveniencia ni por frecuencia en otros proyectos.
- **No aplicable:** sustitúyelo por `No aplica` y una razón breve únicamente
  cuando la ausencia pueda demostrarse o haya sido confirmada.
- **Bloqueado:** conserva el marcador y explica qué evidencia o decisión falta.

Agrupa las preguntas relacionadas para evitar interrupciones repetidas. No
detengas toda la adaptación por campos que no condicionen el resto del trabajo.

## Actualizar cada documento

- `AGENTS.md`: ficha del proyecto con propósito, tecnologías y versiones, ruta
  del código, comando de arranque y comando de pruebas habitual. Complétala
  primero; es lo mínimo para trabajar.
- `context.md`: alcance, componentes, mapa, dominio, decisiones de
  arquitectura y seguridad del sistema.
- `development.md`: comandos, convenciones de implementación, comentarios,
  pruebas y entrega.
- `openspec.md`: solo si OpenSpec está inicializado, su versión, rutas y
  estado. No lo inicialices.

Mantén cada dato en una única fuente. Enlaza documentos relacionados en lugar
de copiar reglas completas entre ellos.

## Comprobación final

1. Busca los marcadores `[POR DEFINIR]` restantes y clasifícalos en el reporte.
2. Comprueba que los enlaces y rutas locales añadidos existen.
3. Revisa que no se hayan documentado ejemplos como configuración activa.
4. Contrasta los comandos registrados con scripts, manifiestos o CI.
5. Revisa el diff para detectar datos inventados, duplicaciones y cambios fuera
   del alcance documental.

Al terminar, informa de:

- Documentos y secciones completados.
- Si OpenSpec está inicializado o no.
- Fuentes utilizadas como evidencia.
- Decisiones confirmadas por el usuario.
- Marcadores pendientes y motivo concreto.
- Comprobaciones ejecutadas y limitaciones de la revisión.
