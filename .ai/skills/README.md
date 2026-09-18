# Procedimientos reutilizables

Consulta este catálogo solo cuando una tarea coincida con uno de sus
procedimientos. No cargues todas las skills al comenzar.

| Procedimiento | Cuándo utilizarlo | Fuente común |
| ------------- | ----------------- | ------------ |
| Crear un commit | Cuando el usuario solicita explícitamente crear un commit Git | [commit.md](commit.md) |
| Preparar el contexto | Al adoptar la plantilla, completar campos pendientes o actualizar la estructura documentada | [setup-project-context.md](setup-project-context.md) |

## Añadir un procedimiento

Incorpóralo cuando una actividad se repita y necesite siempre las mismas
decisiones o comprobaciones. Cada procedimiento debe indicar:

- Cuándo se utiliza y qué resultado produce.
- Qué información necesita.
- Qué pasos y comprobaciones son importantes.
- Qué acciones quedan fuera de su alcance.

Mantén el contenido común en `.ai/skills/` y crea únicamente adaptadores
mínimos en las ubicaciones nativas:

| Herramienta | Directorio de skills |
| ----------- | -------------------- |
| Claude Code | `.claude/skills/` |
| Codex | `.agents/skills/` |

Una skill no necesita un agente para ejecutarse. Delega en uno únicamente si
la tarea requiere aislamiento de contexto, herramientas especializadas o
trabajo paralelo; documenta esa decisión en el adaptador nativo correspondiente.

Las skills de OpenSpec las genera OpenSpec. No las copies ni las reimplementes.
