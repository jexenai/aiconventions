# Desarrollo y validación

Consulta este documento antes de implementar, corregir, refactorizar o revisar
código y pruebas.

## Comandos

Registra únicamente comandos comprobados y su directorio de ejecución. Los de
arranque y pruebas habituales se resumen también en la ficha de
[AGENTS.md](../../AGENTS.md); mantén ambos coherentes.

| Operación | Comando | Directorio o requisito |
| --------- | ------- | ---------------------- |
| Preparar dependencias | [POR DEFINIR] | [POR DEFINIR] |
| Arrancar en local | [POR DEFINIR] | [POR DEFINIR] |
| Compilar | [POR DEFINIR] | [POR DEFINIR] |
| Comprobar formato | [POR DEFINIR] | [POR DEFINIR] |
| Ejecutar análisis estático | [POR DEFINIR] | [POR DEFINIR] |
| Pruebas unitarias | [POR DEFINIR] | [POR DEFINIR] |
| Pruebas de integración | [POR DEFINIR] | [POR DEFINIR] |
| Pruebas de extremo a extremo | [POR DEFINIR] | [POR DEFINIR] |

Consulta la configuración real de CI antes de afirmar qué comprobaciones son
obligatorias. No ejecutes literalmente los marcadores pendientes.

## Implementación y calidad

- Lee el código afectado y sus pruebas. Comprueba que rutas, símbolos y
  dependencias existen antes de usarlos.
- Haz cambios pequeños y completos, coherentes con los patrones del módulo.
- No mezcles el objetivo con limpiezas ajenas ni reviertas trabajo de otros.
- Prefiere código explícito, nombres descriptivos y responsabilidades claras.
- Evita abstracciones especulativas y soluciones provisionales que se sepa que
  habrá que rehacer inmediatamente.
- Expresa los errores de forma útil; no ocultes fallos con capturas genéricas o
  valores de sustitución sin justificar.
- Mantén coherentes manifiestos y archivos de bloqueo al cambiar dependencias.
- No edites archivos generados si existe una fuente o comando de regeneración.

### Comentarios en el código

- Explica decisiones, restricciones, workarounds y comportamientos no evidentes;
  no repitas lo que ya dice el código.
- Mantén los comentarios sincronizados y elimina los obsoletos.
- No conserves código comentado «por si acaso»; el historial ya lo preserva.
- No incluyas secretos, datos personales ni referencias temporales sin contexto.

## Pruebas

- Comprueba comportamiento observable, límites, errores y permisos relevantes.
- Añade una prueba de regresión al corregir un fallo cuando sea razonable.
- Empieza por las pruebas del área afectada y amplía según el riesgo.
- Amplía la validación si cambian contratos públicos, datos persistentes,
  seguridad, varias capas o dependencias.
- Distingue pruebas automáticas de revisión funcional o de dominio: una no
  sustituye a la otra.
- No desactives pruebas para presentar una entrega como correcta.
- Si una prueba falla, diferencia un problema introducido de uno previo o del
  entorno y aporta la evidencia disponible.

## Entrega

- Revisa el diff final y elimina archivos temporales o cambios accidentales.
- Si el árbol cambia después de validarlo, repite las comprobaciones afectadas.
- No ejecutes commits, pushes, despliegues ni publicaciones sin autorización.
- Informa del comportamiento resultante, comprobaciones ejecutadas, resultados
  y cualquier limitación o trabajo pendiente.
