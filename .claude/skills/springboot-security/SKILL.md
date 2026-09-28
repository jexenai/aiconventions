---
name: springboot-security
description: Configuración de Spring Security en Spring Boot 3 y 4 - cadena de filtros, autenticación con sesión o JWT, autorización por método y por propiedad del recurso, CSRF, CORS, cabeceras, contraseñas, límite de peticiones y subida de ficheros. Úsala al añadir o cambiar autenticación, autorización o configuración de seguridad.
disable-model-invocation: true
---

# Seguridad en Spring Boot

Complementa `.claude/rules/comun/seguridad.md` y
`.claude/rules/java/seguridad.md`. Aquí va cómo se configura.

## Cadena de filtros

Dos modelos, según quién llama:

- **La SPA propia (o páginas del servidor):** sesión de servidor en una
  cookie `HttpOnly` y CSRF activo. Es el modelo por defecto: el navegador
  nunca guarda un token (`.claude/rules/react/seguridad.md`).
- **Clientes máquina a máquina:** JWT Bearer, sin sesión ni CSRF, en una
  cadena aparte y solo si existen.

```java
@Configuration
@EnableMethodSecurity
class SeguridadConfig {

  // Solo si hay clientes máquina a máquina: peticiones con Authorization: Bearer.
  @Bean
  @Order(1)
  SecurityFilterChain clientes(HttpSecurity http) throws Exception {
    return http
        .securityMatcher(new RequestHeaderRequestMatcher(HttpHeaders.AUTHORIZATION))
        .authorizeHttpRequests(auth -> auth.anyRequest().authenticated())
        .oauth2ResourceServer(rs -> rs.jwt(Customizer.withDefaults()))
        .sessionManagement(s -> s.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
        .csrf(csrf -> csrf.disable())               // sin cookies: no hay CSRF posible
        .build();
  }

  // La SPA propia: sesión con cookie HttpOnly y CSRF.
  @Bean
  @Order(2)
  SecurityFilterChain navegador(HttpSecurity http) throws Exception {
    return http
        .authorizeHttpRequests(auth -> auth
            .requestMatchers("/actuator/health").permitAll()
            .anyRequest().authenticated())          // deniega por defecto
        .formLogin(Customizer.withDefaults())       // o oauth2Login con el proveedor corporativo
        .csrf(csrf -> csrf.spa())                   // cookie XSRF-TOKEN y cabecera X-XSRF-TOKEN
        .headers(h -> h
            .contentSecurityPolicy(csp -> csp.policyDirectives("default-src 'self'"))
            .frameOptions(HeadersConfigurer.FrameOptionsConfig::deny))
        .build();
  }
}
```

- Solo el DSL con lambdas: en Spring Security 7 (Spring Boot 4) desaparecen
  `and()` y los métodos encadenados antiguos.
- `csrf.spa()` deja el token en la cookie `XSRF-TOKEN`, legible por
  JavaScript, y lo espera en la cabecera `X-XSRF-TOKEN`: axios lo hace solo.
  Es de las versiones recientes de Spring Security; si la del proyecto no
  lo tiene, configura `CookieCsrfTokenRepository.withHttpOnlyFalse()` con el
  manejador para SPA de la documentación oficial.
- Sirve la SPA y la API bajo el mismo dominio (por ejemplo, con el proxy
  inverso de Apache) para que la cookie de sesión sea de primera parte y no
  haga falta CORS con credenciales.
- Nunca desactives CSRF en una cadena que use cookies. En la de clientes
  máquina a máquina sí, porque no hay sesión.
- Para validar JWT, `oauth2ResourceServer` con el emisor configurado
  (`spring.security.oauth2.resourceserver.jwt.issuer-uri`). No escribas un
  filtro propio que interprete el token.
- Cookies de sesión `Secure`, `HttpOnly` y `SameSite`
  (`server.servlet.session.cookie.*`); en WebLogic, revisa también
  `weblogic.xml`, que puede prevalecer.

## Autorización

```java
// BuscarUsuariosConFiltros
@PreAuthorize("hasRole('ADMIN')")
public Page<Usuario> ejecutar(FiltroUsuarios filtro, Pageable pagina) { ... }

// CancelarPedido
@PreAuthorize("@autorizacion.esPropietario(#pedidoId, authentication)")
public Pedido ejecutar(Long pedidoId) { ... }
```

La autorización no es una regla de negocio: no va en el validador.

- Comprueba la propiedad del recurso, no solo el rol: un usuario
  autenticado no puede leer ni cambiar pedidos ajenos cambiando el
  identificador de la URL.
- Si basta con el usuario y los parámetros, `@PreAuthorize` en el
  `ejecutar` del caso de uso, como en el ejemplo.
- Si necesita la entidad cargada, el caso de uso la comprueba justo después
  de cargarla y lanza `AccessDeniedException`; el manejador la traduce a 403.
- Prueba cada regla con `@WithMockUser` o `jwt()` de
  `spring-security-test`, incluido el caso denegado.

## CORS

Solo si la SPA no puede servirse bajo el mismo dominio que la API. Con
sesión, el origen cruzado necesita credenciales y la cabecera del token
CSRF:

```java
// app.cors.origenes en application.yml, distinto por entorno.
@ConfigurationProperties("app.cors")
record CorsPropiedades(List<String> origenes) {}

@Bean
CorsConfigurationSource corsConfigurationSource(CorsPropiedades cors) {
  var config = new CorsConfiguration();
  config.setAllowedOrigins(cors.origenes());
  config.setAllowedMethods(List.of("GET", "POST", "PUT", "DELETE"));
  config.setAllowedHeaders(List.of("Content-Type", "X-XSRF-TOKEN"));
  config.setAllowCredentials(true);
  var source = new UrlBasedCorsConfigurationSource();
  source.registerCorsConfiguration("/**", config);
  return source;
}
```

Actívalo con `.cors(Customizer.withDefaults())` en la cadena del navegador,
no con `@CrossOrigin` repartido por los controladores. Nunca origen `*` con
credenciales. La cookie de sesión entre sitios distintos necesita además
`SameSite=None` y `Secure`.

## Contraseñas

`PasswordEncoderFactories.createDelegatingPasswordEncoder()` (bcrypt por
defecto, admite migrar de algoritmo). Nunca compares contraseñas en claro ni
con hashes rápidos (MD5, SHA).

## Límite de peticiones

- Mejor en el balanceador o la pasarela, si existen.
- En la aplicación, Bucket4j con una caché con expiración (Caffeine) por
  usuario o IP. Un `Map` sin límite crece sin control.
- Detrás de un proxy, la IP real viene en `X-Forwarded-For` solo si el proxy
  es de confianza (`server.forward-headers-strategy`); si no, se falsifica.
- Responde 429 con `Retry-After`.

## Ficheros subidos

- Tamaño máximo en `spring.servlet.multipart.max-file-size` y
  `max-request-size`.
- Comprueba el tipo por contenido, no por la extensión ni el
  `Content-Type` del cliente.
- Guarda con nombre generado fuera de las rutas servidas y normaliza la ruta
  (`Path.normalize()` y comprobación de que sigue dentro del directorio
  base).

## Dependencias

OWASP Dependency-Check (`dependency-check-maven`) en CI con umbral de fallo
(`failBuildOnCVSS`). Mantén Spring Boot en una versión con soporte.
