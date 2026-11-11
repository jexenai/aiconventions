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
  | Cuándo delegar en `test-runner` | Sección "Comandos" de `development.md` |
  | Comandos que ejecuta `test-runner` (derivados de "Comandos") | Bloque generado en `.claude/agents/test-runner.md` |
  | Orden de pruebas primero | `rules` y `operations` de `openspec/config.yaml` |
  | Pautas generales de código, seguridad y pruebas | `.claude/rules/` |
  | Tecnologías y versiones del estándar | `templates/*.yaml` |

- **Controles que no dependen del modelo.** Lo que no debe ocurrir nunca va
  en `.claude/settings.json` o en un hook, no solo en texto.
  Las reglas de `Bash(…)` no cubren la herramienta PowerShell que Claude
  Code ofrece en Windows: cada regla `ask` se declara para las dos. Los
  permisos `allow` del commit inicial (`git init`, `git add`,
  `git commit`) solo existen para la fase 0 del setup, que los retira al
  terminar; si se quedaran, «no hagas commits sin petición» dependería solo
  del texto.

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
- Las skills de setup solo se ejecutan al invocarlas: lo fija
  `disable-model-invocation` en su `SKILL.md`.
- Los procedimientos propios de la plantilla son skills nativas de Claude
  Code: cada uno vive entero en su carpeta de `.claude/skills/`, con sus
  plantillas al lado si las tiene (`liberar-version`). No hay una fuente
  aparte con adaptadores: la plantilla solo se dirige a Claude Code (usa
  `AskUserQuestion`, hooks, reglas por ruta y subagentes), y mantener dos
  copias enlazadas no aportaba nada. `.claude/skills/README.md` es el
  catálogo que enlaza `AGENTS.md`.
- Los comandos `/opsx:*` no se versionan en la plantilla: los genera
  OpenSpec al instalarlo y así corresponden a su versión. El único comando
  propio es `/leer_requisitos`, que depende de OpenSpec y por eso tiene su
  fila en la tabla de retirada del setup.
- Solo tres procedimientos pueden instalar, y siempre con confirmación en el
  momento: `setup-openspec` (OpenSpec), `setup-testing` (herramientas de
  pruebas y análisis, como dependencias de desarrollo) y `liberar-version`
  (VitePress, `medium-zoom` y el navegador de Playwright, la primera vez que
  se genera el manual). El resto de la plantilla prohíbe instalar.
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
- No ejecutan pruebas: las ejecuta la conversación principal, que conoce la
  "Base de datos de pruebas", y les pasa el resultado sobre el mismo árbol.
  Así ningún revisor reinicia una base de datos y varios en paralelo no se
  pisan.
- Lo que pueden ejecutar no depende del prompt: un hook `PreToolUse` en su
  frontmatter (`.claude/hooks/revisor-solo-lectura.sh`) solo deja pasar
  lecturas de Git, comprobaciones estáticas (compilación, formato en modo
  comprobación, lint, tipos, análisis) y auditorías de dependencias, y
  bloquea todo lo demás, incluido lo que no reconoce. Si el proyecto usa
  otro comando de comprobación, añádelo a la lista del script. Necesita
  `bash` (en Windows, Git Bash).
  Las listas son cerradas a propósito: `npm audit` pasa pero `npm audit fix`
  no, `tsc` solo con `--noEmit` y `-p`, y `npx` solo ejecuta lo que ya está
  en `node_modules` (o con `--no-install`), porque si no descargaría el
  paquete. Los scripts de `npm run` y `composer` admitidos son los que
  declaran `templates/*.yaml` y `setup-testing`; al añadir un comando de
  comprobación a una plantilla, añádelo también al hook.
- Su bloque «Además de las reglas» solo contiene lo que las reglas no
  cubren (concurrencia, flujos con estado, entrada peligrosa, escenarios).
  La arquitectura y el estilo los comprueban leyendo las reglas: no los
  repitas en los revisores.
- Usan las reglas de `.claude/rules/` como lista de comprobación. Algunos
  leen además una skill cuando el alcance lo requiere: `java-reviewer`,
  `jpa-patterns`; `react-reviewer`, `frontend-a11y`; `java-reviewer` y
  `php-reviewer`, `api-design` si se tocan controladores de la API; y
  `security-reviewer`, la de seguridad del stack.

### Ejecutor de pruebas

