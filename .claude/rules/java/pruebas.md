---
paths:
  - "**/src/test/**/*.java"
---
# Java: pruebas

JUnit 5, Hamcrest y Mockito.

Antes de escribir o corregir una prueba, lee
`.claude/skills/springboot-tdd/SKILL.md`, si existe.

## Carpetas

Bajo `src/test/java/<paquete raíz>/`, con la misma ruta que el código
probado dentro de cada una:

| Carpeta | Qué se prueba | Cómo |
| ------- | -------------- | ---- |
| `unit` | Caso de uso, validador y mapper | Sin contexto de Spring: `@ExtendWith(MockitoExtension.class)` |
| `integration` | Controlador, repositorio y consultas | `@WebMvcTest` con los casos de uso simulados; `@DataJpaTest` contra la base de datos real, solo para métodos personalizados (`@Query` o de nombre derivado) — no se prueban los heredados de `JpaRepository`/`CrudRepository` |
| `e2e` | Flujo completo | `@SpringBootTest(webEnvironment = RANDOM_PORT)`, solo para los flujos críticos |

`unit/actions/convocatorias/CrearConvocatoriaTest`,
`integration/controllers/ConvocatoriasControllerTest`.

## Aserciones

- Hamcrest (`MatcherAssert.assertThat` y sus *matchers*) para las
  aserciones, siempre que encaje con el tipo de prueba: es más legible y
  compone bien. Conserva las aserciones idiomáticas de MockMvc
  (`status()`, `jsonPath()`) y las comprobaciones especializadas que no
  tengan una alternativa Hamcrest clara.
- Excepciones con `assertThrows` de JUnit y, sobre la excepción capturada,
  un *matcher* de Hamcrest para el mensaje o los datos del caso.

## Convenciones

- Nombre de la prueba: `metodo_condicion_resultado`, por ejemplo
  `crear_conEmailDuplicado_lanzaExcepcion`. En casos de uso y en los
  métodos del validador, cuyo nombre ya expresa la acción, basta
  `condicion_resultado` (`conCodigoDuplicado_lanzaExcepcion`). Si cubre un
  escenario de OpenSpec, su nombre va en `@DisplayName`.
- Dobles en el contexto de Spring con `@MockitoBean`, no con `@MockBean`,
  obsoleto en Spring Boot 3.4 y eliminado en Spring Boot 4.
- Variantes del mismo caso con `@ParameterizedTest`.
- Código asíncrono con Awaitility, no con `Thread.sleep()`.
- Cobertura con JaCoCo si está configurado.
