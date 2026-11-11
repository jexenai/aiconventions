---
paths:
  - "**/*.{java,php,js,jsx,ts,tsx}"
---
# Pautas comunes de código

Las convenciones propias del proyecto, en
[development.md](../../../.ai/project/development.md), prevalecen sobre estas
pautas y sobre las de cada lenguaje.

## Al cambiar código

- Lee el código afectado y sus pruebas, y comprueba que los símbolos y
  dependencias existen antes de usarlos.
- Haz cambios pequeños y completos. Si el módulo ya sigue una convención,
  respétala.
- Usa solo características de las versiones de lenguaje y framework del
  proyecto (manifiesto y ficha de `AGENTS.md`).
- Aplica el formateador y el análisis estático del proyecto, sin reformatear
  ficheros que no estás modificando.
- Al corregir un fallo, añade una prueba de regresión. Si una prueba falla,
  distingue si el problema es nuevo, previo o del entorno, y nunca la
  desactives para dar algo por bueno.

## Organización

La estructura de carpetas concreta de cada stack está en su `patrones.md`.

- El dominio se agrupa por entidad, con la carpeta en plural
  (`convocatorias/`).
- Un caso de uso por operación, con el formato
  `Verbo+Entidad+PosibleDetalle` y sin sufijos como `Service`. En el backend
  es una clase en `PascalCase` (`CrearUsuario`; ver
  `comun/organizacion-backend.md`). En React es una función de API en
  `camelCase` (`crearUsuario`; ver `react/patrones.md`).
- Cada caso de uso es breve y hace una sola cosa: así es reutilizable y un
  humano lo entiende sin esfuerzo. Escríbelo con el vocabulario funcional
  acordado (`architecture.md`), no con términos técnicos que el negocio no
  usaría, y reutiliza otros casos de uso antes de repetir sus pasos.
- El formato de la entrada (obligatorios, longitudes, patrones) se valida en
  el límite: contrato, petición o formulario.

## Diseño

Escribe para que cualquier desarrollador con experiencia lo entienda en una
primera lectura, sin tener que descifrarlo. Nada rebuscado: ni trucos del
lenguaje o del framework que haya que conocer de antemano, ni construcciones
que obliguen a seguir varios saltos para saber qué ocurre. Ante dos
soluciones correctas, elige la que se explica sola.

- Código explícito y lineal, y una responsabilidad por función.
- Nombres descriptivos completos (`jugadorActual`, no `ja` ni `flag`).
- Nada de abstracciones especulativas ni «ingeniosas» que ahorran tres líneas
  y cuestan diez minutos de estudio, ni soluciones provisionales que haya que
  rehacer enseguida. Extrae la lógica repetida solo cuando la repetición sea
  real.
- Un bucle claro antes que cadenas largas o anidadas de `map`, `filter` o
  `reduce`: si necesitan un comentario para entenderse, usa el bucle.
- Retornos anticipados en lugar de anidar; constantes con nombre en lugar de
  números o textos con significado.
- Prefiere datos inmutables: devuelve valores nuevos en lugar de modificar
  parámetros o estado compartido.
- El acceso a datos y a servicios externos vive en su capa (repositorio o
  cliente de API; en Laravel, los modelos Eloquent, ver `php/patrones.md`)
  y el resto depende de ella, no de SQL suelto ni del SDK directamente.
  Interfaces pequeñas y específicas; si hay varias
  implementaciones, deben poder sustituirse sin romper a quien las usa.
- No ocultes fallos con capturas genéricas ni con valores de sustitución.
  Si absorbes un error a propósito, comenta por qué.

> Aclaración: SOLID es una guía, no un dogma. Si aplicarlo añade complejidad
> sin beneficio claro, prioriza lo simple y deja un comentario explicándolo.

> Aclaración: más de 50 líneas por función, 800 por fichero o cuatro niveles
> de anidamiento suelen indicar que conviene dividir. No son límites
> estrictos.

## Dependencias, generados y comentarios

- Mantén coherentes manifiestos y ficheros de bloqueo al cambiar
  dependencias.
- No edites ficheros generados si hay una fuente o un comando para
  regenerarlos.
- Comenta el porqué, no lo que ya dice el código. Comenta siempre los
  *workarounds* y las decisiones que parezcan raras a primera vista. Elimina
  los comentarios obsoletos y el código comentado: el historial lo guarda.
- Si el proyecto usa Sonar, sus avisos se corrigen en el código. Los que
  resulten ser falsos positivos se marcan en Sonar con el motivo, no con
  `// NOSONAR`, salvo que no haya otra opción: así el código no se llena de
  marcas y la justificación queda en el panel.
