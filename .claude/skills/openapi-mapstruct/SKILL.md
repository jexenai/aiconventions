---
name: openapi-mapstruct
description: DTO generados desde el contrato OpenAPI y mapeo entidad-DTO con MapStruct - configuración de Maven, configuración compartida de mappers, lectura, alta, modificación, paginación, referencias, objetos embebidos, texto con formato propio y pruebas. Úsala al crear o cambiar un mapper, o al exponer una entidad nueva en la API.
disable-model-invocation: true
---

# DTO de OpenAPI y mapeo con MapStruct

Complementa `.claude/rules/java/datos.md`, que fija las pautas. Aquí va el
detalle y los ejemplos. Los paquetes (`com.ejemplo.app`) y el dominio
(`Pedido`, `Cliente`) son ilustrativos: usa los del proyecto.

## Configuración de Maven

Si el proyecto aún no genera los DTO, añade el plugin y los procesadores de
anotaciones. Fija las versiones en `<properties>` y comprueba en
`development.md` si el proyecto ya declara otras.

```xml
<dependency>
  <groupId>org.mapstruct</groupId>
  <artifactId>mapstruct</artifactId>
  <version>${mapstruct.version}</version>
</dependency>

<!-- maven-compiler-plugin: Lombok antes que MapStruct -->
<annotationProcessorPaths>
  <path>
    <groupId>org.projectlombok</groupId>
    <artifactId>lombok</artifactId>
    <version>${lombok.version}</version>
  </path>
  <path>
    <groupId>org.mapstruct</groupId>
    <artifactId>mapstruct-processor</artifactId>
    <version>${mapstruct.version}</version>
  </path>
</annotationProcessorPaths>

<plugin>
  <groupId>org.openapitools</groupId>
  <artifactId>openapi-generator-maven-plugin</artifactId>
  <version>${openapi-generator.version}</version>
  <executions>
    <execution>
      <goals><goal>generate</goal></goals>
      <configuration>
        <inputSpec>${project.basedir}/src/main/resources/openapi.yml</inputSpec>
        <generatorName>spring</generatorName>
        <apiPackage>com.ejemplo.app.api</apiPackage>
        <modelPackage>com.ejemplo.app.dto</modelPackage>
        <configOptions>
          <delegatePattern>true</delegatePattern>
          <useBeanValidation>true</useBeanValidation>
          <useJakartaEe>true</useJakartaEe>
        </configOptions>
      </configuration>
    </execution>
  </executions>
</plugin>
```

- Los DTO se generan en `target/generated-sources/openapi/` en cada
  compilación; tras cambiar el contrato, `mvn generate-sources`.
- Las restricciones de validación (`required`, `maxLength`, `pattern`...) se
  declaran en el contrato y el generador las traslada a los DTO.
- Cada esquema del contrato es un DTO. Si falta uno (por ejemplo, un resumen
  para un listado), añádelo al contrato; no crees la clase a mano.

## Configuración compartida

Crea una vez, en el paquete de mappers:

```java
// ERROR en lugar de WARN: un campo sin mapear rompe la compilación.
@MapperConfig(
    componentModel = "spring",
    injectionStrategy = InjectionStrategy.CONSTRUCTOR,
    unmappedTargetPolicy = ReportingPolicy.ERROR)
public interface MapeoConfig {
}
```

- `unmappedTargetPolicy = ERROR`: si el DTO o la entidad ganan un campo y el
  mapper no lo trata, la compilación falla con
  `Unmapped target property: "..."`.
- `injectionStrategy = CONSTRUCTOR`: los mappers que usan otros mappers los
  reciben por constructor.

## Entidades

Patrón de anotaciones acordado: `@Entity`, `@Getter`, `@Setter`, `@Builder`
y los dos constructores de Lombok. Nombre del dominio, sin sufijo `Entity`,
en `models/`; sin reglas de negocio ni campos que el contrato o el esquema
no requieran.

