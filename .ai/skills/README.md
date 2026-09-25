# Procedimientos reutilizables

Consulta este catálogo solo cuando una tarea coincida con uno de sus
procedimientos. No cargues todas las skills al comenzar.

| Procedimiento | Cuándo utilizarlo | Fuente común |
| ------------- | ----------------- | ------------ |
| Crear un commit | Cuando el usuario solicita explícitamente crear un commit Git | [commit.md](commit.md) |
| Preparar el contexto | Al adoptar la plantilla, completar campos pendientes o actualizar la estructura documentada | [setup-project-context.md](setup-project-context.md) |
| Decidir sobre OpenSpec | Al adoptar la plantilla o cuando se plantee usar OpenSpec: decisión del usuario y, si procede, instalación e inicialización | [setup-openspec.md](setup-openspec.md) |
| Preparar las pruebas | Cuando a una parte del proyecto le faltan las herramientas para ejecutar sus pruebas o su análisis: instalación con confirmación, pruebas semilla y comandos | [setup-testing.md](setup-testing.md) |
| Comprobar un despliegue de Laravel | Antes de desplegar un proyecto Laravel; solo comprueba, no despliega | [laravel-deploy.md](laravel-deploy.md) |

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

Las skills de código de `.claude/skills/` (seguridad, pruebas, JPA,
accesibilidad y contratos por stack) no son procedimientos: son referencia
técnica solo para Claude Code y no tienen fuente común aquí. Están descritas
en [docs/diseno.md](../../docs/diseno.md).
