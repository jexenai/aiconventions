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
| Claude Code | `.claude/settings.json` | Bloquea leer y editar `.env.prod*`, editar `.env`, `.env.local` y `.env.*.local`, y leer claves y certificados (el `.env` local sí puede leerse); permite sin preguntar las órdenes de Git del commit inicial del setup y `git rm`; pide confirmación antes de `git push` y de las migraciones y los comandos `db:` de Artisan |
| Claude Code | `.claude/hooks/revisor-solo-lectura.sh` | Los revisores solo pueden ejecutar lecturas de Git, comprobaciones estáticas y auditorías de dependencias; nunca pruebas ni comandos que escriban |
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
   invocarlas: el agente no las lanza por su cuenta. Si el proyecto no tiene
   repositorio Git o no tiene commits, el setup lo inicializa y crea el commit
   inicial antes de empezar. Si está dentro de otro repositorio (un
   monorepo), trabaja sobre ese y no crea uno anidado. Si la herramienta
   deniega ese commit, te pregunta si lo autorizas. Ese commit es la
   línea base que permite revisar y deshacer lo que el setup retira; el
   resultado del setup queda sin commit para que lo revises. Si `.gitignore`
   excluye ficheros de la plantilla (`.claude/`, `AGENTS.md`, `.mcp.json`…),
   como hace el del kit de Laravel, el informe propone versionarlos.
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
6. Si el stack declara servidores MCP (por ejemplo, `dsjex`, el Sistema de
   Diseño de la Junta de Extremadura, para las vistas React de Laravel), el
   setup los añade a `.mcp.json`. Apruébalos en la primera sesión: añadirlos
   no los activa. Si el servidor tiene un paso de inicio (`dsjex`:
   `iniciar_proyecto`), el setup no lo ejecuta, pero deja en la sección
   "Sistema de diseño" de `development.md` cómo adaptarlo al stack; tras
   aprobarlo, pide al agente que inicie el sistema de diseño.
7. Si quedan pendientes comandos de pruebas, lint o análisis porque falta la
   herramienta (por ejemplo, Vitest en un Laravel con vistas React), el setup
   te pregunta al final si los preparas con `setup-testing`. Si aceptas,
   continúa en la misma ejecución: te pregunta qué preparar, instala solo con
   tu confirmación, crea una prueba semilla por tipo y registra los comandos.
   Si lo dejas para más tarde, ejecuta `/setup-testing` cuando quieras.

### Qué aplica el setup según el stack

Lo que declara cada `templates/*.yaml` y el setup materializa, además de la
ficha y los documentos:

| Clave del stack | Efecto en el setup | `laravel-inertia` | `laravel-api` |
| --------------- | ------------------ | ----------------- | ------------- |
| `database` | Persistencia y base de pruebas; puede declararse por entorno | Oracle 19c en producción, SQLite en desarrollo y en pruebas | Igual |
| `auth` | Se documenta como requisito; si el proyecto trae otra autenticación, se informa sin retirarla | SSO corporativo (JWT) | Igual |
| `ui.bridge` | Primera opción de P4 y decisión de qué reglas y skills se retiran. El setup comprueba que el repositorio usa ese puente y, si no, recomienda la otra plantilla | Inertia.js | API REST + SPA |
| `mcp` | `.mcp.json` y, con `init`, la adaptación del paso de inicio en `development.md` | `dsjex`; `iniciar_proyecto` adaptado a Inertia, sin react-router y sustituyendo los componentes Radix del kit | `dsjex`; `iniciar_proyecto` casi tal cual, en `resources/js/` y con react-router |
| `conventions.buildTools` | Comandos propuestos en P5 y P6 y filas de "Comandos", contrastados con los scripts. Formato y lint nunca cuentan como pruebas | Scripts del kit: `composer dev`, `composer lint:check`, `npm run check`; las pruebas de vistas quedan para `setup-testing` | Los de Laravel sin kit: `php artisan test`, `vendor/bin/pint`, `npm run build` |
| `conventions.formatIgnore` | Excluye la documentación del formateador del kit | `fmt.ignorePatterns` de `vite.config.ts` | No aplica: no hay kit |

La CI declarada (GitLab CI) no se genera todavía: el setup solo la documenta.

### Elegir entre `laravel-inertia` y `laravel-api`

En Laravel, cómo se unen backend y vistas se decide al crear el proyecto, no
después: el kit oficial de React ya trae Inertia, y una API se crea sin él.
Por eso son dos stacks y el setup no lo pregunta, solo lo confirma.

- **`laravel-inertia`:** una aplicación web con un único cliente. Los
  controladores pasan los datos a páginas React, sin API ni contrato que
  mantener. El navegador no añade el JWT del SSO a las visitas: o lo inyecta
  el gateway corporativo en cada petición, o Laravel abre una sesión tras el
  acceso por SSO. Está por decidir con Identidad corporativa.
- **`laravel-api`:** la misma API sirve también a otros clientes (móvil,
  integraciones) o el equipo de interfaz trabaja aparte. La SPA obtiene el
  token del SSO y lo envía como `Bearer`, y Laravel lo valida sin estado. Si
  la SPA vive en otro repositorio, ese repositorio usa `react18`.

El kit oficial trae su propia autenticación. Cómo crear cada variante sin
ella, para usar el SSO corporativo desde el principio, está pendiente de
estudio.

### Modo automático de Claude Code

En modo automático, un clasificador revisa cada comando aunque haya una regla
`allow` en `settings.json`, y deniega los que ve masivos o destructivos (por
ejemplo, un `git rm` de muchos ficheros). Para el setup y para las retiradas
grandes, usa un modo que pida confirmación (Shift+Tab) o ejecuta tú el
comando que el agente te indique.

Los campos `[POR DEFINIR]` que no afecten al trabajo actual pueden mantenerse
pendientes. No conviertas suposiciones en datos del proyecto.

### Manifest de distribución

Antes de distribuir una versión de la plantilla, genera `dist/manifest.json`
con una versión CalVer `YY.MM.PATCH`. El comando también crea
`dist/aiconventions.zip` con los mismos archivos inventariados:

```bash
bash scripts/new-manifest.sh --template-version "26.09.0"
```

El script calcula los hashes SHA-256 de los archivos gestionados, añade al
manifest el hash del zip y escribe ambos artefactos en `dist/`. En Git Bash
necesita tener disponible el comando `zip`. Si quieres usar solo los archivos
ya versionados en Git, añade `--tracked-only`.

El workflow de GitHub Actions `Build distribution` solo se ejecuta al empujar
una etiqueta `vYY.MM.PATCH` o `YY.MM.PATCH`, por ejemplo `v26.09.0`. Usa esa
etiqueta como versión de plantilla y publica `manifest.json` y
`aiconventions.zip` como artefactos del job y como assets de la release.

URLs de descarga de la última release:

```text
https://github.com/jexenai/aiconventions/releases/latest/download/manifest.json
https://github.com/jexenai/aiconventions/releases/latest/download/aiconventions.zip
```

Para publicar manualmente una versión:

```bash
git tag v26.09.0
git push origin main
git push origin v26.09.0
```

Si tu rama principal no se llama `main`, cambia `main` por el nombre real de
la rama.

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

Solo informan; las correcciones las hace la conversación principal. Tampoco
ejecutan pruebas: Claude las ejecuta antes y les pasa el resultado. Claude
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
| Spring Boot | `springboot-security`, `jpa-patterns`, `springboot-tdd`, `openapi-mapstruct` |
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
