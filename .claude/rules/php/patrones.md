---
paths:
  - "**/*.php"
---
# PHP: patrones de Laravel

Al crear un endpoint o cambiar uno ya expuesto, lee antes
`.claude/skills/api-design/SKILL.md`, si existe.

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

- La lógica de dominio vive solo en `app/Actions` y en el validador de
  `app/Validator`. Controladores, `FormRequest`, `Resource`, modelos y
  *middleware* no deciden reglas de negocio.
- Caso de uso: una clase por operación, con el nombre
  `Verbo+Entidad+PosibleDetalle` (`CrearConvocatoria`,
  `BuscarConvocatoriaPorIdentificador`, `BuscarConvocatoriasConFiltros`,
  `CerrarConvocatoria`), con un único método público `ejecutar()`. Toda
  operación pasa por su caso de uso, aunque no tenga reglas. Si escribe en
  varias tablas, usa `DB::transaction()`. Es breve y se lee con el
  vocabulario funcional del dominio (`comun/estilo-codigo.md`); no comprueba
  reglas de negocio, las delega en el validador.
- Validador: una única clase por modelo, con el sufijo `Validator`
  (`ConvocatoriaValidator`). Expone un método público por acción que
  necesita validación, con un nombre legible desde el dominio
  (`validarCreacion`, `validarModificacion`, `validarBorrado`); cada uno
  compone las reglas aplicables a la acción, en su orden de lectura. Cada
  regla compartida o atómica es un método privado con un nombre que expresa
  la condición de negocio (`comprobarQueLaConvocatoriaEsModificable`),
  reutilizado desde los métodos públicos: nunca dupliques una comprobación
  entre acciones. Puede depender de repositorios o *query builders* cuando
  una regla necesite comprobar estado persistido. Informa del incumplimiento
  con la excepción de dominio que el manejador traduce a 422, con un mensaje
  que identifica la regla vulnerada.
- El caso de uso llama al método del validador justo antes de guardar:
  `$this->convocatoriaValidator->validarCreacion($convocatoria); $convocatoria->save();`.
- El formato de la entrada (obligatorios, longitudes, patrones) lo valida el
  `FormRequest`; el validador no lo repite, solo las condiciones que
  dependen del dominio, de su estado o de otros datos. Excepción: las
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

- Nombres por la convención de Laravel: sin `$table`, `$primaryKey` ni
  claves foráneas explícitas en las relaciones. Si el plural que genera
  Laravel no es correcto en español (`motivo_denegacions`), declara `$table`
  en ese modelo con un comentario que lo explique.
- Relaciones con `with()` para evitar consultas N+1, y
  `Model::preventLazyLoading()` fuera de producción para detectarlas.
- Listados con `paginate()`, nunca `all()` sin límite.
- *Scopes* para las consultas repetidas y `casts` para tipar atributos.

## Configuración y colas

- `config()` en el código; `env()` solo dentro de `config/`, porque con la
  configuración en caché devuelve `null` fuera de ahí.
- El trabajo lento (correos, integraciones, procesos pesados) va a *jobs*.
