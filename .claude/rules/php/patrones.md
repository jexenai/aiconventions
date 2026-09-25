---
paths:
  - "**/*.php"
---
# PHP: patrones de Laravel

Al crear un endpoint o cambiar uno ya expuesto, lee antes
`.claude/skills/api-design/SKILL.md`, si existe.

## Capas

- Controladores delgados: validan con `FormRequest`, delegan y responden.
- Cada caso de uso con lógica de negocio, en una acción de propósito único
  (`AltaCliente`); un servicio solo si agrupa varios casos de la misma
  funcionalidad. Un CRUD sin reglas de negocio puede quedarse en el
  controlador con su `FormRequest`.
- Respuestas JSON de la API con `JsonResource` o `ResourceCollection`,
  nunca con el modelo directamente. Las páginas de Inertia siguen
  `.claude/rules/inertia/patrones.md`, si existe.

## Eloquent

- Relaciones con `with()` para evitar consultas N+1, y
  `Model::preventLazyLoading()` fuera de producción para detectarlas.
- Listados con `paginate()`, nunca `all()` sin límite.
- *Scopes* para las consultas repetidas y `casts` para tipar atributos.

## Configuración y colas

- `config()` en el código; `env()` solo dentro de `config/`, porque con la
  configuración en caché devuelve `null` fuera de ahí.
- El trabajo lento (correos, integraciones, procesos pesados) va a *jobs*.
