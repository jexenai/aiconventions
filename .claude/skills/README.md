# Procedimientos reutilizables

Consulta este catálogo solo cuando una tarea coincida con uno de sus
procedimientos. No cargues todas las skills al comenzar.

| Procedimiento | Cuándo utilizarlo | Fuente |
| ------------- | ----------------- | ------------ |
| Crear un commit | Cuando el usuario solicita explícitamente crear un commit Git | [commit](commit/SKILL.md) |
| Preparar el contexto | Al adoptar la plantilla, completar campos pendientes o actualizar la estructura documentada | [setup-project-context](setup-project-context/SKILL.md) |
| Decidir sobre OpenSpec | Al adoptar la plantilla o cuando se plantee usar OpenSpec: decisión del usuario y, si procede, instalación e inicialización | [setup-openspec](setup-openspec/SKILL.md) |
| Preparar las pruebas | Cuando a una parte del proyecto le faltan las herramientas para ejecutar sus pruebas o su análisis: instalación con confirmación, pruebas semilla y comandos | [setup-testing](setup-testing/SKILL.md) |
| Liberar una versión | Cuando el usuario pide liberar una versión o generar el manual de usuario: manual con capturas por perfil en `docs/manual/`, novedades, commit y tag, con su revisión antes de cerrar | [liberar-version](liberar-version/SKILL.md) |

## Añadir un procedimiento

Incorpóralo cuando una actividad se repita y necesite siempre las mismas
decisiones o comprobaciones. Cada procedimiento debe indicar:

- Cuándo se utiliza y qué resultado produce.
- Qué información necesita.
- Qué pasos y comprobaciones son importantes.
- Qué acciones quedan fuera de su alcance.

Cada procedimiento es una skill de Claude Code: una carpeta en
`.claude/skills/` con su `SKILL.md` completo y, si las necesita, sus
plantillas al lado. No hay otra copia del contenido. Añade su fila a la
tabla de arriba.

Una skill no necesita un agente para ejecutarse. Delega en uno únicamente si
la tarea requiere aislamiento de contexto, herramientas especializadas o
trabajo paralelo; documenta esa decisión en su `SKILL.md`.

Las skills y los comandos de OpenSpec los genera OpenSpec al instalarlo. No
los copies ni los reimplementes. El comando `/leer_requisitos` sí es de la
plantilla: planifica un documento de requisitos en cambios de OpenSpec y
solo se conserva si el proyecto lo usa.

Las demás skills de esta carpeta (seguridad, pruebas, JPA, accesibilidad y
contratos por stack) no son procedimientos: son referencia técnica. Están
descritas en [docs/diseno.md](../../docs/diseno.md).
