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
| `services/{entidades}` | Casos de uso: `services/convocatorias/CrearConvocatoria` |
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
`services/auditorias/RegistrarAuditoria`.

## Capas

- La lógica de dominio vive solo en `services` y en el validador de
  `validator`. Controladores, entidades, mappers, DTO, repositorios e
  interceptores no deciden reglas de negocio.
- Caso de uso: una clase `@Service` por operación, con el nombre
  `Verbo+Entidad+PosibleDetalle` (`CrearConvocatoria`,
  `BuscarConvocatoriaPorIdentificador`, `BuscarConvocatoriasConFiltros`,
  `CerrarConvocatoria`), sin sufijo, y un único método público `ejecutar`.
  Recibe el DTO de entrada, lo convierte con el mapper, carga las
  referencias con su repositorio y devuelve la entidad. Lleva
  `@Transactional` (con `readOnly = true` en las lecturas); nunca
  transacciones en controladores. Es breve y se lee con el vocabulario
  funcional del dominio (`comun/estilo-codigo.md`); no comprueba reglas de
  negocio, las delega en el validador.
- Validador: una única clase `@Component` por entidad, con el sufijo
  `Validator` (`ConvocatoriaValidator`). Expone un método público por
  acción que necesita validación, con un nombre legible desde el dominio
  (`validarCreacion`, `validarModificacion`, `validarBorrado`); cada uno
  compone las reglas aplicables a la acción, en su orden de lectura. Cada
  regla compartida o atómica es un método privado con un nombre que
  expresa la condición de negocio (`comprobarQueLaConvocatoriaEsModificable`),
  reutilizado desde los métodos públicos: nunca dupliques una comprobación
  entre acciones. Puede depender de repositorios y de otros componentes de
  lectura cuando una regla necesite comprobar estado persistido. Informa
  del incumplimiento con la excepción de dominio del proyecto y un mensaje
  que identifica la regla vulnerada.
- La autorización (rol y propiedad del recurso) no es regla de negocio y no
  va en el validador: `@PreAuthorize` en `ejecutar` o, si necesita la
  entidad cargada, en el caso de uso tras cargarla
  (`.claude/skills/springboot-security/SKILL.md`, si existe).
- El caso de uso llama al método del validador justo antes de guardar:
  `convocatoriaValidator.validarCreacion(convocatoria); repositorio.save(convocatoria);`.
- El formato de la entrada (obligatorios, longitudes, patrones) lo declara
  el contrato OpenAPI y lo aplica Bean Validation al entrar en el
  controlador; el validador no lo repite, solo las condiciones que
  dependen del dominio, de su estado o de otros datos.
- Controlador: HTTP, sin lógica. Recibe el DTO, llama al caso de uso y
  convierte el resultado con el mapper.
- Repositorio: acceso a datos, sin reglas de negocio.
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
- Relaciones `LAZY`. Carga lo necesario con `JOIN FETCH` o `@EntityGraph`
  para evitar consultas N+1.
- Listados paginados con `Pageable` y `Page<T>`.
- `CascadeType.ALL` y `orphanRemoval` solo si el hijo no existe sin el padre.