```java
@Entity
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Cliente {

    @Id @GeneratedValue(strategy = GenerationType.SEQUENCE)
    private Long id;

    private String nif;
    private String nombre;

    @Version
    private Long version;

    private LocalDateTime creadoEn;
    private LocalDateTime actualizadoEn;
    private LocalDateTime borradoEn;

    @PrePersist
    void alCrear() {
        creadoEn = LocalDateTime.now();
        actualizadoEn = creadoEn;
    }

    @PreUpdate
    void alActualizar() {
        actualizadoEn = LocalDateTime.now();
    }
}
```

- Auditoría (`.claude/skills/jpa-patterns/SKILL.md`, sección homónima):
  `creadoEn`, `actualizadoEn` y, si la entidad admite baja lógica,
  `borradoEn`, los tres `LocalDateTime` con `@PrePersist`/`@PreUpdate`. Si la
  entidad se expone en algún JSON que no pase por el mapper (por ejemplo, un
  log), oculta estos campos con `@JsonIgnore`.
- Alta: MapStruct crea la entidad con `builder()`, así que `toEntidad` da
  `ignore = true` a `id`, `version` y a los campos de auditoría, que no
  llegan del DTO (`.claude/rules/java/datos.md`).
- Modificación: `actualizar` con `@MappingTarget` no toca `id`, `version` ni
  los campos de auditoría; decláralos con `ignore = true`. Con `@Setter` en
  toda la clase, esa exclusión la garantiza el mapper, no la entidad.

## Ejemplos

Mappers en `mappers/`, con el sufijo `*Mapper`. Cuando entidad y DTO
se llaman igual (`models.Cliente` y `dto.Cliente`), importa la entidad y
escribe el DTO con su nombre completo.

### Paginación (compartido)

```java
@Mapper(config = MapeoConfig.class)
public interface PaginacionMapper {

    @Mapping(target = "pagina", source = "number")
    @Mapping(target = "elementosPorPagina", source = "size")
    @Mapping(target = "paginas", source = "totalPages")
    @Mapping(target = "elementos", source = "totalElements")
    Paginacion toPaginacion(Page<?> pagina);
}
```

Los nombres de destino son los del esquema de paginación del contrato.

### Lectura, alta, modificación y página

```java
@Mapper(config = MapeoConfig.class, uses = PaginacionMapper.class)
public interface ClienteMapper {

    com.ejemplo.app.dto.Cliente toDto(Cliente entidad);

    @Mapping(target = "id", ignore = true)
    @Mapping(target = "version", ignore = true)
    @Mapping(target = "creadoEn", ignore = true)
    @Mapping(target = "actualizadoEn", ignore = true)
    @Mapping(target = "borradoEn", ignore = true)
    Cliente toEntidad(NuevoCliente nuevo);

    @Mapping(target = "id", ignore = true)
    @Mapping(target = "version", ignore = true)
    @Mapping(target = "creadoEn", ignore = true)
    @Mapping(target = "actualizadoEn", ignore = true)
    @Mapping(target = "borradoEn", ignore = true)
    void actualizar(ModificacionCliente modificacion, @MappingTarget Cliente entidad);

    @Mapping(target = "contenido", source = "content")
    @Mapping(target = "paginacion", source = ".")
    PaginaClientes toPagina(Page<Cliente> pagina);
}
```

- `version` del DTO de modificación no se copia: el caso de uso la compara
  con la de la entidad antes de llamar a `actualizar` y responde 409 si
  difiere.
- Los enums con las mismas constantes se mapean solos por nombre. Si
  difieren, usa `@ValueMapping`.

### Referencias a otra entidad

El contrato envía el identificador (`clienteId`) y la entidad necesita el
objeto. El caso de uso lo carga con su repositorio y se lo pasa al mapper:

