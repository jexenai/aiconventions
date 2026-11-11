---
paths:
  - "**/*.{java,php}"
---
# Organización del backend: casos de uso y validadores

Vale para Spring Boot y Laravel. Las carpetas, las anotaciones y el acceso a
datos de cada uno están en su `patrones.md`; el formato del nombre de los
casos de uso, en `comun/estilo-codigo.md`.

- La lógica de dominio vive solo en los casos de uso y en el validador de
  cada entidad. Controladores, modelos, mappers, DTO, repositorios y el
  resto son auxiliares: no deciden reglas de negocio.
- Caso de uso: una clase por operación (`BuscarTramitePorIdentificador`,
  `CrearUsuario`, `BuscarConsejeriasConFiltros`, `CerrarConvocatoria`) con
  un único método público `ejecutar`.

  > Aclaración: si `ejecutar` no cabe en una pantalla, es una señal de que
  > conviene extraer un paso a otro caso de uso.

- Las reglas de negocio de una entidad van en su validador: una única clase
  por entidad, con el sufijo `Validator` (`TramiteValidator`).
  - Expone un método público por acción que necesita validación, con un
    nombre legible desde el dominio (`validarCreacion`,
    `validarModificacion`, `validarBorrado`). Cada uno compone las reglas
    aplicables a la acción, en su orden de lectura.
  - Cada regla compartida o atómica es un método privado cuyo nombre expresa
    la condición de negocio (`comprobarQueLaConvocatoriaEsModificable`),
    reutilizado desde los métodos públicos: nunca dupliques una comprobación
    entre acciones.
  - Puede consultar datos cuando una regla depende del estado persistido.
  - Informa del incumplimiento con la excepción de dominio del proyecto y un
    mensaje que identifica la regla vulnerada.
- El caso de uso no comprueba reglas: llama al método correspondiente del
  validador justo antes de guardar y se limita a coordinar la operación.
- El validador no repite el formato de la entrada, que ya se valida en el
  límite: solo las condiciones que dependen del dominio, de su estado o de
  otros datos.