- Un único `test-runner` para todos los stacks. Lo que cambia entre stacks
  son los comandos, no el trabajo: la plantilla lo trae genérico, con un
  bloque de comandos vacío, y el setup lo especializa.
- Usa `haiku`, que no debe interpretar una tabla con huecos, filas
  compartidas o comandos que corrigen. Por eso el criterio va en
  [Generar los comandos de test-runner](../.claude/skills/setup-project-context/comandos-test-runner.md),
  que aplica un modelo capaz con el usuario delante: elige solo comandos de
  lectura, compila sin pruebas, separa unitarias e integración, marca las
  inclusiones, incorpora el "Entorno local" y bloquea las filas con base de
  datos sin confirmar. El agente solo ejecuta las filas del bloque.
- La fuente sigue siendo la tabla "Comandos" de `development.md`, que usa
  también la conversación principal. El bloque es derivado: lo regeneran
  `setup-project-context`, `setup-testing` y cualquier tarea que cambie la
  tabla, la "Base de datos de pruebas" o el "Entorno local".
- El mismo paso añade cada comando ejecutable a `permissions.allow`, para
  que el agente no dependa de confirmaciones al ejecutarse en segundo plano.
  Lo añade como `Bash(…)` y como `PowerShell(…)`: el agente declara las dos
  herramientas y una regla de una no cubre la otra.
- Ejecuta pruebas, así que no lleva el hook de los revisores, sino el suyo
  (`.claude/hooks/test-runner-solo-bloque.sh`): solo deja pasar los
  comandos del bloque generado, escritos igual, y bloquea las filas
  marcadas «no ejecutar». Así, que no instale, no arregle ni lance una
  migración no depende de que un modelo pequeño obedezca su prompt. Los dos
  hooks comparten la lectura del comando en `leer-comando.sh`. Su valor está en no llenar el contexto principal con la salida
  de la suite.

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
  o cambiar un endpoint, `jpa-patterns` al crear o cambiar una entidad, un
  repositorio o una consulta, `laravel-patterns` al crear o cambiar un
  caso de uso, un validador, un modelo o una consulta, `openapi-mapstruct` al crear o cambiar un
  mapper, `springboot-tdd`, `laravel-tdd` y `react-testing` antes de
  escribir o corregir una prueba de su stack,
  `e2e-testing` al escribir pruebas de Playwright, `frontend-a11y` antes de
  crear o cambiar un formulario o un componente interactivo y `contract-first` antes
  de cambiar el contrato de la API.
  La lectura funciona aunque la skill no sea invocable por el modelo.

### Manual de usuario

`liberar-version` genera y mantiene el manual de usuario. Decisiones:

- **Una versión liberada es un tag en un commit que ya contiene su manual.**
  Git no avisa al crear un tag y un manual generado después quedaría fuera
  de él, así que la skill es la que crea el tag, tras la revisión del
  usuario. Los tags se pueden seguir creando a mano: la skill documenta
  después el último tag si el código no ha cambiado desde él, o recoge sus
  cambios en la siguiente versión. No hay hook que bloquee `git tag`.
- **Una sola versión del manual, la última.** Las aplicaciones web solo
  tienen una versión en uso; el historial queda en los tags y en
  `novedades.md`.
- **VitePress, publicado con la aplicación en `/manual/`.** El build de la
  aplicación encadena el del manual dentro de su carpeta de salida, así que
  se despliega sin pasos extra. Es contenido estático: lo ve quien llegue al
  servidor, igual que la aplicación.
- **El texto lo redacta Claude y lo edita el usuario.** En cada versión solo
  se tocan los párrafos afectados por cambios visibles, para no pisar sus
  ediciones. El orden sale de la interfaz (menú y recorrido de cada
  pantalla) y el contenido de las especificaciones; si discrepan, manda lo
  implementado.
- **Capturas deterministas.** Playwright contra un build de la aplicación
  servido aparte (el servidor de desarrollo compila al vuelo y las capturas
  en paralelo fallan), con la API simulada con datos ficticios, la sesión
  fijada por perfil y los elementos de desarrollo ocultos. Se versionan en
  `docs/manual/img/`; el HTML no.
- **El estilo es el de la aplicación de cada proyecto.** La plantilla de
  `custom.css` lleva valores neutros; la skill los sustituye por los tokens
  de la aplicación (o del servidor MCP de sistema de diseño) y comprueba el
  resultado en claro, oscuro y móvil.

