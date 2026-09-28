---
name: jpa-patterns
description: Patrones de JPA e Hibernate en Spring Boot con Oracle - entidades, relaciones, consultas, proyecciones, transacciones, bloqueo optimista, migraciones y conexión en WebLogic o JBoss. Úsala al diseñar o cambiar entidades, repositorios o consultas, o al resolver problemas de N+1, transacciones o rendimiento de acceso a datos.
disable-model-invocation: true
---

# Patrones de JPA

Complementa `.claude/rules/java/patrones.md`, que ya fija relaciones `LAZY`,
`JOIN FETCH` y paginación, y `.claude/rules/java/oracle.md`, si existe, con
las restricciones de Oracle 19c. Aquí va el detalle.

## Entidades

```java
// Tabla pedido, secuencia pedido_seq y columna cliente_id, por convención.
@Entity
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Pedido {

  @Id
  @GeneratedValue(strategy = GenerationType.SEQUENCE)
  private Long id;

  @Version
  private Long version;

  @Column(nullable = false, length = 200)
  private String referencia;

  @Enumerated(EnumType.STRING)
  @Column(nullable = false, length = 20)
  private EstadoPedido estado;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  private Cliente cliente;

  // Las líneas no existen sin su pedido: cascada y orphanRemoval (patrones.md).
  @OneToMany(mappedBy = "pedido", cascade = CascadeType.ALL, orphanRemoval = true)
  @Builder.Default
  private List<LineaPedido> lineas = new ArrayList<>();

  private LocalDateTime creadoEn;
  private LocalDateTime actualizadoEn;

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

- Los nombres físicos los deriva Spring Boot
  (`CamelCaseToUnderscoresNamingStrategy`): la clase `LineaPedido` va a la
  tabla `linea_pedido`, el campo `fechaEntrega` a `fecha_entrega` y la
  relación `cliente` a `cliente_id`. No los fijes con `@Table`, `name` ni
  `@SequenceGenerator`; la migración usa esos mismos nombres.
- La secuencia por defecto es `{tabla}_seq` con un `allocationSize` de 50:
  créala con `INCREMENT BY 50`. Si no coinciden, se generan identificadores
  duplicados o con huecos inesperados.
- `@Version` para bloqueo optimista en entidades que se editan de forma
  concurrente; traduce `OptimisticLockException` a 409 en el manejador
  centralizado.
- `EnumType.STRING`, nunca `ORDINAL`: reordenar el enum corrompe los datos.
- `equals()` y `hashCode()` basados en el identificador de negocio o en el
  `id` con clase constante; nunca en todas las columnas ni en relaciones.
- `@ManyToOne` es `EAGER` por defecto en JPA: decláralo `LAZY` siempre.

## Auditoría

- `creadoEn` y `actualizadoEn` en toda entidad, y `borradoEn` si admite baja
  lógica, los tres `LocalDateTime`, con columnas `creado_en`,
  `actualizado_en` y `borrado_en` por convención.
- Los rellenan `@PrePersist` y `@PreUpdate` de la propia entidad; nunca se
  fijan a mano desde el caso de uso.
- `@JsonIgnore` en los tres si la entidad llega a serializarse fuera del
  mapper (por ejemplo, en un log); con MapStruct y DTO del contrato
  (`datos.md`), la entidad nunca sale directamente, así que no suele hacer
  falta.
- Con baja lógica, las consultas de listado excluyen `borradoEn IS NOT NULL`
  (`@SQLRestriction` de Hibernate, que sustituye al `@Where` obsoleto, o la
  condición en el repositorio); la de detalle
  por identificador puede incluir los borrados si el caso de uso lo pide
  explícitamente.

## Consultas

```java
public interface PedidoRepository extends JpaRepository<Pedido, Long> {

  @EntityGraph(attributePaths = {"cliente", "lineas"})
  Optional<Pedido> findWithDetalleById(Long id);

  // Proyección: solo las columnas que se muestran
  Page<PedidoResumen> findByEstado(EstadoPedido estado, Pageable pageable);

  @Modifying(clearAutomatically = true)
  @Query("update Pedido p set p.estado = :estado where p.id in :ids")
  int actualizarEstado(@Param("estado") EstadoPedido estado, @Param("ids") List<Long> ids);
}

public record PedidoResumen(Long id, String referencia, EstadoPedido estado) {}
```

- Lecturas para pantallas o listados con proyecciones (`record` o interfaz),
  no con entidades completas. La proyección no sale a la API: se mapea con
  MapStruct al DTO generado del contrato.
- `JOIN FETCH` sobre una colección junto con `Pageable` pagina en memoria
  (Hibernate avisa con `HHH90003004`): pagina los identificadores y carga
  el detalle en una segunda consulta.
- `@Modifying(clearAutomatically = true)` para que el contexto de
  persistencia no devuelva datos obsoletos tras una actualización masiva.
- Escrituras masivas con `hibernate.jdbc.batch_size` y `order_inserts`; con
  `GenerationType.IDENTITY` Hibernate desactiva el *batching*.
- Para ver el SQL real al depurar: `logging.level.org.hibernate.SQL=DEBUG`,
  nunca en producción.

## Transacciones

- Transacciones cortas: nada de llamadas HTTP ni esperas dentro.
- `@Transactional` funciona por proxy: una llamada desde la misma clase no
  abre transacción.
- Por defecto solo se revierte con excepciones no comprobadas.
- `spring.jpa.open-in-view=false`: evita consultas perezosas desde la capa
  web, que ocultan N+1 y alargan la conexión.

## Conexión y esquema

- En WebLogic o JBoss, `spring.datasource.jndi-name` apunta al *datasource*
  del servidor. El pool lo gestiona el servidor: la configuración de Hikari
  no aplica.
- `spring.jpa.hibernate.ddl-auto=validate` o `none`. El esquema cambia con
  migraciones versionadas (Flyway o Liquibase), nunca con Hibernate.
- Migraciones solo aditivas en un mismo despliegue: añadir antes de quitar,
  y borrar columnas en una versión posterior.

## Pruebas

`@DataJpaTest` con `@AutoConfigureTestDatabase(replace = NONE)` contra la base
de datos real. Comprueba el número de consultas en los casos con relaciones
cuando el rendimiento importe (estadísticas de Hibernate o
`spring.jpa.properties.hibernate.generate_statistics=true` en pruebas).
