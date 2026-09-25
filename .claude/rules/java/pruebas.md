---
paths:
  - "**/src/test/**/*.java"
---
# Java: pruebas

JUnit 5, AssertJ y Mockito.

| Qué se prueba | Cómo |
| ------------- | ---- |
| Lógica de servicio | Unitaria sin contexto de Spring: `@ExtendWith(MockitoExtension.class)` |
| Controlador | `@WebMvcTest` con el servicio simulado |
| Repositorio y consultas | `@DataJpaTest` contra la base de datos real |
| Flujo completo | `@SpringBootTest`, solo en integración |

- Nombre de la prueba: `metodo_condicion_resultado`, por ejemplo
  `crear_conEmailDuplicado_lanzaExcepcion`. Si cubre un escenario de
  OpenSpec, su nombre va en `@DisplayName`.
- Dobles en el contexto de Spring con `@MockitoBean`, no con `@MockBean`,
  obsoleto en Spring Boot 3.4 y eliminado en Spring Boot 4.
- Variantes del mismo caso con `@ParameterizedTest`.
- Código asíncrono con Awaitility, no con `Thread.sleep()`.
- Cobertura con JaCoCo si está configurado.
