---
name: "Leer requisitos"
description: "Lee los requisitos de docs/, los planifica en changes de OpenSpec con hitos mostrables y documenta el orden y las dependencias"
argument-hint: "[ruta del documento de requisitos, opcional]"
allowed-tools: Bash(openspec:*)
category: "Workflow"
---

Planifica los requisitos del proyecto como una serie de changes de OpenSpec.

**Entrada**: `$ARGUMENTS`. Si trae una ruta, usa ese documento. Si viene
vacío, usa los documentos de requisitos de `docs/` (Markdown; ignora
ficheros de configuración como `stack.yaml`). Si hay más de un documento
candidato y no está claro cuál es, pregunta antes de seguir.

**Límite**: esta tarea solo planifica. No modifiques código de la aplicación
ni empieces la implementación de ningún change.

## Pasos

1. **Lee los requisitos completos** del documento, incluidos anexos, requisitos
   no funcionales y casos de prueba. Revisa también `openspec/specs/` y
   `openspec/changes/` (sin el histórico de `archive/` salvo que haga falta)
   para no duplicar capacidades ni changes que ya existan.

2. **Divide en changes**. Cada change debe cerrar un hito funcional o
   mostrable: al terminarlo, algo se puede ejecutar, probar o enseñar
   (una pantalla, un flujo, un cálculo verificable con pruebas...). Criterios:
   - Evita changes puramente técnicos sin resultado visible; si una base
     técnica es imprescindible (autenticación, modelo de datos), asóciala al
     primer hito que la usa.
   - Tamaño manejable: que cada uno pueda implementarse y revisarse por
     separado.
   - Cada requisito (RM-xx, RF-xx, anexos, no funcionales) debe quedar
     cubierto por al menos un change. Señala los que no encajen.
   - Nombres en kebab-case, descriptivos.

   No pidas confirmación de la división: decide con los criterios anteriores
   y continúa. Solo pregunta si una ambigüedad del documento impide decidir
   y elegir resulte arriesgado; en lo demás, toma la opción más razonable y
   anótala como suposición.

3. **Crea todos los changes con el workflow `openspec-propose`** (el mismo
   de `/opsx:propose`), en orden de dependencias y sin detenerte entre uno y
   otro, generando todos sus artefactos hasta dejarlos listos para
   `/opsx:apply`. En la propuesta de cada change indica de qué changes
   depende y qué requisitos del documento cubre. Valida cada uno con
   `openspec validate <nombre>` y corrige los errores antes de pasar al
   siguiente. Comprueba con `openspec status --change <nombre>` que todos
   sus artefactos quedan completos.

4. **Muestra el resumen final** en la conversación:
   - Lista de changes en orden de implementación.
   - Para cada uno: hito mostrable, requisitos cubiertos y dependencias.
   - Requisitos no cubiertos o suposiciones tomadas, si los hay.

5. **Actualiza el documento de requisitos** añadiendo al final una sección
   `## Plan de implementación (OpenSpec)`. Si ya existe, sustitúyela en lugar
   de duplicarla. No modifiques el resto del documento. Contenido:

   - Una tabla con este formato:

     | Orden | Change | Hito mostrable | Requisitos | Depende de |
     | ----- | ------ | -------------- | ---------- | ---------- |
     | 1 | `nombre-del-change` | Qué se puede enseñar al terminar | RM-01, RF-01 | — |

   - Un diagrama Mermaid descendente con las dependencias, del primer change
     arriba a los últimos abajo; cada flecha va del change previo al que
     depende de él:

     ```mermaid
     flowchart TD
       A[1. nombre-change-a] --> B[2. nombre-change-b]
       A --> C[3. nombre-change-c]
     ```

6. Al terminar, indica qué changes se crearon, qué validaciones pasaron y qué
   queda pendiente. Recuerda al usuario que puede lanzar `/opsx:apply
   <nombre>` sobre el change que le interese, siempre que los changes de
   los que depende ya estén implementados.
