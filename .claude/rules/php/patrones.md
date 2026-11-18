---
paths:
  - "**/*.php"
---
# PHP: patrones de Laravel

Al crear un endpoint o cambiar uno ya expuesto, lee antes
`.claude/skills/api-design/SKILL.md`, si existe. Al crear o cambiar un caso
de uso, un validador, un modelo o una consulta, lee antes
`.claude/skills/laravel-patterns/SKILL.md`, si existe.

## Carpetas

Las carpetas de entidad van en plural y en `PascalCase`, como su espacio de
nombres (`MotivosDenegacion`).

| Carpeta | Contenido |
| ------- | --------- |
| `app/Http/Controllers` | Controladores |
| `app/Http/Requests` | `FormRequest`: formato de la entrada |
| `app/Http/Resources` | Respuestas JSON de la API |
| `app/Actions/{Entidades}` | Casos de uso: `app/Actions/Convocatorias/CrearConvocatoria.php` |
| `app/Validator` | Un validador por modelo: `app/Validator/ConvocatoriaValidator.php` |
| `app/Models` | Modelos Eloquent |

Crea estas solo cuando hagan falta:

| Carpeta | Contenido |
| ------- | --------- |
| `app/Policies` | Autorización por modelo |
| `app/Collections` | Colecciones propias de un modelo (`newCollection()`) o de dominio; no respuestas de la API |
| `app/Enums` | Conjuntos cerrados de valores y constantes compartidas |
| `app/Contracts/{Capacidad}` | Interfaces que comparten varios modelos, solo con dos o más implementaciones reales |
| `app/Http/Middleware` | *Middleware* HTTP |
| `app/Projections` | Modelos de lectura calculados; nunca salen a la API sin un `JsonResource` |

Lo transversal se organiza igual, como una entidad más:
`app/Actions/Auditorias/RegistrarAuditoria.php`.

## Capas

Qué es un caso de uso y un validador, cómo se nombran y qué hace cada uno
está en `comun/organizacion-backend.md`. Aquí, solo lo propio de Laravel:

- Caso de uso: una clase en `app/Actions/{Entidades}`. Toda operación pasa
  por su caso de uso, aunque no tenga reglas. Si escribe en varias tablas,
  usa `DB::transaction()`.
- Validador: una clase por modelo en `app/Validator`. Su excepción de
  dominio es la que el manejador traduce a 422.
- Eloquent es la capa de acceso a datos: no se añaden repositorios. Casos
  de uso y validadores consultan y guardan con los modelos y sus *scopes*;
  los controladores y los `FormRequest` no consultan, y el SQL suelto
  (`DB::select`, `DB::raw`) queda para lo que Eloquent no cubre.
- El caso de uso llama al método del validador justo antes de guardar:
  `$this->convocatoriaValidator->validarCreacion($convocatoria); $convocatoria->save();`.
- El formato de la entrada (obligatorios, longitudes, patrones) lo valida el
  `FormRequest`. Excepción: las
  comprobaciones de existencia y unicidad que Laravel resuelve con una
  regla declarativa (`unique`, `exists`) van también en el `FormRequest`,
  que devuelve el error en su campo. Si la condición tiene lógica de
  negocio (estados, combinaciones, fechas), va al validador.
- Controladores delgados: reciben el `FormRequest`, llaman al caso de uso y
  responden.
- Respuestas JSON de la API con `JsonResource` o `ResourceCollection`,
  nunca con el modelo directamente. Las páginas de Inertia siguen
  `.claude/rules/inertia/patrones.md`, si existe.
- Si la API tiene contrato OpenAPI, se actualiza antes de crear o cambiar
  una operación.

## Eloquent

- Declara siempre `$table` en el modelo, con el plural correcto en español
  (`solicitudes`, `motivos_denegacion`): el pluralizador de Laravel es
  inglés y falla con casi todos los nombres terminados en consonante
  (`solicituds`, `motivo_denegacions`). Lo demás, por la convención de
  Laravel: sin `$primaryKey` ni claves foráneas explícitas en las
  relaciones.
- Relaciones con `with()` para evitar consultas N+1, y
  `Model::preventLazyLoading()` fuera de producción para detectarlas.
- Listados con `paginate()`, nunca `all()` sin límite.
- *Scopes* para las consultas repetidas y `casts` para tipar atributos.

## Configuración y colas

- `config()` en el código; `env()` solo dentro de `config/`, porque con la
  configuración en caché devuelve `null` fuera de ahí.
- El trabajo lento (correos, integraciones, procesos pesados) va a *jobs*.
