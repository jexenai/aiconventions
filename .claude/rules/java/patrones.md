---
paths:
  - "**/*.java"
---
# Java: patrones de Spring Boot

Al crear un endpoint o cambiar uno ya expuesto, lee antes
`.claude/skills/api-design/SKILL.md`, si existe. Al crear o cambiar una
entidad, un repositorio o una consulta, lee antes
`.claude/skills/jpa-patterns/SKILL.md`, si existe.

## Paquetes

Bajo el paquete raíz de la aplicación. Las carpetas de entidad van en plural,
en minúsculas y sin separadores (`motivosdenegacion`).

| Paquete | Contenido |
| ------- | --------- |
| `controllers` | Controladores REST |
| `actions/{entidades}` | Casos de uso: `actions/convocatorias/CrearConvocatoria` |
| `validator` | Un validador por entidad: `validator/ConvocatoriaValidator` |
| `models` | Entidades JPA y sus `enum` |
| `mappers` | Mappers de MapStruct y `MapeoConfig` (`datos.md`) |
| `repositories` | Repositorios de Spring Data |
| `configurations` | Configuración y `@RestControllerAdvice`; las excepciones, en `configurations/exceptions` |

Crea estos solo cuando hagan falta:

| Paquete | Contenido |
| ------- | --------- |
| `auth` | Usuario autenticado y datos de identidad propios de la aplicación |
| `collections` | Colecciones de dominio con comportamiento propio (árboles, agrupaciones); no respuestas de la API |
| `constants` | Valores literales compartidos (perfiles, mensajes) en clases `final` con constructor privado. Un conjunto cerrado de valores es un `enum` en `models` |
| `interfaces/{capacidad}` | Capacidades que comparten varias entidades (`interfaces/deshabilitable/Deshabilitable`), solo con dos o más implementaciones reales |
| `middlewares` | `HandlerInterceptor` y filtros HTTP |
| `projections` | Modelos de lectura: proyecciones de Spring Data o datos calculados en memoria. Nunca salen a la API |

Lo transversal se organiza igual, como una entidad más:
`actions/auditorias/RegistrarAuditoria`.

## Capas

Qué es un caso de uso y un validador, cómo se nombran y qué hace cada uno
está en `comun/organizacion-backend.md`. Aquí, solo lo propio de Spring Boot:

- Caso de uso: una clase `@Service` en `actions/{entidades}`. Recibe el DTO
  de entrada, lo convierte con el mapper, carga las referencias con su
  repositorio y devuelve la entidad. Lleva `@Transactional` (con
  `readOnly = true` en las lecturas); nunca transacciones en controladores.
- Que el caso de uso reciba el DTO generado es deliberado: es el contrato
  de entrada y evita mantener un tercer modelo. Si otro caso de uso o un
  proceso sin HTTP (tarea programada, mensaje) necesita la misma operación,
  no construyas un DTO para llamarlo: extrae el paso común a un caso de uso
  que reciba la entidad o los valores del dominio, y el que recibe el DTO
  delega en él.
- Validador: una clase `@Component` en `validator`. Para las reglas que
  dependen del estado persistido, usa repositorios y otros componentes de
  lectura.
- La autorización (rol y propiedad del recurso) no es regla de negocio y no
  va en el validador: `@PreAuthorize` en `ejecutar` o, si necesita la
  entidad cargada, en el caso de uso tras cargarla
  (`.claude/skills/springboot-security/SKILL.md`, si existe).
- El caso de uso llama al método del validador justo antes de guardar:
  `convocatoriaValidator.validarCreacion(convocatoria); repositorio.save(convocatoria);`.
- El formato de la entrada (obligatorios, longitudes, patrones) lo declara
  el contrato OpenAPI y lo aplica Bean Validation al entrar en el
  controlador.
- Controlador: HTTP, sin lógica. Recibe el DTO, llama al caso de uso y
  convierte el resultado con el mapper.
- Repositorio: acceso a datos, sin reglas de negocio.
- `JdbcTemplate` solo para consultas que JPA no cubre (p. ej. objetos de
  base de datos fuera del modelo de entidades), siempre dentro de un
  repositorio. Al insertar con `KeyHolder`, pide la columna de la clave
  (`new String[] {"ID"}`) y protege `getKey()` con `Objects.requireNonNull`
  y un mensaje que diga qué inserción no devolvió su identificador.
- El contrato OpenAPI se actualiza antes de crear o cambiar una operación, y
  el código se implementa después sobre las interfaces generadas.
- La API devuelve DTO generados del contrato y rellenados con MapStruct
  (`datos.md`), nunca entidades JPA ni proyecciones.
- Errores centralizados en `@RestControllerAdvice`, que traduce cada
  excepción de dominio a su código HTTP y los errores de Bean Validation a
  422 (`api-design`).

## Inyección y configuración

- Inyección por constructor con campos `final`; nunca `@Autowired` en campos.
- Configuración en clases `@ConfigurationProperties` tipadas, no en `@Value`
  repartidos.

## JPA

- Entidades con el nombre del dominio, sin sufijo `Entity` ni variantes, en
  `models/`. Son modelos de persistencia de soporte, sin reglas de negocio
  ni métodos que decidan si una operación está permitida: eso es del
  validador. Sin campos que el contrato o el esquema no requieran.
- Nombres de tablas, columnas y secuencias por la convención de Spring Boot:
  sin `@Table`, sin `name` en `@Column` ni en `@JoinColumn` y sin
  `@SequenceGenerator`. `ConvocatoriaParametro` se guarda en la tabla
  `convocatoria_parametro`, `fechaInicio` en la columna `fecha_inicio`, la
  relación `zona` en `zona_id`, y el identificador usa la secuencia
  `convocatoria_parametro_seq`. Las migraciones crean esos nombres.
  Excepciones, con `name` explícito y un comentario que lo explique: una
  tabla heredada que no sigue la convención, o un nombre que resultaría ser
  una palabra reservada de la base de datos (`oracle.md`, si existe).
- Relaciones `LAZY`. Carga lo necesario con `JOIN FETCH` o `@EntityGraph`
  para evitar consultas N+1.
- Listados paginados con `Pageable` y `Page<T>`.
- `CascadeType.ALL` y `orphanRemoval` solo si el hijo no existe sin el padre.
