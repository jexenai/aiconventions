---
paths:
  - "**/*.java"
---
# Java: DTO y mapeo

Antes de crear o cambiar un mapper, lee
`.claude/skills/openapi-mapstruct/SKILL.md`, si existe.

- Los DTO de la API solo salen del contrato OpenAPI mediante
  `openapi-generator`. No escribas DTO a mano (ni `record`, ni clases, ni
  proyecciones expuestas) y no edites los generados: si cambia su forma,
  cambia primero el contrato.
- Todo mapeo entre entidad y DTO, en los dos sentidos, se hace con MapStruct,
  usando la dependencia y el procesador ya configurados en `pom.xml` o
  `build.gradle`. No escribas conversiones manuales para sustituir un mapper
  ni añadas otra dependencia de mapeo. Un `@Mapper` por entidad en `mappers/`
  con la configuración compartida (`config = MapeoConfig.class`, también en
  `mappers/`; si no existe, créala según la skill): lectura (`toDto`), alta
  (`toEntidad`, con el `builder()` de la entidad) y modificación
  (`actualizar` con `@MappingTarget`). Nada de construir, rellenar o copiar
  campos a mano en controladores, casos de uso ni validadores, ni con
  métodos `default` en el mapper. Regístralos como beans de Spring
  (`componentModel = "spring"` en `MapeoConfig`).
- Con `@Builder` en la entidad, MapStruct construye el alta a través del
  *builder*: `id`, `version` y los campos de auditoría
  (`.claude/skills/jpa-patterns/SKILL.md`) no llegan del DTO, así que
  `toEntidad` los declara con `ignore = true`.
- Los campos sin equivalente se declaran con
  `@Mapping(target = "...", ignore = true)` y un comentario que explique por
  qué. No relajes la `unmappedTargetPolicy = ERROR` de `MapeoConfig`.
- Si el contrato transporta fechas o importes como texto con un formato
  propio, conviértelos con `expression` y el conversor del proyecto
  (convenciones de `development.md`), nunca con la conversión implícita de
  MapStruct.
