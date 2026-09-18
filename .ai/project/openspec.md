# OpenSpec

OpenSpec es opcional. Consulta este documento solo para configurarlo o trabajar
con una especificación o un cambio suyo.

## Responsabilidades

| Contenido | Fuente |
| --------- | ------ |
| Reglas comunes | `AGENTS.md` |
| Contexto estable | `.ai/project/` |
| Comportamiento aceptado | `openspec/specs/` |
| Propuesta, diseño y tareas de un cambio | `openspec/changes/<cambio>/` |
| Procedimientos y configuración | Integración instalada y `openspec/config.yaml` |

Versión adoptada: [POR DEFINIR].

## Preparación

1. Instala OpenSpec siguiendo su documentación oficial.
2. Ejecuta `openspec init` en la raíz y selecciona las herramientas utilizadas.
3. Revisa los archivos generados antes de versionarlos.
4. Mantén breve el contexto de `openspec/config.yaml`. Un ejemplo mínimo es:

```yaml
schema: spec-driven

context: |
  Las reglas comunes están en AGENTS.md.
  La documentación estable está en .ai/project/.
  Lee solo el contexto y los artefactos necesarios para el cambio.
```

No inicialices OpenSpec como requisito de una tarea que no lo necesite ni
sobrescribas una instalación existente.

## Trabajo con cambios

- Identifica el cambio por nombre o por correspondencia inequívoca. Si hay
  varios candidatos, pregunta cuál corresponde.
- Usa el workflow instalado y respeta sus artefactos y dependencias.
- Implementa desde las tareas y el diseño del cambio, no desde un plan paralelo.
- Consulta solo las especificaciones relacionadas y evita el histórico salvo
  que exista una dependencia concreta.
- No presentes una propuesta como comportamiento vigente.

## Verificación y cierre

Antes de archivar:

1. Comprueba tareas y artefactos requeridos.
2. Verifica la implementación frente a requisitos, escenarios y diseño.
3. Ejecuta las pruebas y revisiones aplicables.
4. Sincroniza las especificaciones mediante el workflow instalado.
5. Archiva después de resolver o documentar las discrepancias.

Archivar o marcar tareas no demuestra que el comportamiento sea correcto. No
copies los workflows generados en `AGENTS.md` ni en `.ai/skills/`.
