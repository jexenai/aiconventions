---
name: jpa-patterns
description: Patrones de JPA e Hibernate en Spring Boot con Oracle - entidades, relaciones, consultas, proyecciones, transacciones, bloqueo optimista, migraciones y conexión en WebLogic o JBoss. Úsala al diseñar o cambiar entidades, repositorios o consultas, o al resolver problemas de N+1, transacciones o rendimiento de acceso a datos.
disable-model-invocation: true
---

# Patrones de JPA

Complementa `.claude/rules/java/patrones.md`, que ya fija relaciones `LAZY`,
`JOIN FETCH`, paginación y las restricciones de Oracle 19c. Aquí va el detalle.

## Entidades

```java
@Entity
@Table(name = "PEDIDOS")
public class Pedido {

  @Id
  @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "pedidos_seq")
  @SequenceGenerator(name = "pedidos_seq", sequenceName = "PEDIDOS_SEQ", allocationSize = 50)
  private Long id;

  @Version
  private Long version;

  @Column(nullable = false, length = 200)
  private String referencia;

  @Enumerated(EnumType.STRING)
  @Column(nullable = false, length = 20)
  private EstadoPedido estado;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @JoinColumn(name = "CLIENTE_ID")
  private Cliente cliente;
}
```

- `allocationSize` igual al `INCREMENT BY` de la secuencia en Oracle; si no
  coinciden, se generan identificadores duplicados o con huecos inesperados.
- `@Version` para bloqueo optimista en entidades que se editan de forma
  concurrente; traduce `OptimisticLockException` a 409 en el manejador
  centralizado.
- `EnumType.STRING`, nunca `ORDINAL`: reordenar el enum corrompe los datos.
- `equals()` y `hashCode()` basados en el identificador de negocio o en el
  `id` con clase constante; nunca en todas las columnas ni en relaciones.
- `@ManyToOne` es `EAGER` por defecto en JPA: decláralo `LAZY` siempre.

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
  no con entidades completas.
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
