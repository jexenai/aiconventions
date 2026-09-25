# Preparar las pruebas

Utiliza este procedimiento cuando a una parte del proyecto le falten las
herramientas para ejecutar sus pruebas o su análisis: al terminar
`setup-project-context` con comandos de pruebas pendientes, cuando
`development.md` no tenga el comando que una tarea necesita o cuando el
usuario lo pida.

El resultado son las herramientas elegidas instaladas y configuradas, una
prueba semilla por tipo que pasa y los comandos registrados en
`development.md` y en la ficha de `AGENTS.md`. Las pruebas semilla son
también el fichero vecino que hace cargar las reglas de `.claude/rules/` al
escribir las siguientes.

## Límites

- Instala solo con confirmación explícita del usuario en el momento, y solo
  dependencias de desarrollo. Es una excepción a la regla general de no
  instalar dependencias, igual que la de `setup-openspec`, y no se extiende a
  otras herramientas.
- No sustituyas una herramienta que el proyecto ya usa: si hay Jest, Pest,
  otro linter o una configuración propia, amplíala o déjala como está.
- No leas ni edites `.env`. No ejecutes migraciones ni pruebas contra una base
  de datos que no sea la de la tabla "Base de datos de pruebas" de
  `development.md`. Elegir esa base es decisión del usuario.
- No modifiques código de aplicación. Si el lint o el análisis estático
  encuentran errores en el código existente, infórmalos sin corregirlos.
- No edites `.gitlab-ci.yml` ni `docs/stack.yaml`. Los jobs de CI se proponen
  en el informe como fragmento.
- No hagas commits ni pushes.

## Herramientas del estándar

Propón estas herramientas, y solo para las partes que existan. Las versiones
no están fijadas: elige la última compatible con las versiones del manifiesto
(React, Vite, PHP, Laravel, Java, Spring Boot) según la documentación oficial
vigente, y muéstralas en la pregunta de instalación.

| Parte | Tipo | Herramienta | Comando que registra |
| ----- | ---- | ----------- | -------------------- |
| Vistas React | Pruebas de componentes | Vitest con `jsdom`, `@testing-library/react`, `@testing-library/user-event`, `@testing-library/jest-dom` y `vitest-axe`; MSW solo si las vistas llaman a una API | `npm test` (`vitest run`) |
| Vistas React | Lint | ESLint con `eslint-plugin-react-hooks` y `eslint-plugin-jsx-a11y` | `npm run lint` |
| Vistas React | Tipos | `tsc --noEmit`, solo si hay TypeScript | `npm run typecheck` |
| Laravel | Análisis estático | Larastan | `vendor/bin/phpstan analyse` |
| Laravel | Cobertura | PCOV, si no hay Xdebug | `php artisan test --coverage` |
| Laravel con Oracle | Conexión en pruebas | Extensión `oci8` y Oracle Instant Client | — |
| Spring Boot | Integración | Failsafe (Maven) o una tarea `integrationTest` (Gradle), con Testcontainers si la base es Oracle | `mvn verify` o `./gradlew integrationTest` |
| Spring Boot | Cobertura | JaCoCo | El de su informe |
| Extremo a extremo | Flujos críticos | Playwright, solo Chromium | `npm run test:e2e` |

> Aclaración: la extensión `oci8` y el Instant Client son software del
> sistema, no dependencias del proyecto. No los instales: indica en el
> informe qué falta en el equipo local y en la imagen de CI.

## Fase 1: recopilar evidencia

Solo lectura.

1. Lee la ficha de `AGENTS.md`, la sección "Comandos" y la tabla "Base de
   datos de pruebas" de `.ai/project/development.md`, y `docs/stack.yaml` si
   existe (`context.declared`, `context.ui`, `context.database` y
   `context.conventions.paths`).
2. Lee los manifiestos (`composer.json`, `package.json`, `pom.xml`,
   `build.gradle`) y la configuración existente: `phpunit.xml`,
   `phpstan.neon*`, `vite.config.*`, `vitest.config.*`, `eslint.config.*`,
   `.eslintrc*`, `tsconfig.json`, `playwright.config.*` y el fichero de CI.
3. Busca una prueba existente de cada tipo: unitaria y de *feature* o
   integración del backend, de componente de las vistas y de extremo a
   extremo.
4. Comprueba sin efectos lo que falta en el equipo: versiones de `php`,
   `node` y `java`, y las extensiones de PHP (`php -m`) si la base es Oracle
   o se pide cobertura.
5. Resume el estado en una tabla con una fila por parte y tipo:
   `Preparado`, `Falta herramienta`, `Falta prueba` o `No aplica`.

## Fase 2: preguntar

