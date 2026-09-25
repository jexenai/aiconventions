# Plantilla de contexto para agentes de IA

Esta plantilla comparte instrucciones entre Claude Code y Codex sin cargar toda
la documentación en cada tarea. OpenSpec es opcional.

Este documento explica cómo usarla. Por qué está organizada así y cómo
ampliarla sin romperla está en [docs/diseno.md](docs/diseno.md).

## Archivos principales

| Archivo                      | Para qué sirve                                       |
| ---------------------------- | ---------------------------------------------------- |
| `AGENTS.md`                  | Ficha del proyecto, reglas comunes y rutas de consulta |
| `.ai/project/architecture.md` | Reglas, alcance, mapa, dominio y seguridad             |
| `.ai/project/development.md` | Comandos, base de datos de pruebas, convenciones propias, API, sistema de diseño y entrega |
| `.claude/rules/`             | Pautas de código, seguridad y pruebas (solo Claude Code) |
| `.ai/skills/README.md`       | Catálogo de procedimientos reutilizables               |

`CLAUDE.md` importa `AGENTS.md`. No añadas imports de todos los documentos:
los detalles se consultan solo cuando la tarea los necesita.

## Integraciones nativas

| Herramienta | Skills            | Agentes           | Reglas de código |
| ----------- | ----------------- | ----------------- | ---------------- |
| Claude Code | `.claude/skills/` | `.claude/agents/` | `.claude/rules/` |
| Codex       | `.agents/skills/` | `.codex/agents/`  | No disponible    |

En Codex, `.agents/` y `.codex/` no son equivalentes: la primera contiene
skills y la segunda configuración y agentes propios de Codex.

### Permisos

Estos archivos aplican controles que no dependen de que el modelo obedezca:

| Herramienta | Archivo | Control |
| ----------- | ------- | ------- |
| Claude Code | `.claude/settings.json` | Bloquea leer y editar `.env` y `.env.prod*`, editar `.env.local` y `.env.*.local`, y leer claves y certificados; pide confirmación antes de `git push` y de las migraciones y los comandos `db:` de Artisan |
| Codex | `.codex/config.toml` | Limita la escritura al repositorio, desactiva la red y pide aprobación para salir del sandbox |

Codex no permite bloquear la lectura de archivos concretos. La regla de
Claude Code no cubre la lectura desde la terminal (`cat .env`). En ambos
casos, la protección definitiva está en no versionar secretos.

### Memoria automática

`.claude/settings.json` desactiva la memoria automática de Claude Code
(`autoMemoryEnabled: false`). Así, Claude no guarda notas por su cuenta en la
carpeta personal de cada desarrollador y todos trabajan con las mismas
instrucciones. Si una corrección es una convención del equipo, va a
`.ai/project/development.md` o a `.claude/rules/`, donde se revisa y llega a
todos.

Quien quiera la memoria para sí puede reactivarla en su
`.claude/settings.local.json`, que no se versiona:

```json
{ "autoMemoryEnabled": true }
```

## Adaptación inicial

1. Copia la plantilla en el repositorio sin sobrescribir instrucciones
   existentes. El plugin ofrece los stacks resumidos en
   [pila_tecnologica.md](pila_tecnologica.md) y copia la plantilla elegida de
   `templates/` como `docs/stack.yaml`. Las tecnologías y versiones solo se
   mantienen en cada plantilla.
2. Ejecuta `/setup-project-context` en Claude Code o
   `$setup-project-context` en Codex. Las skills de setup solo se ejecutan al
   invocarlas: el agente no las lanza por su cuenta.
3. Responde a las tres rondas de preguntas del guion: ficha, ejecución y
   OpenSpec. Son siempre las mismas nueve preguntas, también al repetir el
   setup; cuando un dato ya está resuelto, la pregunta lo propone como
   primera opción para confirmarlo.
4. Si eliges instalar OpenSpec, la misma ejecución continúa con
   `setup-openspec` y te pregunta las herramientas y la confirmación de la
   instalación. Revisa al final la tabla del informe, con una fila por
   pregunta y por fase.
5. Con las tecnologías, las vistas y la base de datos confirmadas, el setup
   retira lo de los stacks que no uses. La sección "Stacks" del informe
   indica qué se conservó y qué se retiró; lo que depende de una respuesta
   pendiente no se borra.