```java
@Mapper(config = MapeoConfig.class, uses = ClienteMapper.class)
public interface PedidoMapper {

    // El cliente sale anidado en la respuesta a través de ClienteMapper.toDto.
    com.ejemplo.app.dto.Pedido toDto(Pedido entidad);

    @Mapping(target = "cliente", source = "cliente")
    @Mapping(target = "id", ignore = true)
    @Mapping(target = "version", ignore = true)
    @Mapping(target = "creadoEn", ignore = true)
    @Mapping(target = "actualizadoEn", ignore = true)
    Pedido toEntidad(NuevoPedido nuevo, Cliente cliente);

    // Si varios parámetros tienen el mismo campo, indica de cuál sale.
    @Mapping(target = "cliente", source = "cliente")
    @Mapping(target = "id", ignore = true)
    @Mapping(target = "version", ignore = true)
    @Mapping(target = "creadoEn", ignore = true)
    @Mapping(target = "actualizadoEn", ignore = true)
    void actualizar(ModificacionPedido modificacion, Cliente cliente,
        @MappingTarget Pedido entidad);
}
```

### Objetos embebidos

Un método propio para el `@Embeddable` hace que MapStruct lo reutilice en el
alta y lo sustituya entero en la modificación:

```java
Direccion toEntidad(com.ejemplo.app.dto.Direccion direccion);
```

### Campos que no se mapean

`ignore = true` solo con un motivo real y comentado. Si un campo del DTO
sobra, quítalo del contrato.

## Texto con formato propio

Aplica si el contrato transporta fechas o importes como texto con un formato
que no es ISO ni punto decimal (por ejemplo, `dd/mm/aaaa` o `1.160,50`). Sin
indicación, MapStruct convierte `String` a `LocalDate` o `BigDecimal` con su
conversión implícita: compila, pero falla en ejecución sin un error de
validación del campo.

- Salida: añade el conversor del proyecto a `uses` de `MapeoConfig`; sus
  métodos estáticos de un parámetro (`String texto(LocalDate)`) se aplican
  solos.
- Entrada: `expression` con el conversor y el nombre del campo, para que el
  error 400 lo indique.

```java
@Mapping(target = "fechaEntrega",
    expression = "java(FormatoEspanol.fecha(nuevo.getFechaEntrega(), \"fechaEntrega\"))")
Pedido toEntidad(NuevoPedido nuevo, Cliente cliente);
```

La variable de la `expression` es el nombre del parámetro del método, y el
mapper declara `imports = FormatoEspanol.class`.

Para que olvidar la `expression` rompa la compilación, añade también a
`uses` de `MapeoConfig` una clase con dos métodos por tipo de destino. La
conversión se vuelve ambigua y MapStruct falla con un mensaje que ya indica
qué hacer:

```java
// Workaround: dos métodos por tipo hacen ambigua la conversión implícita String -> fecha/decimal
// y MapStruct falla al compilar; obliga a usar expression con el conversor y el nombre del campo.
public final class ConversionImplicitaBloqueada {

    private static final String MENSAJE = "Usa expression con el conversor y el nombre del campo";

    private ConversionImplicitaBloqueada() {
    }

    public static LocalDate fechaUsaExpressionConElConversor(String valor) {
        throw new UnsupportedOperationException(MENSAJE);
    }

    public static LocalDate fechaIndicaElNombreDelCampo(String valor) {
        throw new UnsupportedOperationException(MENSAJE);
    }

    // Igual para Instant, LocalDateTime y BigDecimal si el contrato los usa.
}
```

Registra el conversor y este bloqueo en las convenciones de
`development.md`.

## Pruebas

- Un mapper sin dependencias se prueba sin Spring: `new ClienteMapperImpl()`.
- Con dependencias, pásalas al constructor:
  `new PedidoMapperImpl(new ClienteMapperImpl())`.
- Cubre los nulos, que la modificación no toca `id`, `version` ni los campos
  de auditoría y, si hay formato propio, la conversión en ambos sentidos y
  el error del campo ante un texto mal formado.
