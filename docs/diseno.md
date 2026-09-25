# Diseño de la plantilla

Este documento es para quien mantiene o amplía la plantilla. Explica por qué
cada pieza está donde está. Cómo se usa está en el [README](../README.md).
Los agentes no lo leen durante su trabajo.

## Principios

- **Carga bajo demanda.** De lo que aporta el proyecto, solo `AGENTS.md` y
  las descripciones de skills y subagentes están siempre en contexto. La
  memoria automática de Claude Code está desactivada en
  `.claude/settings.json` para que todo el equipo trabaje con las mismas
  instrucciones. El resto se lee cuando la tarea lo necesita: documentos enlazados desde la tabla
  "Contexto necesario", reglas por ruta y skills.
- **Una sola fuente por pauta.** Cada dato o decisión vive en un único sitio;
  los demás enlazan. Las fuentes de referencia son:

  | Tema | Fuente única |
  | ---- | ------------ |
  | Datos mínimos del proyecto | Ficha de `AGENTS.md` |
  | Comandos, base de datos de pruebas, convenciones propias y API | `.ai/project/development.md` |
  | Cuándo ofrecer los revisores y qué hacer con sus hallazgos | Sección "Entrega" de `development.md` |
  | Orden de pruebas primero | `rules` y `operations` de `openspec/config.yaml` |
  | Pautas generales de código, seguridad y pruebas | `.claude/rules/` |
  | Tecnologías y versiones del estándar | `templates/*.yaml` |

- **Controles que no dependen del modelo.** Lo que no debe ocurrir nunca va
  en `.claude/settings.json` o `.codex/config.toml`, no solo en texto.

## Skills y agentes

- Una **skill** define un procedimiento reutilizable y es la opción normal para
  tareas como preparar contexto o crear un commit.
- Un **agente** aporta un contexto aislado, herramientas o permisos propios.
  Úsalo solo cuando ese aislamiento, especialización o paralelismo aporte valor.
- La conversación principal invoca la skill o delega en el agente. Una skill
  puede solicitar delegación cuando su procedimiento lo necesite, pero no debe
  hacerlo por defecto para tareas breves y dependientes del contexto actual.
- El commit se ejecuta directamente mediante su skill. No necesita un agente
  intermedio y nunca debe lanzarse automáticamente sin petición del usuario.
- Las skills de setup solo se ejecutan al invocarlas. En Claude Code lo fija
  `disable-model-invocation` en su `SKILL.md`; en Codex, el archivo
  `agents/openai.yaml` de cada skill.
- Los procedimientos tienen su fuente común en `.ai/skills/` y adaptadores
  mínimos en `.claude/skills/` y `.agents/skills/`.
- Solo dos procedimientos pueden instalar, y siempre con confirmación en el
  momento: `setup-openspec` (OpenSpec) y `setup-testing` (herramientas de
  pruebas y análisis, como dependencias de desarrollo). El resto de la
  plantilla prohíbe instalar.
- `setup-testing` elige las herramientas en su propia tabla, no en
  `templates/`, hasta que se decida cómo declarar el estándar de pruebas en
  las plantillas. Las versiones las toma de la documentación oficial,
  compatibles con el manifiesto. Sus pruebas semilla existen también para
  que la primera prueba escrita a mano tenga un fichero vecino y cargue las
  reglas.

### Revisores

- La `description` de cada agente está siempre en el contexto, así que es
  breve (unas 30 palabras) y remite a la "Entrega" de `development.md` para
  saber cuándo ofrecerlo. No repitas esa política en otro sitio: la guía de
  archive de `openspec/config.yaml` también remite a ella.
- En un cambio de OpenSpec leen las especificaciones delta: cada escenario
  debe tener una prueba que lo nombre y compruebe su *Then*. Un escenario sin
  prueba es un hallazgo ALTO.
- Reciben el resultado de las pruebas ya ejecutadas sobre el mismo árbol y no
  las repiten; así, varios revisores en paralelo no se pisan.
- Usan las reglas de `.claude/rules/` como lista de comprobación. Algunos
  leen además una skill cuando el alcance lo requiere: `java-reviewer`,
  `jpa-patterns`; `react-reviewer`, `frontend-a11y`; `java-reviewer` y
  `php-reviewer`, `api-design` si se tocan controladores de la API; y
  `security-reviewer`, la de seguridad del stack.

### Skills de código

Detalle y ejemplos que no caben en las reglas, en las que se basan sin
repetirlas. Llevan `disable-model-invocation: true`: Claude no las carga por
su cuenta, para no duplicar lo que ya leen los revisores. Se usan de tres
formas:

