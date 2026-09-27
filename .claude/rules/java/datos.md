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
- Todo mapeo entre entidad y DTO, en los dos sentidos, se hace en un
  `@Mapper` de MapStruct con la configuración compartida
  (`config = MapeoConfig.class`; si no existe, créala según la skill):
  lectura (`toDto`), alta (`toEntidad`, con el constructor de la entidad) y
  modificación (`actualizar` con `@MappingTarget`). Nada de construir,
  rellenar o copiar campos a mano en controladores ni en servicios, ni con
  métodos `default` en el mapper.
- En las entidades, `@Setter` solo en los campos que el contrato permite
  modificar; nunca en `id`, `version` ni en campos `updatable = false`.
- Los campos sin equivalente se declaran con
  `@Mapping(target = "...", ignore = true)` y un comentario que explique por
  qué. No relajes la `unmappedTargetPolicy = ERROR` de `MapeoConfig`.
- Si el contrato transporta fechas o importes como texto con un formato
  propio, conviértelos con `expression` y el conversor del proyecto
  (convenciones de `development.md`), nunca con la conversión implícita de
  MapStruct.
