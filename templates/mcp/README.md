# Fragmentos de servidores MCP

Cada archivo declara un servidor MCP listo para fusionarse en el `.mcp.json`
del proyecto. Las plantillas de stack los referencian en `context.mcp` y la
skill `setup-project-context` los materializa solo cuando el stack los declara.

| Fragmento | Servidor | Para qué sirve |
| --------- | -------- | -------------- |
| [shadcn.json](shadcn.json) | `shadcn` | Catálogo de componentes de shadcn/ui y de los registros declarados en `components.json` |

Un fragmento describe la conexión, no la aprobación. El servidor queda
pendiente hasta que el usuario lo aprueba en su primera sesión interactiva.