- El programador las invoca cuando le interesan (`/springboot-tdd`).
- Los revisores leen las suyas si el alcance lo requiere.
- Una regla o `development.md` indica leerla antes de una tarea concreta:
  `springboot-security` y `laravel-security` al cambiar la configuración de
  seguridad, la autenticación o la subida de ficheros, `api-design` al crear
  o cambiar un endpoint, `e2e-testing` al escribir pruebas de Playwright y
  `contract-first` antes de cambiar el contrato de la API.
  La lectura funciona aunque la skill no sea invocable por el modelo.

## Reglas de código

| Regla | Se carga al leer |
| ----- | ---------------- |
| `comun/estilo-codigo.md` | Cualquier fichero de código de los stacks (`.java`, `.php`, `.js`, `.jsx`, `.ts`, `.tsx`) |
| `comun/seguridad.md` | Solo backend: `.java`, `.php` y `.sql` |
| `comun/pruebas.md` y `<lenguaje>/pruebas.md` | Solo ficheros de prueba: `tests/**/*.php`, `phpunit.xml`, `src/test/**/*.java`, `*.test.*`, `*.spec.*`, `__tests__/` y la configuración de Vitest o Playwright |
| `<lenguaje>/estilo-codigo.md`, `patrones.md` y `seguridad.md` | Cualquier fichero de su lenguaje (`java/seguridad.md` también `application*.yml`/`.properties`) |
| `java/oracle.md` y `php/oracle.md` | Cualquier fichero de su lenguaje y `.sql`. El setup las retira si la base de datos no es Oracle |
| `java/despliegue.md` | Solo `pom.xml`, `build.gradle`, `weblogic.xml`, `jboss-deployment-structure.xml`, la clase `*Application` y `application*.yml` |
| `inertia/patrones.md` | Páginas de `resources/js/Pages/`, controladores, `HandleInertiaRequests` y `routes/web.php`. El setup la retira si las vistas no usan Inertia |
| `inertia/seguridad.md` | Controladores y `HandleInertiaRequests` |
| `inertia/pruebas.md` | Pruebas PHP de `tests/` |

- Cada regla declara `paths:` en su cabecera, así que Claude Code solo la
  carga al leer un fichero que coincide: una tarea sin código no las carga, y
  un proyecto Java no carga las de PHP ni React aunque estén copiadas.
- Elige la herramienta según lo que marca el momento. Si lo marca un tipo de
  fichero (una prueba, el `pom.xml`, una migración), usa una regla con un
  `paths:` preciso. Si lo marca una acción que ningún fichero delata (crear
  un endpoint, cambiar la seguridad, desplegar), usa una skill y una línea en
  la regla que diga «léela antes de…».
- Una regla entra al leer un fichero que coincide, no al crearlo: por eso
  `development.md` pide leer un fichero vecino antes de crear uno nuevo.
- Una regla cargada no se descarga hasta que termina la sesión o se compacta
  la conversación. Con Inertia, controlador y página forman un mismo
  contrato: trabájalos en la misma sesión aunque el cambio sea grande.
- No añadas a `.claude/rules/` ficheros sin `paths:`, tampoco un README:
  Claude Code los cargaría en todas las sesiones.
- Las de `comun/` no se repiten en las de cada lenguaje, que solo añaden lo
  propio de su tecnología. Cuando una regla de variante contradice a otra
  (Inertia frente a los datos por API de `react/patrones.md`), lo declara al
  principio y la otra remite a ella con la salvedad «si existe».
- Son breves a propósito: se cargan cada vez que se toca código. El detalle
  extenso va en skills, que solo se leen cuando hacen falta.

> Aclaración: de momento son solo para Claude Code. Codex no tiene reglas por
> ruta y solo recibe lo que queda en `development.md`.

> Aclaración: la regla de React se activa con cualquier `.js`/`.ts`, también
> con los estáticos de un proyecto Spring Boot (`src/main/resources/static/`).
> El coste es pequeño.

## Plantillas de stack y setup

- Cada `templates/*.yaml` declara en `context` lo que el setup propone: las
  tecnologías, la base de datos, las vistas y su puente (`bridge`), las rutas
  y los comandos candidatos. Son la intención del estándar, no la prueba de
  lo implementado: el setup los contrasta con el repositorio.
- Los servidores MCP no se configuran a mano: cada plantilla declara en
  `context.mcp` los suyos con su configuración completa, y el setup los
  fusiona en `.mcp.json` solo cuando el stack los declara. Así un backend sin
  interfaz no arrastra un catálogo de componentes.
- La plantilla trae las reglas, revisores y skills de todos los stacks, y el
  setup retira lo que el proyecto no usa según la tabla fija de su sección
  "Retirar los stacks no usados". Cualquier artefacto nuevo que dependa de un
  stack necesita su fila en esa tabla, y las referencias a él desde otros
  ficheros, la salvedad «si existe».
