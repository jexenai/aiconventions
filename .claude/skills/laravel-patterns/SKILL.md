---
name: laravel-patterns
description: Ejemplos de la arquitectura de Laravel que fijan las reglas - caso de uso, validador de entidad y excepción de dominio, controlador con FormRequest y Resource, y Eloquent como capa de datos (modelo, scopes, relaciones, transacciones) con Oracle. Úsala al crear o cambiar un caso de uso, un validador, un modelo o una consulta.
disable-model-invocation: true
---

# Patrones de Laravel

Complementa `.claude/rules/comun/organizacion-backend.md` y
`.claude/rules/php/patrones.md`, que fijan qué va en cada capa, y
`.claude/rules/php/oracle.md`, si existe. Aquí van los ejemplos. Las pruebas
de cada pieza están en `.claude/skills/laravel-tdd/SKILL.md`.

## Una operación de principio a fin

El controlador recibe la petición ya validada en su formato, llama al caso
de uso y responde. No consulta ni decide.

```php
// app/Http/Controllers/ConvocatoriasController.php
public function store(CrearConvocatoriaRequest $request, CrearConvocatoria $crearConvocatoria): JsonResponse
{
    $convocatoria = $crearConvocatoria->ejecutar($request->validated());

    return ConvocatoriaResource::make($convocatoria)
        ->response()
        ->setStatusCode(201);
}
```

El `FormRequest` valida el formato y lo que Laravel resuelve con una regla
declarativa (`unique`, `exists`). La autorización va en `authorize()` con la
*policy*.

```php
// app/Http/Requests/CrearConvocatoriaRequest.php
public function authorize(): bool
{
    return $this->user()->can('create', Convocatoria::class);
}

public function rules(): array
{
    return [
        'codigo' => ['required', 'string', 'max:20', 'unique:convocatorias,codigo'],
        'titulo' => ['required', 'string', 'max:200'],
        'fecha_inicio' => ['required', 'date'],
        'fecha_fin' => ['required', 'date'],
        'zona_id' => ['required', 'integer', 'exists:zonas,id'],
    ];
}
```

El caso de uso coordina: construye el modelo, delega las reglas en el
validador justo antes de guardar y devuelve el modelo. Recibe los datos
validados, no el `Request`, para poder llamarlo desde un comando o un *job*.

```php
// app/Actions/Convocatorias/CrearConvocatoria.php
namespace App\Actions\Convocatorias;

class CrearConvocatoria
{
    public function __construct(private ConvocatoriaValidator $convocatoriaValidator) {}

    public function ejecutar(array $datos): Convocatoria
    {
        $convocatoria = new Convocatoria($datos);
        $convocatoria->estado = EstadoConvocatoria::Borrador;

        $this->convocatoriaValidator->validarCreacion($convocatoria);
        $convocatoria->save();

        return $convocatoria;
    }
}
```

Si escribe en varias tablas, todo dentro de `DB::transaction()`, con la
validación dentro para que lea el mismo estado que se va a guardar:

```php
public function ejecutar(Convocatoria $convocatoria): Convocatoria
{
    return DB::transaction(function () use ($convocatoria) {
        $this->convocatoriaValidator->validarCierre($convocatoria);

        $convocatoria->estado = EstadoConvocatoria::Cerrada;
        $convocatoria->save();
        $this->registrarAuditoria->ejecutar($convocatoria, AccionAuditada::Cierre);

        return $convocatoria;
    });
}
```

## Validador

Un método público por acción, que se lee como la lista de reglas de esa
acción, y un método privado por regla, con el nombre de la condición de
negocio. Las reglas compartidas se reutilizan, no se copian.

```php
// app/Validator/ConvocatoriaValidator.php
namespace App\Validator;

class ConvocatoriaValidator
{
    public function validarCreacion(Convocatoria $convocatoria): void
    {
        $this->comprobarQueLasFechasSonCoherentes($convocatoria);
    }

    public function validarModificacion(Convocatoria $convocatoria): void
    {
        $this->comprobarQueLaConvocatoriaEsModificable($convocatoria);
        $this->comprobarQueLasFechasSonCoherentes($convocatoria);
    }

    public function validarBorrado(Convocatoria $convocatoria): void
    {
        $this->comprobarQueLaConvocatoriaEsModificable($convocatoria);
        $this->comprobarQueNoTieneSolicitudes($convocatoria);
    }

    private function comprobarQueLaConvocatoriaEsModificable(Convocatoria $convocatoria): void
    {
        if ($convocatoria->estado === EstadoConvocatoria::Cerrada) {
            throw new ReglaDeNegocioException('Una convocatoria cerrada no se puede modificar ni borrar.');
        }
    }

    private function comprobarQueLasFechasSonCoherentes(Convocatoria $convocatoria): void
    {
        if ($convocatoria->fecha_fin->lt($convocatoria->fecha_inicio)) {
            throw new ReglaDeNegocioException('La fecha de fin no puede ser anterior a la de inicio.');
        }
    }

    // Regla que depende del estado persistido: consulta con el modelo.
    private function comprobarQueNoTieneSolicitudes(Convocatoria $convocatoria): void
    {
        if ($convocatoria->solicitudes()->exists()) {
            throw new ReglaDeNegocioException('La convocatoria tiene solicitudes y no se puede borrar.');
        }
    }
}
```

