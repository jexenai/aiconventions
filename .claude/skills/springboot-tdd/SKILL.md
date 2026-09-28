---
name: springboot-tdd
description: Pruebas en Spring Boot 3 y 4 con JUnit 5, Hamcrest, Mockito, MockMvc, spring-security-test y Testcontainers, con ejemplos por capa. Úsala al escribir o corregir pruebas de casos de uso, validadores, controladores o repositorios, o al implementar una funcionalidad con pruebas primero.
disable-model-invocation: true
---

# Pruebas en Spring Boot

Complementa `.claude/rules/java/pruebas.md`, que fija herramientas, carpetas
(`unit`, `integration`, `e2e`) y nombres. Con OpenSpec, el orden de pruebas
primero lo fija `openspec/config.yaml`.

## Caso de uso y validador (unitarias)

```java
@ExtendWith(MockitoExtension.class)
class CancelarPedidoTest {

  @Mock PedidoRepository repositorio;
  @Mock PedidoValidator pedidoValidator;
  @InjectMocks CancelarPedido cancelarPedido;

  @Test
  void pedidoNoCancelable_noGuarda() {
    Pedido pedido = pedidoEnEstado(ENVIADO);
    when(repositorio.findById(1L)).thenReturn(Optional.of(pedido));
    doThrow(new PedidoNoCancelableException(1L))
        .when(pedidoValidator).validarCancelacion(pedido);

    assertThrows(PedidoNoCancelableException.class, () -> cancelarPedido.ejecutar(1L));
    verify(repositorio, never()).save(any());
  }
}

@ExtendWith(MockitoExtension.class)
class PedidoValidatorTest {

  @InjectMocks PedidoValidator pedidoValidator;

  @Test
  void pedidoEnviado_lanzaExcepcion() {
    PedidoNoCancelableException excepcion = assertThrows(PedidoNoCancelableException.class,
        () -> pedidoValidator.validarCancelacion(pedidoEnEstado(ENVIADO)));

    assertThat(excepcion.getMessage(), containsString("ya ha sido enviado"));
  }
}
```

- Cada regla se prueba en el método del validador que la aplica
  (`validarCancelacion`, `validarModificacion`...), no en el caso de uso. En
  el caso de uso basta comprobar que llama al validador antes de guardar y
  que no guarda si este lanza la excepción.

## Controlador

```java
@WebMvcTest(PedidosController.class)
class PedidosControllerTest {

  @Autowired MockMvc mvc;
  @MockitoBean CrearPedido crearPedido;
  @MockitoBean ListarPedidos listarPedidos;

  @Test
  @WithMockUser
  void crear_sinReferencia_devuelve422() throws Exception {
    mvc.perform(post("/pedidos").with(csrf())
            .contentType(MediaType.APPLICATION_JSON)
            .content("{\"referencia\":\"\"}"))
        .andExpect(status().isUnprocessableEntity())
        .andExpect(jsonPath("$.errors").exists());   // forma: "Formato de error" de development.md
  }

  @Test
  void listar_sinAutenticar_devuelve401() throws Exception {
    mvc.perform(get("/pedidos")).andExpect(status().isUnauthorized());
  }
}
```

- En Spring Boot 4, las anotaciones de pruebas por capa están en módulos
  propios (por ejemplo, `spring-boot-webmvc-test`): si no resuelve el
  import, falta la dependencia de ese módulo.
- Con JWT: `.with(jwt().authorities(new SimpleGrantedAuthority("ROLE_ADMIN")))`.
- Comprueba el cuerpo con `jsonPath` y cubre 422 (validación), 400 (JSON
  mal formado), 401, 403 y 404 además del
  caso correcto.

## Repositorio e integración con Testcontainers

```java
@DataJpaTest
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.NONE)
@Testcontainers
class PedidoRepositoryTest {

  @Container
  @ServiceConnection
  static OracleContainer oracle = new OracleContainer("gvenzl/oracle-free:slim-faststart");

  @Autowired PedidoRepository repositorio;
  ...
}
```

- `@ServiceConnection` configura la conexión sin `@DynamicPropertySource`.
- Reutiliza el contenedor entre clases con una clase base o una
  configuración `@TestConfiguration` compartida: arrancar Oracle es lento.

> Aclaración: la imagen gratuita de Oracle es 23ai, no 19c. Sirve para
> detectar la mayoría de problemas de dialecto; si el proyecto usa algo
> propio de 19c, las pruebas de integración van contra la base de datos de
> integración del equipo.

## Datos de prueba

Constructores de datos (*builders*) o métodos fábrica con valores por
defecto válidos, y en cada prueba solo los campos que importan para el caso.

## Comandos

Usa los de `development.md`. Una sola clase: `mvn test -Dtest=CancelarPedidoTest`
o `./gradlew test --tests CancelarPedidoTest`.
