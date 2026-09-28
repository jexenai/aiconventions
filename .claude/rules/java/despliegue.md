---
paths:
  - "**/pom.xml"
  - "**/build.gradle*"
  - "**/weblogic.xml"
  - "**/jboss-deployment-structure.xml"
  - "**/*Application.java"
  - "**/application*.{yml,yaml,properties}"
---
# Java: despliegue como WAR en WebLogic o JBoss

- La clase principal extiende `SpringBootServletInitializer` y el servidor
  embebido va con `scope` `provided`.
- Antes de añadir una dependencia que el servidor ya incluye (JPA, JAX-RS,
  validación, logging), revisa `weblogic.xml` o
  `jboss-deployment-structure.xml` para evitar conflictos de versiones.
- La base de datos se conecta con un *datasource* JNDI del servidor: la
  aplicación solo referencia su nombre.

> Aclaración: Spring Boot 4 (Spring Framework 7) exige Jakarta EE 11 y
> Servlet 6.1. WebLogic 15.1.1 implementa Jakarta EE 9.1 y JBoss EAP 8,
> Jakarta EE 10. Antes de dar por bueno un despliegue de Spring Boot 4 en
> uno de ellos, comprueba en la documentación del servidor que admite esas
> versiones; si no, dilo en lugar de forzar la configuración.
