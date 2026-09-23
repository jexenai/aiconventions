# Plantilla de contexto para agentes de IA

Esta plantilla comparte instrucciones entre Claude Code y Codex sin cargar toda
la documentación en cada tarea. OpenSpec es opcional.

## Archivos principales

| Archivo                      | Para qué sirve                                       |
| ---------------------------- | ---------------------------------------------------- |
| `AGENTS.md`                  | Ficha del proyecto, reglas comunes y rutas de consulta |
| `.ai/project/context.md`     | Reglas, alcance, mapa, dominio y seguridad             |
| `.ai/project/development.md` | Comandos, calidad de código, pruebas y entrega         |
| `.ai/skills/README.md`       | Catálogo de procedimientos reutilizables               |

OpenSpec no tiene documento propio en la plantilla: su forma de trabajo la
define el workflow que él mismo instala. La plantilla solo aporta la decisión
de adoptarlo, en `.ai/skills/setup-openspec.md`, y la fila `Especificaciones`
de la ficha de `AGENTS.md`.

Los servidores MCP tampoco se configuran a mano: cada plantilla de stack
declara en `context.mcp` los que le corresponden, con su configuración
completa. `setup-project-context` los fusiona en el `.mcp.json` del
proyecto solo cuando el stack los declara, de modo que un backend sin interfaz
no arrastra la configuración de un catálogo de componentes.

`CLAUDE.md` importa `AGENTS.md`. No añadas imports de todos los documentos:
los detalles se consultan solo cuando la tarea los necesita.

## Integraciones nativas

| Herramienta | Skills            | Agentes           |
| ----------- | ----------------- | ----------------- |
| Claude Code | `.claude/skills/` | `.claude/agents/` |
| Codex       | `.agents/skills/` | `.codex/agents/`  |

En Codex, `.agents/` y `.codex/` no son equivalentes: la primera contiene
skills y la segunda configuración y agentes propios de Codex.

### Permisos

Estos archivos aplican controles que no dependen de que el modelo obedezca:

| Herramienta | Archivo | Control |
| ----------- | ------- | ------- |
| Claude Code | `.claude/settings.json` | Bloquea leer y editar `.env` y `.env.prod*`, editar `.env.local` y `.env.*.local`, y leer claves y certificados; pide confirmación antes de `git push` |
| Codex | `.codex/config.toml` | Limita la escritura al repositorio, desactiva la red y pide aprobación para salir del sandbox |

Codex no permite bloquear la lectura de archivos concretos. La regla de
Claude Code no cubre la lectura desde la terminal (`cat .env`). En ambos
casos, la protección definitiva está en no versionar secretos.

### Skills y agentes

- Una **skill** define un procedimiento reutilizable y es la opción normal para
  tareas como preparar contexto o crear un commit.
- Un **agente** aporta un contexto aislado, herramientas o permisos propios.
  Úsalo solo cuando ese aislamiento, especialización o paralelismo aporte valor.
- La conversación principal invoca la skill o delega en el agente. Una skill
  puede solicitar delegación cuando su procedimiento lo necesite, pero no debe
  hacerlo por defecto para tareas breves y dependientes del contexto actual.
- El commit se ejecuta directamente mediante su skill. No necesita un agente
  intermedio y nunca debe lanzarse automáticamente sin petición del usuario.

## Adaptación inicial

1. Copia la plantilla en el repositorio sin sobrescribir instrucciones
   existentes. El plugin ofrece los stacks resumidos en
   [pila_tecnologica.md](pila_tecnologica.md) y copia la plantilla elegida de
   `templates/` como `docs/stack.yaml`. Las tecnologías y versiones solo se
   mantienen en cada plantilla.
2. Ejecuta `/setup-project-context` en Claude Code o
   `$setup-project-context` en Codex. Las skills de setup solo se ejecutan al
   invocarlas: el agente no las lanza por su cuenta. En Claude Code lo fija
   `disable-model-invocation` en su `SKILL.md`; en Codex, el archivo
   `agents/openai.yaml` de cada skill.
3. Responde a las tres rondas de preguntas del guion: ficha, ejecución y
   OpenSpec. Son siempre las mismas nueve preguntas, también al repetir el
   setup; cuando un dato ya está resuelto, la pregunta lo propone como
   primera opción para confirmarlo.
4. Si eliges instalar OpenSpec, la misma ejecución continúa con
   `setup-openspec` y te pregunta las herramientas y la confirmación de la
   instalación. Revisa al final la tabla del informe, con una fila por
   pregunta y por fase.

Los campos `[POR DEFINIR]` que no afecten al trabajo actual pueden mantenerse
pendientes. No conviertas suposiciones en datos del proyecto.

### Mínimo para empezar

No es necesario completar toda la plantilla de una vez. Para comenzar con un
proyecto, basta con completar la ficha de `AGENTS.md`:

1. Su propósito principal.
2. Las tecnologías y versiones utilizadas.
3. La ruta del código de aplicación.
4. El comando para arrancarlo en local.
5. El comando de pruebas más habitual.
6. Qué tecnología renderiza sus vistas, si sirve interfaz propia.
7. Si el proyecto usa OpenSpec o no.
8. Si el proyecto usa un sistema de diseño servido por MCP o no.

La ficha está en `AGENTS.md` porque es el único archivo que todas las
herramientas cargan siempre. Completa el resto cuando una tarea necesite esa
información o ejecuta la skill `setup-project-context` para obtenerla
progresivamente.

Actualiza cada dato en su fuente correspondiente. Los detalles temporales de
un cambio pertenecen al cambio de OpenSpec, no a la documentación estable.
