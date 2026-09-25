# Arquitectura del proyecto

Consulta este documento para entender qué hace el sistema, dónde está cada
parte y qué restricciones generales deben respetarse.

El propósito, las tecnologías y la ruta del código están en la ficha de
[AGENTS.md](../../AGENTS.md). Este documento añade las reglas generales y los
datos que se amplían cuando una tarea los necesita.

## Reglas

### Dominio

- Usa el vocabulario acordado y no deduzcas reglas de negocio solo a partir de
  nombres técnicos.
- No implementes capacidades marcadas fuera de alcance aunque parezcan una
  extensión natural.
- La petición y las especificaciones describen la intención; el código y la
  configuración describen lo implementado. Señala cualquier discrepancia.

### Arquitectura

- Mantén cada responsabilidad en el componente que la posee y evita ciclos.
- Usa contratos públicos entre módulos; no dependas de detalles internos para
  resolver una necesidad puntual.
- Elige la solución más simple que cubra el requisito actual. Evita capas y
  abstracciones preventivas.
- Antes de añadir una dependencia, comprueba las capacidades existentes y
  valora mantenimiento, licencia, seguridad y encaje con el stack.
- Conserva la compatibilidad de contratos y datos persistentes o documenta su
  migración.

### Seguridad

- Valida entradas y autorización en los límites de confianza; ocultar una
  acción en la interfaz no sustituye el control de acceso.
- Aplica el menor privilegio y no registres secretos ni datos personales
  innecesarios.
- Si encuentras un secreto expuesto, informa sin reproducir su valor. Eliminarlo
  del archivo no equivale a revocarlo ni a retirarlo del historial.
- Revisa el efecto de nuevas dependencias e integraciones sobre los datos.
- Pushes, despliegues, publicaciones, migraciones destructivas y cambios en
  producción requieren autorización explícita para ese entorno.

## Ampliar cuando haga falta

Completa estas tablas cuando una tarea necesite la información o al ejecutar
`setup-project-context`. Un campo `[POR DEFINIR]` que no afecte a la tarea
actual puede quedarse pendiente. No describas como existente una capacidad
propuesta o una arquitectura todavía no creada.

### Alcance y componentes

| Dato | Valor |
| ---- | ----- |
| Usuarios principales | [POR DEFINIR] |
| Capacidades incluidas | [POR DEFINIR] |
| Capacidades fuera de alcance | [POR DEFINIR] |
| Componentes principales | [POR DEFINIR] |
| Persistencia y propiedad de los datos | [POR DEFINIR] |
| Sistemas externos | [POR DEFINIR] |
| Entornos de ejecución y despliegue | [POR DEFINIR] |

### Mapa del repositorio

Registra solo rutas útiles para navegar, no el árbol completo. Indica qué
archivos no deben editarse a mano y cómo se regeneran.

| Área | Ruta real | Responsabilidad |
| ---- | --------- | --------------- |
| Contratos o interfaces públicas | [POR DEFINIR] | [POR DEFINIR] |
| Persistencia y migraciones | [POR DEFINIR] | [POR DEFINIR] |
| Pruebas | [POR DEFINIR] | [POR DEFINIR] |
| Configuración y dependencias | [POR DEFINIR] | [POR DEFINIR] |
| Integración continua y despliegue | [POR DEFINIR] | [POR DEFINIR] |
| Archivos generados o estado de herramientas | [POR DEFINIR] | [POR DEFINIR] |

### Vocabulario e invariantes

| Término | Significado acordado |
| ------- | -------------------- |
| [POR DEFINIR] | [POR DEFINIR] |

| Regla transversal o invariante | Alcance o referencia |
| ------------------------------ | -------------------- |
| [POR DEFINIR] | [POR DEFINIR] |

### Decisiones de arquitectura

| Decisión estable | Motivo y consecuencias | Referencia |
| ---------------- | ---------------------- | ---------- |
| [POR DEFINIR] | [POR DEFINIR] | [POR DEFINIR] |

### Seguridad del sistema

| Dato | Valor |
| ---- | ----- |
| Autenticación | [POR DEFINIR] |
| Autorización y separación de usuarios | [POR DEFINIR] |
| Datos sensibles | [POR DEFINIR] |
| Gestión de secretos | [POR DEFINIR] |
| Operaciones que requieren autorización | [POR DEFINIR] |

| Área que requiere revisión reforzada | Riesgo | Comprobación adicional |
| ------------------------------------ | ------ | ---------------------- |
| [POR DEFINIR] | [POR DEFINIR] | [POR DEFINIR] |