## Excepción de dominio

Una excepción propia del proyecto, en `app/Exceptions`, que el manejador
traduce a 422 con el formato de error de la API (sección "API" de
`development.md`). Si el proyecto ya tiene la suya, usa esa.

```php
// app/Exceptions/ReglaDeNegocioException.php
class ReglaDeNegocioException extends \DomainException {}

// bootstrap/app.php
->withExceptions(function (Exceptions $exceptions) {
    $exceptions->render(function (ReglaDeNegocioException $e, Request $request) {
        if ($request->expectsJson()) {
            return response()->json(['message' => $e->getMessage()], 422);
        }
    });
})
```

## Modelo

```php
// app/Models/Convocatoria.php
class Convocatoria extends Model
{
    // El pluralizador de Laravel es inglés: la tabla se declara siempre.
    protected $table = 'convocatorias';

    protected $fillable = ['codigo', 'titulo', 'fecha_inicio', 'fecha_fin', 'zona_id'];

    protected function casts(): array
    {
        return [
            'estado' => EstadoConvocatoria::class,
            'fecha_inicio' => 'date',
            'fecha_fin' => 'date',
            // Oracle no tiene BOOLEAN: la columna guarda 0 o 1.
            'publicada' => 'boolean',
        ];
    }

    public function zona(): BelongsTo
    {
        return $this->belongsTo(Zona::class);
    }

    public function solicitudes(): HasMany
    {
        return $this->hasMany(Solicitud::class);
    }

    // Consulta repetida: scope con nombre del dominio.
    public function scopeAbiertas(Builder $consulta): Builder
    {
        return $consulta->where('estado', EstadoConvocatoria::Abierta);
    }
}
```

`estado` no está en `$fillable`: lo cambia un caso de uso, no la petición.

## Consultas

Las lecturas también son casos de uso. Cargan las relaciones que la
respuesta pinta y paginan siempre.

```php
// app/Actions/Convocatorias/BuscarConvocatoriasConFiltros.php
public function ejecutar(array $filtros): LengthAwarePaginator
{
    return Convocatoria::query()
        ->with('zona')
        ->when($filtros['estado'] ?? null, fn (Builder $c, string $estado) => $c->where('estado', $estado))
        ->when($filtros['texto'] ?? null, fn (Builder $c, string $texto) => $c->whereRaw(
            'UPPER(titulo) LIKE ?',
            ['%'.mb_strtoupper($texto).'%'],
        ))
        ->orderBy('fecha_inicio', 'desc')
        ->paginate($filtros['por_pagina'] ?? 20);
}
```

- `when()` para los filtros opcionales, en lugar de `if` que rompen la
  cadena.
- La búsqueda de texto lleva `UPPER()` a los dos lados: en Oracle `LIKE`
  distingue mayúsculas y en SQLite no, así que sin ello la prueba pasaría en
  local y fallaría en producción.
- El valor va como *binding* (`?`), nunca interpolado.
- En `AppServiceProvider::boot()`,
  `Model::preventLazyLoading(! app()->isProduction())` hace fallar en
  desarrollo y en pruebas cualquier relación que se cargue sin `with()`.

Una lista `IN` grande se divide, porque Oracle admite 1000 elementos:

```php
$solicitudes = collect($identificadores)
    ->chunk(1000)
    ->flatMap(fn (Collection $lote) => Solicitud::whereIn('id', $lote)->get());
```

Para recorrer muchas filas, `chunkById()` o `lazyById()`, nunca `all()`.

## Antes de dar por terminada una operación

- El controlador no tiene `if` de negocio ni consultas.
- Cada regla de negocio está en un método privado del validador con nombre
  de condición, y ninguna se repite entre acciones.
- El caso de uso llama al validador justo antes de guardar.
- La respuesta sale de un `JsonResource`, no del modelo.
- Las relaciones que se pintan se cargan con `with()`.
