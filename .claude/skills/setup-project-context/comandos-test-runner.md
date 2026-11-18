# Generar los comandos de test-runner

Lo aplica `setup-project-context` al final de su fase 4, cuando `development.md` ya está actualizado y
los stacks no usados se han retirado. También lo aplican `setup-testing` en
su fase 6 y cualquier tarea que cambie la tabla "Comandos", la "Base de datos
de pruebas" o el "Entorno local". `test-runner` usa `haiku` y no interpreta
la tabla: aquí se resuelve todo lo que exige criterio, para que el agente
solo ejecute.

1. Si no existe `.claude/agents/test-runner.md`, omite este procedimiento e
   indícalo en el informe.
2. Construye una fila por parte y alcance a partir de la tabla "Comandos":

   | Fila de "Comandos" | Alcance |
   | ------------------ | ------- |
   | Comprobar formato | `formato` |
   | Ejecutar análisis estático | `analisis` |
   | Compilar | `compilar` |
   | Pruebas unitarias | `unit` |
   | Pruebas de integración | `integration` |
   | Pruebas de extremo a extremo | `e2e` |
   | Una sola prueba o clase | `prueba` |

3. Resuelve cada fila con estas reglas:
   - **Sin comando** (`[POR DEFINIR]`): no la incluyas; el agente informará
     «sin comando». Si el paso no existe en esa parte (compilar en PHP,
     tipos en JavaScript sin TypeScript), inclúyela sin comando y con
     `Condición` = `no aplica`.
   - **Solo lectura:** nunca incluyas un comando que escriba ficheros
     (`spotless:apply`, `spotlessApply`, `--fix`, `:fix`, `--write`, `pint`
     sin `--test`). Si el formato solo tiene el comando que corrige, no
     incluyas la fila y anótalo en "Pendientes".
   - **Compilar sin pruebas:** si el comando también ejecuta las pruebas,
     usa su variante sin ellas (`mvn -DskipTests package`,
     `./gradlew assemble`).
   - **Unitarias e integración:** si comparten comando y la herramienta
     permite separarlas (`testsuites` `Unit` y `Feature` de `phpunit.xml`,
     carpetas de Vitest, Surefire y Failsafe), usa un filtro por tipo
     (`php artisan test --testsuite=Unit`). Si no, una sola fila `unit` con
     `Incluye` = `integration`.
   - **Inclusiones:** si una fila ejecuta también lo de otra (`mvn verify`
     ejecuta las unitarias de `mvn test`), anótalo en `Incluye`.
   - **Prueba concreta:** sustituye el marcador del comando
     (`NombreDeLaPrueba`) por `{prueba}`.
   - **Salida resumida:** añade la opción de la herramienta que reduce la
     salida sin ocultar los fallos (`--compact` en Artisan, `-q` en Maven,
     `--reporter=dot` en Vitest), si el comando no la lleva.
   - **Entorno local:** incorpora al comando los ajustes obligatorios de esa
     tabla (shell, ruta, `--memory-limit`).
   - **Base de datos:** si la fila ejecuta pruebas que usan base de datos
     (`RefreshDatabase`, migraciones, repositorios JPA) y la "Base de datos
     de pruebas" está `[POR DEFINIR]` o apunta a una base compartida, pon
     `Condición` = `no ejecutar: base de datos de pruebas sin confirmar`.
     Una base aislada (SQLite en memoria, Testcontainers) no la necesita.
     Decide con la configuración de pruebas, sin leer el `.env`.
   - **Requisitos:** un requisito de la columna "Directorio o requisito"
     que no sea un directorio (servidor arrancado, navegadores de
     Playwright) va a `Condición` = `requiere: <requisito>`.
4. Sustituye solo el contenido entre `<!-- comandos-test-runner:inicio … -->`
   y `<!-- comandos-test-runner:fin -->` por una tabla con las columnas
   `Alcance`, `Parte`, `Comando`, `Directorio`, `Incluye` y `Condición`
   (`—` si está vacía), con las filas en el orden de la tabla del paso 2.
   Si no queda ninguna fila, deja «Sin generar.». No edites el resto del
   fichero.

   ```markdown
   | Alcance | Parte | Comando | Directorio | Incluye | Condición |
   | ------- | ----- | ------- | ---------- | ------- | --------- |
   | formato | Backend | vendor/bin/pint --test | . | — | — |
   | compilar | Backend | — | — | — | no aplica |
   | unit | Backend | php artisan test --testsuite=Unit --compact | . | — | — |
   | integration | Backend | php artisan test --testsuite=Feature --compact | . | — | no ejecutar: base de datos de pruebas sin confirmar |
   | prueba | Backend | php artisan test --compact --filter={prueba} | . | — | — |
   ```

5. Añade a `permissions.allow` de `.claude/settings.json`, por cada fila que
   se pueda ejecutar (sin `no aplica` ni `no ejecutar`), dos reglas:
   `Bash(<comando>)` y `PowerShell(<comando>)`. Para la fila `prueba`,
   `Bash(<comando hasta {prueba}>*)` y su equivalente de `PowerShell`.
   `test-runner` declara las dos herramientas y en Windows puede usar
   cualquiera; una regla de `Bash` no cubre lo que se ejecuta con
   `PowerShell`. Antes de sustituir el bloque, lee el anterior y quita de
   `allow` las reglas de sus comandos que ya no estén. No toques las demás
   reglas.
6. Anota en el informe las filas generadas y las omitidas con su motivo.

Un hook (`.claude/hooks/test-runner-solo-bloque.sh`) compara cada comando
que lanza `test-runner` con la columna `Comando` de este bloque y bloquea
lo que no coincida. Por eso:

- Escribe en `Comando` el comando completo y exacto, sin `cd`: la carpeta
  va en `Directorio` y el hook admite que el agente la anteponga.
- No uses `|` dentro de un comando: rompe la tabla. Si hace falta una
  tubería, crea un script del proyecto y pon su llamada.
- `{prueba}` solo admite el nombre o la ruta de una prueba, sin espacios ni
  comillas: no pongas el marcador entre comillas.
