# Preparar el contexto del proyecto

Utiliza este procedimiento cuando se incorpore la plantilla a un repositorio,
se solicite completar los campos `[POR DEFINIR]` o sea necesario actualizar la
ficha de `AGENTS.md` y la documentación estable de `.ai/project/` tras cambios
estructurales importantes.

El resultado debe describir el proyecto real con evidencia suficiente, sin
convertir convenciones habituales ni preferencias del agente en decisiones del
equipo.

El flujo es fijo: recorre las fases en orden, sin saltarte ninguna, y plantea
siempre las mismas preguntas del [guion](#fase-3-preguntar-con-el-guion) de la
misma manera, se ejecute por primera vez o se repita.

## Límites

- No instales dependencias, levantes servicios, conectes con bases de datos ni
  accedas a entornos externos para completar la documentación.
- No instales, inicialices, sincronices ni archives OpenSpec desde este
  procedimiento. Si el usuario decide adoptarlo, continúa con
  [setup-openspec.md](setup-openspec.md) en la fase 5.
- No modifiques código de aplicación ni configuración funcional salvo que el
  usuario amplíe expresamente el alcance. En `AGENTS.md` edita solo su ficha.
- No sobrescribas cambios ajenos ni sustituyas datos existentes sin comprobar
  que han quedado obsoletos.
- No reproduzcas secretos ni datos personales encontrados durante la revisión.
- No apruebes servidores MCP, no los arranques ni instales sus dependencias.
  Materializar su configuración no es activarlos.
- No edites `docs/stack.yaml`: lo genera el plugin a partir de la plantilla de
  stack elegida.
- No hagas preguntas fuera del guion. Lo que no cubra el guion se resuelve con
  evidencia o queda pendiente en el informe.

## Fase 1: recopilar evidencia

Solo lectura. No edites nada en esta fase.

1. Lee `AGENTS.md`, el `README` principal, `.ai/project/context.md` y
   `.ai/project/development.md`.
2. Lee `docs/stack.yaml` si existe y aplica la sección
   [Usar el stack declarado](#usar-el-stack-declarado).
3. Comprueba si OpenSpec está inicializado buscando `openspec/config.yaml` o
   el directorio `openspec/`, y obtén su versión si lo está.
4. Revisa el estado de Git para distinguir el contenido existente de cambios
   locales que deban preservarse.
5. Obtén un mapa acotado del repositorio, excluyendo dependencias descargadas,
   binarios generados y resultados de compilación.
6. Consulta únicamente las fuentes necesarias para completar cada dato:
   manifiestos, archivos de bloqueo, scripts, configuración, CI, pruebas,
   contenedores, despliegue y documentación vigente.
7. Comprueba que las rutas y comandos citados existen. Distingue claramente
   entre comandos observados y comandos realmente ejecutados.

Solo ejecuta comprobaciones locales rápidas y sin efectos cuando aporten
evidencia necesaria, como consultar la versión de una herramienta ya
instalada.

## Fase 2: preparar las propuestas

Sin editar todavía, prepara para cada pregunta del guion sus opciones:

1. **Primera opción:** el valor actual de la ficha si no es `[POR DEFINIR]`;
   si lo es, el valor deducido de la evidencia. Añade `(Recomendado)` a la
   etiqueta solo si lo respalda una fuente del repositorio o de
   `docs/stack.yaml`, y cita esa fuente en la descripción de la opción.
2. **Alternativas:** las que aporte la evidencia, como una versión distinta en
   el manifiesto o las `bridgeOptions` del stack. No inventes alternativas
   para completar el número de opciones.
3. **Última opción:** `Dejar pendiente`, y además `No aplica` en las preguntas
   que lo admitan.

Cada pregunta tiene entre dos y cuatro opciones. Si la evidencia aporta más
alternativas, conserva las que tengan fuente más directa y cita las demás en
la descripción de la primera opción. Si no hay ninguna propuesta con
evidencia, la primera opción es `Sin evidencia: indícalo tú`, cuya
descripción remite a escribir el valor propio.

Clasifica también los demás `[POR DEFINIR]` de `context.md` y
`development.md`, que no tienen pregunta propia:

- **Demostrable:** se completa en la fase 4 con una fuente verificable.
- **No aplicable:** se sustituye por `No aplica` y una razón breve únicamente
  cuando la ausencia pueda demostrarse.
- **Pendiente:** conserva el marcador y explica en el informe qué evidencia o
  decisión falta.

## Fase 3: preguntar con el guion

Plantea siempre las nueve preguntas, en este orden y agrupadas en estas tres
rondas, aunque el valor ya esté en la ficha o parezca evidente. Cuando un dato
ya esté resuelto, la pregunta sirve de confirmación: su primera opción es el
valor actual. No omitas preguntas, no las fusiones, no cambies su redacción y
no añadas otras.

### Mecanismo de preguntas

| Herramienta | Cómo preguntar |
| ----------- | -------------- |
| Claude Code | Una llamada a `AskUserQuestion` por ronda, con la cabecera, el texto y las opciones del guion. Nunca preguntes en texto libre: si la herramienta no está disponible o el usuario la rechaza, sigue la regla de [respuestas ausentes](#respuestas-ausentes) |
| Codex | Un único mensaje por ronda con las preguntas numeradas `P1`…`P9` y las opciones con letras, y espera la respuesta antes de pasar a la ronda siguiente. No uses `request_user_input` aunque aparezca entre las herramientas: fuera del modo Plan puede rechazarse y haría variar la forma de preguntar. En ejecuciones no interactivas (`codex exec`), sigue la regla de [respuestas ausentes](#respuestas-ausentes) |

La opción de escribir un valor propio siempre está disponible: en Claude Code
la añade la herramienta como `Other`; en Codex, indícalo al final del mensaje.

### Ronda 1: ficha

| Id | Cabecera | Pregunta | Opciones |
| -- | -------- | -------- | -------- |
| P1 | Propósito | ¿Cuál es el propósito principal del proyecto? | Propuesta deducida del README o del código · Dejar pendiente |
| P2 | Tecnologías | ¿Qué tecnologías y versiones usa el proyecto? | Declaradas en `context.declared` · Las del manifiesto, si difieren · Dejar pendiente |
| P3 | Código | ¿Dónde está el código de aplicación? | Ruta de `context.conventions.paths.code` si existe · Ruta observada, si difiere · Dejar pendiente |
| P4 | Vistas | ¿Qué tecnología renderiza las vistas y dónde viven? | Con `context.ui`: la declarada con su `bridge` o, si está sin fijar, una opción por cada `bridgeOptions` · Dejar pendiente. Sin `context.ui`: vistas del framework · No aplica · Dejar pendiente |

### Ronda 2: ejecución

| Id | Cabecera | Pregunta | Opciones |
| -- | -------- | -------- | -------- |
| P5 | Arranque | ¿Con qué comando se arranca el proyecto en local? | Comando respaldado por scripts, wrapper o CI · Dejar pendiente |
| P6 | Pruebas | ¿Cuál es el comando de pruebas habitual? | Comando respaldado por scripts, wrapper o CI · Dejar pendiente |
| P7 | Base datos | ¿Qué base de datos usa el proyecto? | Declarada en `context.database` · La de la configuración, si difiere · No aplica · Dejar pendiente |
| P8 | Diseño | ¿Qué sistema de diseño consume el proyecto por MCP? | Con `context.mcp`: una sola opción con todos sus servidores y su propósito · Dejar pendiente. Sin `context.mcp`: No se usa · Dejar pendiente |

### Ronda 3: OpenSpec

| Id | Cabecera | Pregunta | Opciones |
| -- | -------- | -------- | -------- |
| P9 | OpenSpec | ¿El proyecto va a usar OpenSpec para las especificaciones? | Ver abajo |

Opciones de P9 según el estado:

- **`openspec/` existe:** `Registrar OpenSpec <versión> (Recomendado)` ·
  `Dejar pendiente`.
- **No existe:** `Sí, instalarlo ahora` · `No se usa` · `Decidir más tarde`.
  Ninguna lleva `(Recomendado)`: es una decisión de equipo.

### Respuestas ausentes

Si una ronda no obtiene respuesta porque la herramienta no está disponible, la
ejecución no es interactiva o el usuario la rechaza, no vuelvas a preguntar ni
preguntes en texto. Para cada pregunta de esa ronda:

- Aplica la primera opción solo si lleva `(Recomendado)`, e indícalo en el
  informe como "sin confirmar".
- En los demás casos, y siempre en P4 cuando el `bridge` esté sin fijar y en
  P9, conserva `[POR DEFINIR]`.

Continúa con la ronda siguiente.

## Fase 4: actualizar los documentos

Aplica las respuestas y la clasificación de la fase 2:

- `AGENTS.md`: ficha del proyecto con las respuestas de P1 a P8. La fila
  `Especificaciones` se resuelve en la fase 5.
- `context.md`: alcance, componentes, mapa, dominio, decisiones de
  arquitectura y seguridad del sistema, con la persistencia de P7.
- `development.md`: comandos de P5 y P6, convenciones de implementación,
  comentarios, pruebas y entrega.
- `.mcp.json`: según P8, aplicando
  [Materializar los servidores MCP](#materializar-los-servidores-mcp).

Mantén cada dato en una única fuente. Enlaza documentos relacionados en lugar
de copiar reglas completas entre ellos.

## Fase 5: registrar la decisión sobre OpenSpec

Según la respuesta a P9:

| Respuesta | Acción |
| --------- | ------ |
| `Registrar OpenSpec <versión>` | Escribe `OpenSpec <versión>` en la fila `Especificaciones` |
| `Sí, instalarlo ahora` | Sigue [setup-openspec.md](setup-openspec.md) desde su sección `Instalar`; la decisión ya está tomada y no se repite |
| `No se usa` | Escribe `No se usa` y no instales nada |
| `Decidir más tarde` o sin respuesta | Conserva `[POR DEFINIR]`. `AGENTS.md` volverá a pedir la decisión en la siguiente tarea no trivial |

## Fase 6: comprobación final e informe

1. Busca los marcadores `[POR DEFINIR]` restantes y clasifícalos.
2. Comprueba que los enlaces y rutas locales añadidos existen.
3. Si el stack declara `context.mcp`, comprueba que `.mcp.json` es JSON válido,
   que conserva los servidores previos y que la ficha coincide con él.
4. Revisa que no se hayan documentado ejemplos como configuración activa.
5. Contrasta los comandos registrados con scripts, manifiestos o CI.
6. Revisa el diff para detectar datos inventados, duplicaciones y cambios fuera
   del alcance documental.

Termina siempre con un informe con estas secciones, en este orden:

1. **Guion:** una tabla con una fila por pregunta, de `P1` a `P9`, con las
   columnas `Pregunta`, `Respuesta` y `Estado` (`Confirmada`, `Sin confirmar`
   o `Pendiente`). No omitas filas.
2. **Fases:** una tabla con una fila por fase, de 1 a 6, con `Hecha` u
   `Omitida` y el motivo. Una fase solo puede omitirse por un límite de este
   procedimiento.
3. **Documentos:** documentos y secciones completados.
4. **Evidencia:** fuentes utilizadas y datos tomados de `docs/stack.yaml`, con
   sus diferencias respecto al código.
5. **MCP:** servidores añadidos a `.mcp.json` y aviso de que el usuario debe
   aprobarlos; en ejecuciones desatendidas se cargan sin preguntar.
6. **Pendientes:** marcadores restantes con su motivo concreto.
7. **Comprobaciones:** comprobaciones ejecutadas y limitaciones de la revisión.

## Usar el stack declarado

`docs/stack.yaml` recoge el stack estándar que el equipo eligió para el
proyecto. Es la intención declarada, no la prueba de lo implementado. Usa solo
su bloque `context`; ignora `profiles`, `projectRules`, `disabledRules` y las
listas de `skills`, estén en la raíz o dentro de `context.conventions`, porque
no definen procedimientos disponibles en este repositorio. Los procedimientos
reales son los de [.ai/skills/README.md](README.md).

| Clave | Destino | Uso |
| ----- | ------- | --- |
| `context.declared` | Ficha de `AGENTS.md` (tecnologías y versiones) y entornos de ejecución en `context.md` | Propuesta de P2. Si los manifiestos o la configuración indican otra versión, ofrécela como alternativa |
| `context.database` | Persistencia en `context.md` | Propuesta de P7. Declara una sola base de datos; contrástala con la configuración y, si apunta a otra, ofrécela como alternativa. Con el valor `N/A`, propón `No aplica` tras comprobar que el repositorio no contiene configuración de base de datos |
| `context.dependencies` | Configuración y dependencias en `context.md` | Dependencias que el estándar exige para el stack. Comprueba si están en el manifiesto e informa de su ausencia sin instalarlas |
| `context.deployment` | Entornos de ejecución y despliegue en `context.md` | Documenta el empaquetado y el destino declarados. Si el manifiesto o el CI producen otro artefacto, informa de la diferencia sin resolverla |
| `context.ui` | Ficha de `AGENTS.md` (capa de vistas) y mapa del repositorio en `context.md` | Propuesta de P4. Documenta la ruta de `entry` solo si existe. Si `bridge` está fijado o el manifiesto lo demuestra, es la primera opción; si no, ofrece cada valor de `bridgeOptions` sin `(Recomendado)`. Sus `dependencies` son paquetes npm: comprueba si están en `package.json` e informa de su ausencia sin instalarlas. Si la clave no existe, propón las vistas del framework declarado con la evidencia del repositorio y reserva `No aplica` para los proyectos que no sirven interfaz |
| `context.mcp` | `.mcp.json` de la raíz y ficha de `AGENTS.md` (sistema de diseño) | Propuesta de P8. Si la clave no existe, el stack no usa ninguno y la primera opción es `No se usa` |
| `context.conventions.paths` | Ficha de `AGENTS.md` (código de aplicación) y mapa del repositorio en `context.md` | Propuesta de P3. Documenta solo las rutas que existan. `views` es la carpeta de las vistas reales del proyecto, que puede no coincidir con la de plantillas del framework; contrástala con `context.ui` |
| `context.conventions.generated` | Archivos generados en el mapa del repositorio | Documenta solo los que existan o estén declarados en `.gitignore` |
| `context.conventions.buildTools` | Ficha de `AGENTS.md` (arranque y pruebas) y comandos de `development.md` | Propuestas de P5 y P6. Usa la herramienta cuyo `file` exista. Las claves de `commands` son candidatas del estándar, no comandos garantizados: propón cada una solo si la respaldan sus scripts, un wrapper del repositorio o el CI; si hay wrapper, prefiérelo |

El archivo no aporta el propósito, los usuarios, el dominio, las decisiones de
arquitectura ni la seguridad del proyecto. Complétalos con otra evidencia o
mantén el marcador.

Si el repositorio aún no contiene código, propón los datos de
`context.declared` indicando que proceden de `docs/stack.yaml` y deja
pendientes las rutas y comandos que no puedan comprobarse.

## Materializar los servidores MCP

Aplica en la fase 4 cuando P8 confirme uno o más servidores de `context.mcp`.
Materializar la configuración no activa nada, porque la aprobación del
servidor es del usuario y la pide su herramienta en la primera sesión
interactiva.

1. Por cada entrada, lee su clave `server`: es el objeto que describe la
   conexión. Si falta, el stack está mal formado; informa del error y no
   inventes la configuración del servidor.
2. Fusiona cada entrada en el `.mcp.json` de la raíz, creándolo si falta, bajo
   `mcpServers` y con `name` como clave. Conserva los que ya estuvieran
   declarados.
3. Si ya existe un servidor con el mismo nombre y valores distintos, no lo
   sustituyas: conserva el existente e informa de la diferencia en el informe.
4. Si la entrada declara `requires`, comprueba si ese archivo existe. Informa
   de su ausencia sin crearlo: lo genera la herramienta del stack, no este
   procedimiento.
5. Registra en la ficha de `AGENTS.md` el sistema de diseño y el servidor que
   sirve su catálogo, o `No se usa` si esa fue la respuesta a P8.
