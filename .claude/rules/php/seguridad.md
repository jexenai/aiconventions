---
paths:
  - "**/*.php"
---
# PHP: seguridad

Al crear o cambiar la autenticación, las contraseñas, Sanctum, las
*policies*, CORS, la subida de ficheros o la configuración de producción, lee
antes `.claude/skills/laravel-security/SKILL.md`, si existe.

- `$fillable` en cada modelo y nunca `$guarded = []` junto con
  `$request->all()`. Crea y actualiza con `$request->validated()`.
- En `DB::raw()`, `whereRaw()` y `selectRaw()`, los valores van como
  *bindings*, nunca interpolados.
- En Blade, `{!! !!}` solo con contenido de confianza; `{{ }}` ya escapa.
- Autoriza con *Policies* o *Gates* (`$this->authorize()`, `can()`).
- Secretos en `.env`, que no se versiona. Documenta las variables nuevas en
  `.env.example` sin valores reales.
