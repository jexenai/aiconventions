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
- En el backend, la lógica de dominio vive solo en los casos de uso y en el
  validador de cada entidad. Controladores, modelos, mappers, DTO,
  repositorios y el resto son auxiliares: no deciden reglas de negocio.
- Un caso de uso por operación, con el formato
  `Verbo+Entidad+PosibleDetalle` y sin sufijos como `Service`. En el backend
  es una clase en `PascalCase`: `services/tramites/BuscarTramitePorIdentificador`,
  `services/usuarios/CrearUsuario`,
  `services/consejerias/BuscarConsejeriasConFiltros`. En React es una
  función de API en `camelCase` (`crearUsuario`; ver `react/patrones.md`).
- Cada caso de uso es breve y hace una sola cosa: así es reutilizable y un
  humano lo entiende sin esfuerzo. Escríbelo con el vocabulario funcional
  acordado (`architecture.md`), no con términos técnicos que el negocio no
  usaría, y reutiliza otros casos de uso antes de repetir sus pasos.

  > Aclaración: si `ejecutar` no cabe en una pantalla, es una señal de que
  > conviene extraer un paso a otro caso de uso.

- Las reglas de negocio de una entidad van en su validador
  (`TramiteValidator`), en su propia carpeta, con un método público por
  acción (`validarCreacion`, `validarModificacion`, `validarBorrado`). El
  caso de uso no comprueba reglas: delega en el método correspondiente del
  validador, justo antes de guardar, y se mantiene centrado en coordinar el
  caso de uso. El formato de la entrada (obligatorios, longitudes,
  patrones) se valida en el límite: contrato, petición o formulario.

## Diseño

Escribe para que lo entienda sin esfuerzo un desarrollador senior de nivel
medio, no uno avanzado.

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
- El acceso a datos y a servicios externos vive en su capa (repositorio,
  cliente de API) y el resto depende de ella, no del ORM o del SDK
  directamente. Interfaces pequeñas y específicas; si hay varias
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
