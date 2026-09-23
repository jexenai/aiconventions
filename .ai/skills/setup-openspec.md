# Adoptar OpenSpec

Utiliza este procedimiento cuando haya que decidir si el proyecto usará
OpenSpec y, si la respuesta es afirmativa, instalarlo e inicializarlo. La
skill `setup-project-context` deriva aquí esa decisión al adoptar la
plantilla; también puede invocarse más adelante.

El resultado es la decisión registrada en la ficha de `AGENTS.md` y, cuando se
adopta, OpenSpec inicializado en el repositorio. La forma de trabajar con
especificaciones y cambios la define el propio OpenSpec mediante el workflow
que instala; esta plantilla no la duplica.

## Límites

- Instala y ejecuta OpenSpec solo con confirmación explícita del usuario en el
  momento. Es la única excepción a la regla general de no instalar
  dependencias y no se extiende a ninguna otra herramienta.
- No sobrescribas una instalación existente. Si ya hay `openspec/`, limítate a
  registrar la decisión y la versión instalada.
- No crees, modifiques ni archives especificaciones ni cambios durante la
  adopción.
- No hagas commits ni pushes de lo generado.
- No copies los workflows ni las skills que genera OpenSpec en `AGENTS.md`,
  en `.ai/project/` ni en `.ai/skills/`.

## Preguntas

Este procedimiento solo plantea las preguntas de esta sección, con su
cabecera, texto y opciones, usando el mecanismo de la tabla
[Mecanismo de preguntas](setup-project-context.md#mecanismo-de-preguntas):
`AskUserQuestion` en Claude Code y mensaje numerado en Codex. No preguntes en
texto libre ni añadas otras preguntas.

| Id | Cabecera | Pregunta | Opciones |
| -- | -------- | -------- | -------- |
| P9 | OpenSpec | ¿El proyecto va a usar OpenSpec para las especificaciones? | `Sí, instalarlo ahora` · `No se usa` · `Decidir más tarde` |
| O1 | Herramientas | ¿Para qué herramientas se configura OpenSpec? (selección múltiple) | `Claude Code` · `Codex` |
| O2 | Instalación | ¿Ejecuto la instalación y la inicialización? | `Ejecutar <comandos>` · `Cancelar y dejar pendiente` |

P9 es la misma pregunta que la ronda 3 de `setup-project-context`: si llegas
desde allí con la respuesta `Sí, instalarlo ahora`, no la repitas. O1 y O2 se
plantean juntas en una sola ronda. Ninguna opción lleva `(Recomendado)`,
salvo en O1 las herramientas cuya configuración ya exista en el repositorio
(`.claude/` o `.agents/`).

Si una ronda no obtiene respuesta, no vuelvas a preguntar: conserva
`[POR DEFINIR]`, no instales nada y decláralo pendiente.

## Decidir

1. Comprueba si ya existe `openspec/` o `openspec/config.yaml`. Si existe, no
   inicialices ni preguntes: obtén la versión instalada, registra la decisión
   y termina.
2. Si no existe, plantea P9. La pregunta es obligatoria: no elijas por el
   usuario ni dejes la decisión implícita. Si la ficha dice `No se usa` y el
   usuario invoca este procedimiento, trátalo como una petición de
   reconsiderar la decisión y plantea P9 igualmente.
3. Si la respuesta es `No se usa`, regístralo en la ficha y no instales ni
   ejecutes nada.
4. Si la respuesta es `Decidir más tarde` o no hay respuesta, conserva
   `[POR DEFINIR]` y decláralo pendiente. No lo conviertas en `No se usa` por
   omisión.

## Instalar

1. Consulta la documentación oficial vigente para el comando de instalación e
   inicialización y sus opciones. No des por fijos los nombres de los flags:
   compruébalos antes de ejecutarlos.
2. Plantea O1 y O2 en una sola ronda. En la descripción de O2 indica los
   comandos exactos, el gestor de paquetes, el ámbito de la instalación y que
   requiere acceso a red. Si el usuario cancela, aplica el paso 4 de
   [Decidir](#decidir).
3. Ejecuta la inicialización en la raíz indicando de forma no interactiva
   solo las herramientas elegidas en O1, porque el modo interactivo puede
   bloquearse en un entorno sin terminal.
4. Sustituye el contenido que genera la inicialización de `openspec/config.yaml`,
   que suele ser una plantilla comentada, por un contexto breve y la política de
   pruebas. `rules` y `operations` son claves propias de OpenSpec: úsalas para
   fijar el orden de las pruebas en lugar de describirlo aparte. El bloque
   `context` es lo único que varía según el proyecto; `rules` y `operations` se
   escriben tal cual:

   ```yaml
   schema: spec-driven

   context: |
     Las reglas comunes están en AGENTS.md.
     La documentación estable está en .ai/project/.
     Lee solo el contexto y los artefactos necesarios para el cambio.

   rules:
     specs:
       - Cada escenario en Given/When/Then, verificable de forma automática.
     tasks:
       - Toda tarea que cambie comportamiento empieza por la prueba del
         escenario que cubre, y esa prueba debe fallar antes de implementar.
       - Indica en la tarea qué escenario del delta cubre.

   operations:
     apply:
       guidance:
         - Ejecuta la prueba del escenario antes que la suite completa.
   ```

   Comprueba en la documentación vigente de OpenSpec que `rules` y `operations`
   siguen admitiendo estas claves antes de escribirlas. Si el esquema elegido no
   es `spec-driven`, ajusta los nombres de artefacto a los que declare.

5. Revisa todos los archivos generados antes de versionarlos: `openspec/`, las
   skills y comandos de cada herramienta configurada y los marcadores internos
   que deje. Comprueba también si ha modificado `AGENTS.md` o `CLAUDE.md`; si
   añade bloques, resuelve las duplicidades ajustando el texto de la plantilla,
   no el bloque gestionado por OpenSpec.

## Registrar la decisión

Actualiza la fila `Especificaciones` de la ficha de `AGENTS.md` con uno de
estos valores:

- `OpenSpec <versión>` cuando esté inicializado. La ruta siempre es
  `openspec/`, así que no la repitas en la ficha.
- `No se usa` cuando el usuario lo haya descartado.
- `[POR DEFINIR]` mientras la decisión siga pendiente.

## Comprobación final

1. Comprueba que `openspec/` y su configuración existen y que la versión
   registrada coincide con la instalada.
2. Comprueba que `openspec/config.yaml` es YAML válido y conserva `context`,
   `rules` y `operations`.
3. Revisa que la ficha de `AGENTS.md` no contradiga el estado real.
4. Revisa el diff para detectar archivos generados fuera de lo esperado.

Al terminar, informa de lo siguiente. Si llegas desde `setup-project-context`,
añádelo a su informe, con O1 y O2 como filas adicionales de la tabla del
guion:

- Una tabla con las filas P9, O1 y O2 y las columnas `Pregunta`, `Respuesta`
  y `Estado`, marcando `No planteada` las que este procedimiento no requirió.
- La decisión del usuario y dónde ha quedado registrada.
- Comando ejecutado y versión instalada, si se ha instalado.
- Archivos generados o modificados, y los que quedan pendientes de revisar.
- Comprobaciones ejecutadas y limitaciones.
