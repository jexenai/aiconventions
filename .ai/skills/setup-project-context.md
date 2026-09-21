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
- No instales, inicialices, sincronices ni archives OpenSpec. Este
  procedimiento solo plantea la decisión y la deriva a
  [setup-openspec.md](setup-openspec.md).
- No modifiques código de aplicación ni configuración funcional salvo que el
  usuario amplíe expresamente el alcance. En `AGENTS.md` edita solo su ficha.
- No sobrescribas cambios ajenos ni sustituyas datos existentes sin comprobar
  que han quedado obsoletos.
- No reproduzcas secretos ni datos personales encontrados durante la revisión.
- No apruebes servidores MCP, no los arranques ni instales sus dependencias.
  Materializar su configuración no es activarlos.
- No edites `docs/stack.yaml`: lo genera el plugin a partir de la plantilla de
  stack elegida.

## Recopilar evidencia

1. Lee `AGENTS.md`, el `README` principal, `.ai/project/context.md` y
   `.ai/project/development.md`.
2. Lee `docs/stack.yaml` si existe y aplica la sección
   [Usar el stack declarado](#usar-el-stack-declarado).
3. Comprueba si OpenSpec está inicializado buscando `openspec/config.yaml` o
   el directorio `openspec/`.
4. Revisa el estado de Git para distinguir el contenido existente de cambios
   locales que deban preservarse.
5. Obtén un mapa acotado del repositorio, excluyendo dependencias descargadas,
   binarios generados y resultados de compilación.
6. Consulta únicamente las fuentes necesarias para completar cada dato:
   manifiestos, archivos de bloqueo, scripts, configuración, CI, pruebas,
   contenedores, despliegue y documentación vigente.
7. Comprueba que las rutas y comandos citados existen. Distingue claramente
   entre comandos observados y comandos realmente ejecutados.

Usa primero operaciones de lectura. Solo ejecuta comprobaciones locales rápidas
y sin efectos cuando aporten evidencia necesaria, como consultar la versión de
una herramienta ya instalada.

## Usar el stack declarado

`docs/stack.yaml` recoge el stack estándar que el equipo eligió para el
proyecto. Es la intención declarada, no la prueba de lo implementado. Usa solo
su bloque `context`; ignora `profiles`, `projectRules`, `disabledRules` y las
listas de `skills`, estén en la raíz o dentro de `context.conventions`, porque
no definen procedimientos disponibles en este repositorio. Los procedimientos
reales son los de [.ai/skills/README.md](README.md).

| Clave | Destino | Uso |
| ----- | ------- | --- |
| `context.declared` | Ficha de `AGENTS.md` (tecnologías y versiones) y entornos de ejecución en `context.md` | Documenta directamente. Si los manifiestos o la configuración indican otra versión, informa de la diferencia sin resolverla |
| `context.database` | Persistencia en `context.md` | Declara una sola base de datos. Documéntala tras contrastarla con la configuración; si la configuración apunta a otra, identifícala y, si no puedes, pregunta. Con el valor `N/A`, indica `No aplica` tras comprobar que el repositorio no contiene configuración de base de datos |
| `context.dependencies` | Configuración y dependencias en `context.md` | Dependencias que el estándar exige para el stack. Comprueba si están en el manifiesto e informa de su ausencia sin instalarlas |
| `context.deployment` | Entornos de ejecución y despliegue en `context.md` | Documenta el empaquetado y el destino declarados. Si el manifiesto o el CI producen otro artefacto, informa de la diferencia sin resolverla |
| `context.mcp` | `.mcp.json` de la raíz y ficha de `AGENTS.md` (sistema de diseño) | Servidores MCP que el estándar asocia al stack. Aplica la sección [Materializar los servidores MCP](#materializar-los-servidores-mcp). Si la clave no existe, el stack no usa ninguno |
| `context.conventions.paths` | Ficha de `AGENTS.md` (código de aplicación) y mapa del repositorio en `context.md` | Documenta solo las rutas que existan |
| `context.conventions.generated` | Archivos generados en el mapa del repositorio | Documenta solo los que existan o estén declarados en `.gitignore` |
| `context.conventions.buildTools` | Ficha de `AGENTS.md` (arranque y pruebas) y comandos de `development.md` | Usa la herramienta cuyo `file` exista. Las claves de `commands` son candidatas del estándar, no comandos garantizados: documenta cada una solo si la respaldan sus scripts, un wrapper del repositorio o el CI; si hay wrapper, prefiérelo. Omite las que no puedas respaldar |

El archivo no aporta el propósito, los usuarios, el dominio, las decisiones de
arquitectura ni la seguridad del proyecto. Complétalos con otra evidencia o
mantén el marcador.

Si el repositorio aún no contiene código, documenta los datos de
`context.declared` indicando que proceden de `docs/stack.yaml` y deja
pendientes las rutas y comandos que no puedan comprobarse.

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
  primero; es lo mínimo para trabajar. La fila `Especificaciones` se resuelve
  en el paso siguiente.
- `context.md`: alcance, componentes, mapa, dominio, decisiones de
  arquitectura y seguridad del sistema.
- `development.md`: comandos, convenciones de implementación, comentarios,
  pruebas y entrega.

Mantén cada dato en una única fuente. Enlaza documentos relacionados en lugar
de copiar reglas completas entre ellos.

## Materializar los servidores MCP

Aplica solo si `docs/stack.yaml` declara `context.mcp`. Aquí no hay decisión
que plantear: el equipo la tomó al elegir el stack. Materializar la
configuración tampoco activa nada, porque la aprobación del servidor es del
usuario y la pide su herramienta en la primera sesión interactiva.

1. Por cada entrada, localiza el fragmento indicado en `fragment`. Si no
   existe, informa y no inventes la configuración del servidor.
2. Fusiona sus servidores en el `.mcp.json` de la raíz, creándolo si falta.
   Conserva los que ya estuvieran declarados.
3. Si ya existe un servidor con el mismo nombre y valores distintos, no lo
   sustituyas: informa de la diferencia y deja que el usuario decida.
4. Si la entrada declara `requires`, comprueba si ese archivo existe. Informa
   de su ausencia sin crearlo: lo genera la herramienta del stack, no este
   procedimiento.
5. Registra en la ficha de `AGENTS.md` el sistema de diseño y el servidor que
   sirve su catálogo. Si el stack no declara `context.mcp` y no hay otro
   sistema de diseño documentado, escribe `No se usa`.
6. Recuerda al usuario, en el reporte, que debe aprobar el servidor y que en
   ejecuciones desatendidas se carga sin preguntar.

## Derivar la decisión sobre OpenSpec

Este paso es obligatorio y no puede omitirse: la fila `Especificaciones` es una
decisión de equipo, no un dato deducible del repositorio, y la ficha no puede
cerrarse dejándola sin resolver por omisión.

1. Si `openspec/` existe, registra la versión instalada y no preguntes nada.
2. Si no existe y la fila sigue en `[POR DEFINIR]`, pregunta al usuario si el
   proyecto va a usar OpenSpec. Plantéalo al final, junto con las demás
   decisiones pendientes, para no interrumpir la adaptación documental.
3. Si acepta, sigue [setup-openspec.md](setup-openspec.md). Si lo descarta,
   registra `No se usa`. Si no responde, conserva el marcador y decláralo
   como pendiente en el reporte. `AGENTS.md` volverá a pedir la decisión en la
   siguiente tarea no trivial.

## Comprobación final

1. Busca los marcadores `[POR DEFINIR]` restantes y clasifícalos en el reporte.
   Confirma que la pregunta sobre OpenSpec se ha planteado o que la fila ya
   estaba resuelta.
2. Comprueba que los enlaces y rutas locales añadidos existen.
3. Si el stack declara `context.mcp`, comprueba que `.mcp.json` es JSON válido,
   que conserva los servidores previos y que la ficha coincide con él.
4. Revisa que no se hayan documentado ejemplos como configuración activa.
5. Contrasta los comandos registrados con scripts, manifiestos o CI.
6. Revisa el diff para detectar datos inventados, duplicaciones y cambios fuera
   del alcance documental.

Al terminar, informa de:

- Documentos y secciones completados.
- Si OpenSpec está inicializado o no, y qué decidió el usuario sobre su uso.
- Servidores MCP añadidos a `.mcp.json` y qué aprobación les falta.
- Fuentes utilizadas como evidencia.
- Datos tomados de `docs/stack.yaml` y diferencias con el código.
- Decisiones confirmadas por el usuario.
- Marcadores pendientes y motivo concreto.
- Comprobaciones ejecutadas y limitaciones de la revisión.