## Reglas de código

| Regla | Se carga al leer |
| ----- | ---------------- |
| `comun/estilo-codigo.md` | Cualquier fichero de código de los stacks (`.java`, `.php`, `.js`, `.jsx`, `.ts`, `.tsx`) |
| `comun/seguridad.md` | Solo backend: `.java`, `.php` y `.sql` |
| `comun/organizacion-backend.md` | Solo backend: `.java` y `.php`. Casos de uso y validadores; se separó de `estilo-codigo.md` para no cargarla con React |
| `comun/pruebas.md` y `<lenguaje>/pruebas.md` | Solo ficheros de prueba: `tests/**/*.php`, `phpunit.xml`, `src/test/**/*.java`, `*.test.*`, `*.spec.*` y `__tests__/`. La configuración de Vitest, Playwright o Vite solo carga `react/pruebas.md` |
| `<lenguaje>/estilo-codigo.md`, `patrones.md` y `seguridad.md` | Cualquier fichero de su lenguaje (`java/seguridad.md` también `application*.yml`/`.properties`) |
| `java/datos.md` | Solo los paquetes donde se mapea o podría mapearse a mano: `mappers`, `controllers`, `actions`, `validator` y `models` |
| `java/oracle.md` | Solo `models`, `repositories`, `.sql`, `db/migration/` y `db/changelog/` |
| `php/oracle.md` | Cualquier `.php` y `.sql`. El setup retira las dos de Oracle si la base de datos no lo es |
| `java/despliegue.md` | Solo `pom.xml`, `build.gradle`, `weblogic.xml`, `jboss-deployment-structure.xml`, la clase `*Application` y `application*.yml` |
| `inertia/patrones.md` | Páginas, componentes de entidad y layouts de `resources/js/` (`pages/`, `features/`, `layouts/`), controladores, `HandleInertiaRequests` y `routes/web.php`. El setup la retira si las vistas no usan Inertia |
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
  propio de su tecnología. Qué es un caso de uso y un validador, cómo se
  nombran y qué hace cada uno está solo en `comun/organizacion-backend.md`; los
  `patrones.md` de cada stack añaden la carpeta, las anotaciones y el
  acceso a datos. La política de avisos de Sonar también vive ahí, porque
  es la única regla que se carga con cualquier código. Cuando una regla de variante contradice a otra
  (Inertia frente a los datos por API de `react/patrones.md`), lo declara al
  principio y la otra remite a ella con la salvedad «si existe».
- `java/datos.md` y `java/oracle.md` se acotan por paquete y dependen de
  la estructura de `java/patrones.md`. Si un proyecto usa otros paquetes
  (convenciones propias de `development.md`), ajusta sus `paths`.
- Son breves a propósito: se cargan cada vez que se toca código. El detalle
  extenso va en skills, que solo se leen cuando hacen falta.

> Aclaración: la regla de React se activa con cualquier `.js`/`.ts`, también
> con los estáticos de un proyecto Spring Boot (`src/main/resources/static/`).
> El coste es pequeño.

## Plantillas de stack y setup

- Cada `templates/*.yaml` declara en `context` lo que el setup propone: las
  tecnologías, la base de datos, las vistas y su puente (`bridge`), las rutas
  y los comandos candidatos. Son la intención del estándar, no la prueba de
  lo implementado: el setup los contrasta con el repositorio.
- Una plantilla por decisión que se toma al crear el proyecto. En Laravel,
  Inertia o API REST condiciona el kit, los scripts, cómo se inicia
  el sistema de diseño y cómo llega el token del SSO, así que son dos
  plantillas (`laravel-inertia` y `laravel-api`) con `bridge` fijado.
  `bridgeOptions` queda para los stacks en los que el puente pueda elegirse
  después de crear el proyecto.
- Los servidores MCP no se configuran a mano: cada plantilla declara en
  `context.mcp` los suyos con su configuración completa, y el setup los
  fusiona en `.mcp.json` solo cuando el stack los declara. Así un backend sin
  interfaz no arrastra un catálogo de componentes.
- La plantilla trae las reglas, revisores y skills de todos los stacks, y el
  setup retira lo que el proyecto no usa según la tabla fija de su sección
  "Retirar los stacks no usados". Cualquier artefacto nuevo que dependa de un
  stack necesita su fila en esa tabla, y las referencias a él desde otros
  ficheros, la salvedad «si existe».
