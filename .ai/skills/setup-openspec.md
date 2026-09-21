# Adoptar OpenSpec

Utiliza este procedimiento cuando haya que decidir si el proyecto usará
OpenSpec y, si la respuesta es afirmativa, instalarlo e inicializarlo. La
skill `setup-project-context` deriva aquí esa decisión al adoptar la
plantilla; también puede invocarse más adelante.

El resultado es la decisión registrada en la ficha de `AGENTS.md` y, cuando se
adopta, OpenSpec inicializado en el repositorio. La forma de trabajar con
especificaciones y cambios la define el propio OpenSpec mediante el workflow
que instala; esta plantilla no la duplica.

## Límites

- Instala y ejecuta OpenSpec solo con confirmación explícita del usuario en el
  momento. Es la única excepción a la regla general de no instalar
  dependencias y no se extiende a ninguna otra herramienta.
- No sobrescribas una instalación existente. Si ya hay `openspec/`, limítate a
  registrar la decisión y la versión instalada.
- No crees, modifiques ni archives especificaciones ni cambios durante la
  adopción.
- No hagas commits ni pushes de lo generado.
- No copies los workflows ni las skills que genera OpenSpec en `AGENTS.md`,
  en `.ai/project/` ni en `.ai/skills/`.

## Decidir

1. Comprueba si ya existe `openspec/` o `openspec/config.yaml`. Si existe, no
   inicialices: obtén la versión instalada, registra la decisión y termina.
   Si la ficha dice `No se usa` y el usuario invoca este procedimiento, trátalo
   como una petición de reconsiderar la decisión y pregunta de nuevo.
2. Si no existe, pregunta al usuario si el proyecto va a usar OpenSpec. La
   pregunta es obligatoria: no elijas por él ni dejes la decisión implícita.
3. Si la respuesta es que no, registra `No se usa` en la ficha y no instales
   ni ejecutes nada.
4. Si el usuario no responde o pide decidir más tarde, conserva
   `[POR DEFINIR]` y decláralo pendiente. No lo conviertas en `No se usa` por
   omisión.

## Instalar

1. Consulta la documentación oficial vigente para el comando de instalación e
   inicialización y sus opciones. No des por fijos los nombres de los flags:
   compruébalos antes de ejecutarlos.
2. Indica al usuario qué vas a ejecutar, con qué gestor de paquetes y en qué
   ámbito, y espera su confirmación. La instalación requiere acceso a red.
3. Pregunta qué herramientas usa el proyecto de verdad y ejecuta la
   inicialización en la raíz indicándolas de forma no interactiva, porque el
   modo interactivo puede bloquearse en un entorno sin terminal. Configura
   únicamente esas herramientas.
4. Sustituye el contenido que genera la inicialización de `openspec/config.yaml`,
   que suele ser una plantilla comentada, por un contexto breve. Un ejemplo
   mínimo es:

   ```yaml
   schema: spec-driven

   context: |
     Las reglas comunes están en AGENTS.md.
     La documentación estable está en .ai/project/.
     Lee solo el contexto y los artefactos necesarios para el cambio.
   ```

5. Revisa todos los archivos generados antes de versionarlos: `openspec/`, las
   skills y comandos de cada herramienta configurada y los marcadores internos
   que deje. Comprueba también si ha modificado `AGENTS.md` o `CLAUDE.md`; si
   añade bloques, resuelve las duplicidades ajustando el texto de la plantilla,
   no el bloque gestionado por OpenSpec.

## Registrar la decisión

Actualiza la fila `Especificaciones` de la ficha de `AGENTS.md` con uno de
estos valores:

- `OpenSpec <versión>` cuando esté inicializado. La ruta siempre es
  `openspec/`, así que no la repitas en la ficha.
- `No se usa` cuando el usuario lo haya descartado.
- `[POR DEFINIR]` mientras la decisión siga pendiente.

## Comprobación final

1. Comprueba que `openspec/` y su configuración existen y que la versión
   registrada coincide con la instalada.
2. Revisa que la ficha de `AGENTS.md` no contradiga el estado real.
3. Revisa el diff para detectar archivos generados fuera de lo esperado.

Al terminar, informa de:

- La decisión del usuario y dónde ha quedado registrada.
- Comando ejecutado y versión instalada, si se ha instalado.
- Archivos generados o modificados, y los que quedan pendientes de revisar.
- Comprobaciones ejecutadas y limitaciones.
