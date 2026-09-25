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
