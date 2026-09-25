---
name: springboot-security
description: Configuración de Spring Security en Spring Boot 3 y 4 - cadena de filtros, autenticación con sesión o JWT, autorización por método y por propiedad del recurso, CSRF, CORS, cabeceras, contraseñas, límite de peticiones y subida de ficheros. Úsala al añadir o cambiar autenticación, autorización o configuración de seguridad.
disable-model-invocation: true
---

# Seguridad en Spring Boot

Complementa `.claude/rules/comun/seguridad.md` y
`.claude/rules/java/seguridad.md`. Aquí va cómo se configura.

## Cadena de filtros

```java
@Configuration
@EnableMethodSecurity
class SeguridadConfig {

  @Bean
  SecurityFilterChain api(HttpSecurity http) throws Exception {
    return http
        .authorizeHttpRequests(auth -> auth
            .requestMatchers("/actuator/health").permitAll()
            .requestMatchers(HttpMethod.GET, "/api/publico/**").permitAll()
            .anyRequest().authenticated())          // deniega por defecto
        .oauth2ResourceServer(rs -> rs.jwt(Customizer.withDefaults()))
        .sessionManagement(s -> s.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
        .csrf(csrf -> csrf.disable())               // API sin estado con token Bearer
        .cors(Customizer.withDefaults())
        .headers(h -> h
            .contentSecurityPolicy(csp -> csp.policyDirectives("default-src 'self'"))
            .frameOptions(HeadersConfigurer.FrameOptionsConfig::deny))
        .build();
  }
}
```

- Solo el DSL con lambdas: en Spring Security 7 (Spring Boot 4) desaparecen
  `and()` y los métodos encadenados antiguos.
- Para validar JWT, `oauth2ResourceServer` con el emisor configurado
  (`spring.security.oauth2.resourceserver.jwt.issuer-uri`). No escribas un
  filtro propio que interprete el token.
- Con sesión de navegador (formularios o SPA en el mismo dominio), mantén
  CSRF y usa `CookieCsrfTokenRepository.withHttpOnlyFalse()` para que el
  frontend lea el token. Desactívalo solo en APIs sin estado con token, y
  documenta el motivo.
- Cookies de sesión `Secure`, `HttpOnly` y `SameSite`
  (`server.servlet.session.cookie.*`); en WebLogic, revisa también
  `weblogic.xml`, que puede prevalecer.

## Autorización

```java
@PreAuthorize("hasRole('ADMIN')")
public List<UsuarioDto> listar() { ... }

@PreAuthorize("@autorizacion.esPropietario(#pedidoId, authentication)")
public void cancelar(Long pedidoId) { ... }
```

- Comprueba la propiedad del recurso en el servicio, no solo el rol: un
  usuario autenticado no puede leer ni cambiar pedidos ajenos cambiando el
  identificador de la URL.
- Si la regla depende de datos cargados, compruébala tras cargar la entidad
  y lanza `AccessDeniedException`; el manejador la traduce a 403.
- Prueba cada regla con `@WithMockUser` o `jwt()` de
  `spring-security-test`, incluido el caso denegado.

## CORS

```java
@Bean
CorsConfigurationSource corsConfigurationSource(@Value("${app.cors.origenes}") List<String> origenes) {
  var config = new CorsConfiguration();
  config.setAllowedOrigins(origenes);
  config.setAllowedMethods(List.of("GET", "POST", "PUT", "DELETE"));
  config.setAllowedHeaders(List.of("Authorization", "Content-Type"));
  config.setAllowCredentials(true);
  var source = new UrlBasedCorsConfigurationSource();
  source.registerCorsConfiguration("/api/**", config);
  return source;
}
```

Configúralo en la cadena de seguridad, no con `@CrossOrigin` repartido por
los controladores. Nunca origen `*` con credenciales.

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