6. Si el stack declara servidores MCP (por ejemplo, el catálogo de shadcn/ui
   para las vistas React), el setup los añade a `.mcp.json`. Apruébalos en
   la primera sesión: añadirlos no los activa.
7. Si el informe deja pendientes comandos de pruebas, lint o análisis porque
   falta la herramienta (por ejemplo, Vitest o ESLint en un Laravel con vistas
   React), ejecuta `/setup-testing`. Te pregunta qué preparar, instala solo
   con tu confirmación, crea una prueba semilla por tipo y registra los
   comandos.

Los campos `[POR DEFINIR]` que no afecten al trabajo actual pueden mantenerse
pendientes. No conviertas suposiciones en datos del proyecto.

### Mínimo para empezar

No es necesario completar toda la plantilla de una vez. Para comenzar con un
proyecto, basta con completar la ficha de `AGENTS.md`:

1. Su propósito principal.
2. Las tecnologías y versiones utilizadas.
3. La ruta del código de aplicación.
4. Los comandos para arrancarlo en local, uno por parte si hay varias.
5. Los comandos de pruebas habituales, uno por parte si hay varias.
6. Qué tecnología renderiza sus vistas, si sirve interfaz propia.
7. Si el proyecto usa OpenSpec o no.
8. Si el proyecto usa un sistema de diseño servido por MCP o no.

Si las pruebas usan base de datos, completa también la tabla "Base de datos
de pruebas" de `development.md`: mientras esté pendiente, el agente no
ejecutará las pruebas que la reinician.

Actualiza cada dato en su fuente correspondiente. Los detalles temporales de
un cambio pertenecen al cambio de OpenSpec, no a la documentación estable.

## OpenSpec

OpenSpec no tiene documento propio en la plantilla: su forma de trabajo la
define el workflow que él mismo instala. La decisión de adoptarlo está en
`.ai/skills/setup-openspec.md` y queda registrada en la fila
`Especificaciones` de la ficha. Al instalarlo, `openspec/config.yaml` fija el
orden de pruebas primero en cada cambio.

## Revisores (solo Claude Code)

| Agente | Revisa |
| ------ | ------ |
| `java-reviewer` | Java y Spring Boot |
| `php-reviewer` | PHP y Laravel, también con Inertia |
| `react-reviewer` | React con Vite, también las páginas de Inertia |
| `security-reviewer` | Seguridad de cualquiera de los anteriores |

Solo informan; las correcciones las hace la conversación principal. Claude
te propone pasarlos en los momentos que fija la sección "Entrega" de
[development.md](.ai/project/development.md), que es la única fuente de esa
política. También puedes pedirlos directamente sobre un cambio de OpenSpec,
ficheros, carpetas o commits: «revisa `app/Http/Controllers/Pedidos` con
php-reviewer».

## Skills de código (solo Claude Code)

Referencia técnica que Claude no carga por su cuenta. La usan los revisores,
las reglas indican cuándo leerla y tú puedes invocarla (`/laravel-tdd`).

| Stack | Skills |
| ----- | ------ |
| Spring Boot | `springboot-security`, `jpa-patterns`, `springboot-tdd` |
| Laravel | `laravel-security`, `laravel-tdd` y el procedimiento `laravel-deploy` |
| Spring Boot y Laravel | `api-design` |
| React | `react-testing`, `frontend-a11y`, `e2e-testing` |
| API REST con SPA | `contract-first` (no aplica con Inertia) |

`laravel-deploy` es un procedimiento con fuente común en `.ai/skills/`:
comprueba que un proyecto Laravel está listo para desplegar, sin desplegar
nada.

## Reglas de código (solo Claude Code)

`.claude/rules/` contiene pautas breves por lenguaje (`comun/`, `java/`,
`php/`, `react/` e `inertia/`). Cada una se carga sola al leer un fichero que
coincide con su `paths:`, así que no hace falta citarlas. Las convenciones
propias del proyecto van en `development.md` y prevalecen sobre ellas.

Dos consecuencias prácticas:

- Usa una sesión por cambio: una regla cargada no se descarga hasta que
  termina la sesión o se compacta la conversación. `/context` muestra las
  que hay cargadas.
- Para crear un fichero nuevo, el agente lee antes uno vecino del mismo tipo:
  las reglas entran al leer, no al crear.
