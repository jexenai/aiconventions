---
name: springboot-tdd
description: Pruebas en Spring Boot 3 y 4 con JUnit 5, Mockito, MockMvc, spring-security-test y Testcontainers, con ejemplos por capa. Úsala al escribir o corregir pruebas de servicios, controladores o repositorios, o al implementar una funcionalidad con pruebas primero.
disable-model-invocation: true
---

# Pruebas en Spring Boot

Complementa `.claude/rules/java/pruebas.md`, que fija herramientas, niveles y
nombres. Con OpenSpec, el orden de pruebas primero lo fija
`openspec/config.yaml`.

## Servicio (unitaria)

```java
@ExtendWith(MockitoExtension.class)
class PedidoServiceTest {

  @Mock PedidoRepository repositorio;
  @InjectMocks PedidoService servicio;

  @Test
  void cancelar_pedidoEnviado_lanzaExcepcion() {
    when(repositorio.findById(1L)).thenReturn(Optional.of(pedidoEnEstado(ENVIADO)));

    assertThatThrownBy(() -> servicio.cancelar(1L))
        .isInstanceOf(PedidoNoCancelableException.class);
    verify(repositorio, never()).save(any());
  }
}
```

## Controlador

```java
@WebMvcTest(PedidoController.class)
class PedidoControllerTest {

  @Autowired MockMvc mvc;
  @MockitoBean PedidoService servicio;

  @Test
  @WithMockUser
  void crear_sinReferencia_devuelve400() throws Exception {
    mvc.perform(post("/api/pedidos").with(csrf())
            .contentType(MediaType.APPLICATION_JSON)
            .content("{\"referencia\":\"\"}"))
        .andExpect(status().isBadRequest());
  }

  @Test
  void listar_sinAutenticar_devuelve401() throws Exception {
    mvc.perform(get("/api/pedidos")).andExpect(status().isUnauthorized());
  }
}
```

- En Spring Boot 4, las anotaciones de pruebas por capa están en módulos
  propios (por ejemplo, `spring-boot-webmvc-test`): si no resuelve el
  import, falta la dependencia de ese módulo.
- Con JWT: `.with(jwt().authorities(new SimpleGrantedAuthority("ROLE_ADMIN")))`.
- Comprueba el cuerpo con `jsonPath` y cubre 400, 401, 403 y 404 además del
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

Usa los de `development.md`. Una sola clase: `mvn test -Dtest=PedidoServiceTest`
o `./gradlew test --tests PedidoServiceTest`.