Usa el mecanismo de la tabla
[Mecanismo de preguntas](setup-project-context.md#mecanismo-de-preguntas).
Plantea solo las preguntas de esta sección, y de cada una solo las opciones
de lo que la fase 1 marcó como `Falta herramienta`. Omite la pregunta que se
quede sin opciones. Ninguna opción lleva `(Recomendado)`.

### Ronda 1: alcance

| Id | Cabecera | Pregunta | Opciones |
| -- | -------- | -------- | -------- |
| T1 | Vistas | ¿Qué preparo en las vistas? (selección múltiple) | `Pruebas de componentes` · `Lint` · `Comprobación de tipos` |
| T2 | Backend | ¿Qué preparo en el backend? (selección múltiple) | `Análisis estático` · `Cobertura` · `Pruebas contra <base de datos>` |
| T3 | Extremo | ¿Preparo las pruebas de extremo a extremo con Playwright? | `Sí` · `No por ahora` |
| T4 | BD pruebas | ¿Contra qué base de datos se ejecutan las pruebas? | `Base dedicada que ya existe (indica cuál)` · `Contenedor local de <base de datos>` · `Dejar pendiente` |

T4 solo se plantea si la tabla "Base de datos de pruebas" está
`[POR DEFINIR]` y el proyecto usa base de datos.

### Ronda 2: instalación

| Id | Cabecera | Pregunta | Opciones |
| -- | -------- | -------- | -------- |
| T5 | Instalación | ¿Ejecuto la instalación? | `Ejecutar <comandos>` · `Cancelar y dejar pendiente` |

En la descripción de `Ejecutar` indica los comandos exactos, los paquetes con
su versión, que requiere acceso a red y los ficheros que se crearán o
modificarán.

Si una ronda no obtiene respuesta, no vuelvas a preguntar: no instales nada y
declara pendiente todo lo que dependía de ella.

## Fase 3: instalar y configurar

1. Instala con el gestor que indica el fichero de bloqueo, como dependencias
   de desarrollo (`npm install -D`, `composer require --dev`), y en Java
   añade los plugins o dependencias de prueba al manifiesto.
2. Configura cada herramienta elegida:
   - **Vitest:** bloque `test` en `vite.config.*` con `environment: "jsdom"`,
     `setupFiles` e `include` limitado a la carpeta de las vistas
     (`resources/js/` en Laravel). Si el plugin de Laravel interfiere,
     `vitest.config.*` propio con el plugin de React y el mismo alias `@`.
     El fichero de `setupFiles`, en `<vistas>/test/setup.*`, registra los
     *matchers* de `jest-dom`.
   - **ESLint:** si no hay configuración, `eslint.config.js` con las reglas
     recomendadas de `react-hooks` y `jsx-a11y` sobre la carpeta de las
     vistas; si la hay, añade solo esos dos plugins. No ejecutes `--fix`
     sobre el código existente.
   - **Larastan:** `phpstan.neon` con la extensión de Larastan, `paths: [app]`
     y el nivel más alto que el código actual supere sin errores. Si no
     supera ni el nivel 1, genera una *baseline* e indícalo.
   - **Base de datos de pruebas:** en `phpunit.xml`, la conexión elegida en
     T4 sin credenciales; las credenciales, en variables de entorno o en un
     `.env.testing` fuera de Git que completa el usuario. En Spring Boot,
     Testcontainers o un perfil `test`.
   - **Playwright:** la configuración de la skill `e2e-testing`, si existe,
     y `playwright/.auth/`, `test-results/` y `playwright-report/` en
     `.gitignore`.
3. Añade a `package.json` los *scripts* de la tabla de herramientas que no
   existan. No cambies los que ya están.

## Fase 4: pruebas semilla

Crea una prueba por cada tipo preparado que no tenga ya una. Como aún no hay
un fichero vecino, lee antes las reglas del tipo en `.claude/rules/`
(`comun/pruebas.md` y las del lenguaje, y las de `inertia/` si existen).

- Prueba comportamiento real del código existente: una página que se
  muestra, un componente que pinta su etiqueta o una ruta protegida que
  redirige al invitado. No crees código de aplicación para poder probarlo.
  Si no hay nada que probar, omítela e indícalo.
- Nombra el caso en la descripción de la prueba, como las demás.
- Con Inertia, crea una prueba de *feature* con `assertInertia` y otra de
  componente de la misma página. La de componente simula `@inertiajs/react`
  y pasa las props directamente:

```tsx
vi.mock("@inertiajs/react", () => ({
  Head: () => null,
  Link: ({ href, children }: { href: string; children: React.ReactNode }) => <a href={href}>{children}</a>,
  usePage: () => ({ props: { auth: { user: { name: "Ana" } } } }),
}));

test("muestra el nombre del usuario en la cabecera", () => {
  render(<Dashboard />);
  expect(screen.getByText("Ana")).toBeInTheDocument();
});
```

  Si la página usa `useForm`, simúlalo devolviendo `data`, `setData`,
  `errors`, `processing` y `post` como dobles.

## Fase 5: comprobar

1. Ejecuta cada prueba semilla y cada herramienta configurada, filtrando al
   fichero y mostrando solo el resumen. Las semillas deben pasar: prueban
   comportamiento existente.
2. Ejecuta las que usan base de datos solo si la tabla "Base de datos de
   pruebas" está resuelta y la conexión configurada coincide con ella.
3. Del lint, los tipos y el análisis estático, anota cuántos errores hay en
   el código existente y dónde se concentran, sin corregirlos.

## Fase 6: registrar e informar

1. Registra los comandos comprobados en la sección "Comandos" de
   `development.md`, con una fila por parte, y resume los habituales en la
   ficha de `AGENTS.md`.
2. Completa la tabla "Base de datos de pruebas" con la respuesta a T4.

Termina con un informe con estas secciones:

1. **Preguntas:** una tabla con las filas T1 a T5, con `Pregunta`,
   `Respuesta` y `Estado` (`Confirmada`, `No planteada` o `Pendiente`).
2. **Estado:** la tabla de la fase 1 actualizada.
3. **Instalación:** comandos ejecutados, paquetes y versiones.
4. **Ficheros:** creados y modificados.
5. **Comprobaciones:** resultado de cada semilla y herramienta, y los errores
   existentes que no se corrigieron.
6. **CI:** fragmento de `.gitlab-ci.yml` con un job por herramienta
   preparada y lo que necesita su imagen (por ejemplo, `oci8` y el Instant
   Client), para que el usuario lo revise y lo añada.
7. **Pendientes:** lo que queda y por qué, incluido lo que falta en el
   equipo local.
