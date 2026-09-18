# Crear un commit

Utiliza este procedimiento únicamente cuando el usuario solicite de forma
explícita crear un commit. La petición de commit no autoriza a hacer push,
publicar, desplegar ni incluir cambios ajenos al alcance indicado.

## Preparación

1. Revisa `git status`, el resumen de cambios y el historial reciente para
   conocer el estado real y las convenciones del repositorio.
2. Examina el diff necesario para entender los cambios de texto. Evita cargar
   contenido binario completo cuando el resumen y los nombres sean suficientes.
3. Comprueba si aparecen secretos, credenciales, datos personales, archivos de
   entorno o artefactos que no deban versionarse. Detén su inclusión e informa
   al usuario si existe algún riesgo.
4. Distingue los cambios de la tarea de modificaciones previas o ajenas. Si el
   alcance del commit no puede determinarse con seguridad, acláralo antes de
   preparar el área de staging.

## Preparación del commit

1. Añade explícitamente las rutas que pertenecen al commit. No uses `git add .`
   ni `git add -A` sin haber verificado antes todo su alcance.
2. Revisa `git status` y `git diff --cached` después del staging. Confirma que
   no falte ningún archivo necesario y que no se haya incluido nada accidental.
3. Ejecuta `git diff --cached --check` para detectar errores de whitespace.
4. Respeta las comprobaciones obligatorias del proyecto y los hooks de Git. No
   los desactives para conseguir que el commit termine correctamente.

## Mensaje

Sigue Conventional Commits salvo que el repositorio documente otra convención:

```text
<tipo>[(ámbito opcional)]: <resumen>

<descripción breve opcional>
```

- Selecciona el tipo por el propósito principal del cambio: `feat`, `fix`,
  `docs`, `chore`, `refactor`, `style`, `test`, `build`, `ci`, `perf` o `revert`.
- Usa un ámbito solo cuando ayude a localizar claramente el área afectada.
- Redacta un resumen concreto, sin punto final y en el idioma establecido por
  el proyecto.
- Añade cuerpo cuando sea útil explicar qué cambió, efectos relevantes,
  migraciones o relación con una especificación o tarea.
- No añadas trailers de autoría, modelos o herramientas salvo que el usuario o
  las normas del repositorio lo exijan expresamente.

Cuando el mensaje tenga cuerpo o caracteres que puedan sufrir por el shell,
escríbelo en UTF-8 y usa `git commit -F <archivo>`.

## Verificación

Después del commit:

1. Comprueba `git status` para identificar lo que haya quedado pendiente.
2. Revisa el mensaje creado con `git log -1 --pretty=%B`.
3. Informa del commit resultante y de cualquier cambio que se haya dejado fuera
   deliberadamente.

## Límites

- No crees commits vacíos.
- No hagas `git push` como parte de este procedimiento.
- No uses `--amend`, `--no-verify` ni desactives la firma sin petición explícita.
- Si un hook falla, comprueba primero si el commit llegó a crearse antes de
  corregir y reintentar. No reescribas historial por iniciativa propia.
