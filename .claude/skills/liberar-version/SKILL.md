---
name: liberar-version
description: Libera una versión para el usuario final. Actualiza el manual de usuario (sitio VitePress en docs/manual con capturas por perfil), registra las novedades y, tras la revisión del usuario, hace el commit y crea el tag. Úsalo solo cuando el usuario pida liberar una versión o generar el manual.
argument-hint: "[versión, opcional; p. ej. v1.2.0]"
disable-model-invocation: true
---

Libera la versión `$ARGUMENTS`. Una versión liberada con esta skill es un
tag de Git en un commit que ya contiene su manual de usuario actualizado.
Los tags también pueden crearse sin la skill; en ese caso no hay manual
para esa versión y la siguiente ejecución de la skill recoge sus cambios.

**Resultado**: `docs/manual/` actualizado (texto, capturas y novedades), un
commit con esos cambios y un tag anotado sobre ese commit.

**Fuera de alcance**: push, despliegue y publicación del manual; cambios en
el código de la aplicación. Si para capturar una pantalla hiciera falta
tocar la aplicación, detente y explícalo.

## 1. Comprobaciones previas

1. Lee los tags existentes con `git tag --sort=-v:refname`. La versión
   anterior es el primero con formato de versión.
2. **Con argumento**, úsalo como versión. Debe seguir el formato de los tags
   existentes (`vMAYOR.MENOR.PARCHE` si no hay ninguno) y ser mayor que la
   versión anterior, o ser ese mismo tag (modo tag existente, punto 4).
3. **Sin argumento**, decide la versión:
   - Si el último tag no tiene entrada en `docs/manual/novedades.md` y
     cumple las condiciones del punto 4, documenta ese tag (se creó a mano y
     le falta el manual).
   - Si no, calcula la siguiente.
   - Sin tags anteriores: `v0.1.0`.
   - Con cambios visibles para el usuario desde la versión anterior (paso
     3): incrementa MENOR y pon PARCHE a 0 (`v1.2.3` → `v1.3.0`).
   - Solo correcciones o cambios internos: incrementa PARCHE
     (`v1.2.3` → `v1.2.4`).
   - MAYOR nunca se incrementa automáticamente: solo si el usuario lo pide.

   Indica al usuario la versión calculada y el motivo; puede cambiarla en
   la revisión del paso 7.
4. Comprueba si el tag ya existe (`git rev-parse -q --verify
   "refs/tags/<versión>"`). Si existe, se trabaja en **modo tag existente**:
   se genera su manual y no se crea, mueve ni borra ningún tag. Solo es
   posible si se cumplen estas tres condiciones; si falla alguna, detente y
   explica por qué:
   - Es el último tag de versión. El manual describe el código actual, no
     el de una versión antigua.
   - `docs/manual/novedades.md` aún no tiene su entrada. Si ya la tiene, ese
     manual ya existe.
   - El código de la aplicación no ha cambiado desde el tag:
     `git diff --quiet <versión> HEAD -- <código de aplicación de la ficha>`.
     Si ha cambiado, el manual describiría cosas que el tag no contiene;
     propón liberar una versión nueva.

   El commit del manual queda después del tag, no dentro de él. Díselo al
   usuario.
5. Lee la ficha de `AGENTS.md`. Con `Capa de vistas: No aplica` no hay
   manual: informa y detente sin crear nada. Si las vistas se sirven con
   Inertia (ficha, `docs/stack.yaml` o `@inertiajs/react` en
   `package.json`), detente también: esa variante está pendiente y sin
   probar. Explica al usuario las diferencias del
   [anexo](#pendiente-laravel-con-inertia) y no prepares nada.
6. Ejecuta `git status`. Si hay cambios sin confirmar fuera de
   `docs/manual/`, detente: el tag no los incluiría y el manual describiría
   algo distinto de lo liberado. Pregunta si se confirman antes o se dejan
   fuera.
7. Si el proyecto ya tiene manual (`docs/manual/.vitepress/config.mts`),
   comprueba solo lo que cambia de un equipo a otro: las dependencias
   instaladas y el navegador de Playwright (filas 2 y 4 de la tabla del
   paso 2). La primera vez, la comprobación completa está en el paso 2.

## 2. Preparación (solo la primera vez)

Si no existe `docs/manual/.vitepress/config.mts`, el proyecto aún no tiene
manual.

### Requisitos

Comprueba todos antes de crear nada y presenta el resultado en una tabla
(requisito, estado, qué falta). No instales nada sin confirmación: reúne lo
que falte y pídela una sola vez, junto con la lista de ficheros de abajo.

| # | Requisito | Cómo se comprueba | Si falta |
| - | --------- | ----------------- | -------- |
| 1 | Node.js con la versión de la ficha (o de `engines` en `package.json`) | `node -v` | Detente: lo instala el usuario |
| 2 | Dependencias instaladas | `npm ls --depth=0` sin errores de dependencias ausentes | `npm install` |
| 3 | `@playwright/test` en `devDependencies` | `npx playwright --version` | Sigue antes `setup-testing` |
| 4 | Navegador Chromium de esa versión de Playwright, el completo (`channel: 'chromium'`) y no solo el modo sin interfaz: solo con él los elementos nativos, como el selector de ficheros, salen en español | `npx playwright install --dry-run chromium` da la carpeta de instalación; comprueba que existe | `npx playwright install chromium` (en Linux sin escritorio, con `--with-deps`) |
| 5 | Simulación de la API en los e2e | Hay un soporte de e2e que intercepta las llamadas (`page.route`, MSW…) | Pregunta: sin él, las capturas necesitan el backend arrancado y pueden salir datos reales |
| 6 | Puertos 5174 (manual) y 5175 (capturas) libres | Que no haya nada escuchando en ellos (`netstat -ano` en Windows, `lsof -i` en Linux y macOS) | Pregunta qué puertos usar y ajústalos en los scripts y en `capturas.config.ts` |
| 7 | VitePress y `medium-zoom` | `npm ls vitepress medium-zoom` | Se instalan en la preparación |

El backend no es un requisito si se cumple el 5.

### Instalación y ficheros

Enumera al usuario lo que vas a crear e instalar y espera su confirmación:

- `vitepress` y `medium-zoom` como dependencias de desarrollo (última versión
  estable de cada una). `medium-zoom` permite ampliar las capturas al
  pulsarlas, a su tamaño original.
- La copia de [plantillas/](plantillas/) en `docs/manual/`, con la misma
  estructura, incluido el tema de `.vitepress/theme/`.
- Scripts en `package.json`:
  - `"manual:dev": "vitepress dev docs/manual --port 5174"`
  - `"manual:build": "vitepress build docs/manual"`
  - `"manual:preview": "vitepress preview docs/manual --port 5174"`
  - `"manual:capturas": "playwright test -c docs/manual/capturas/playwright.config.ts"`
  - Al final del script de build de la aplicación, `&& npm run manual:build`
    (por ejemplo `"build": "tsc -b && vite build && npm run manual:build"`).
    El manual se compila después, porque el build de la aplicación vacía su
    carpeta de salida.
- En `.gitignore`: `docs/manual/.vitepress/cache`.

**El manual se publica con la aplicación, en `/manual/`.** Busca en la
configuración del build y del despliegue (`vite.config.*`, la ficha, el
fichero de stack) qué carpeta genera el build y se publica, y apunta a ella
`outDir` en `.vitepress/config.mts` (`<carpeta>/manual`). Comprueba después
que no choca con nada:

- Ninguna ruta de la aplicación empieza por `/manual`. Si alguna lo hace,
  pregunta qué ruta usar y cámbiala en `RUTA`.
- Las comprobaciones del build de la aplicación (scripts que revisan la
  carpeta de salida) siguen pasando con el manual dentro.
- Servida la carpeta de salida (en Vite, `vite preview`), la aplicación
  responde en `/` y en sus rutas, y el manual en `/manual/`, con sus
  imágenes y sin errores en las respuestas.

**En desarrollo, el manual va por el mismo puerto que la aplicación.** Si
las vistas se construyen con Vite, añade a `vite.config.ts` este plugin, que
monta VitePress como middleware del servidor de desarrollo y lo atiende en
`/manual/` (la aplicación sigue en `/`). Así `npm run dev` sirve ambos, con
recarga en caliente del manual:

```ts
import { fileURLToPath } from 'node:url'
import { defineConfig, type Plugin } from 'vite'

// En desarrollo, sirve el manual (VitePress) en /manual/ por el mismo puerto
// que la aplicación. En producción lo publica el build en <salida>/manual/.
function manualEnDesarrollo(): Plugin {
  return {
    name: 'manual-en-desarrollo',
    apply: 'serve',
    async configureServer(servidor) {
      const { createServer } = await import('vitepress')
      const manual = await createServer(
        fileURLToPath(new URL('./docs/manual', import.meta.url)),
        // Sin servidor propio: comparte el de la aplicación. Su HMR usa otro puerto.
        { middlewareMode: true, hmr: { port: 24679 } },
      )
      servidor.middlewares.use((req, res, next) => {
        if (req.url?.startsWith('/manual')) manual.middlewares(req, res, next)
        else next()
      })
      servidor.httpServer?.once('close', () => void manual.close())
    },
  }
}
```

Añade `manualEnDesarrollo()` a `plugins`. Si `24679` está ocupado, elige otro
puerto para el HMR del manual. Comprueba con `npm run dev` que `/` y
`/manual/` responden por el mismo puerto. Sin Vite, `npm run manual:dev`
(puerto 5174) sigue siendo la vía.

Si el build no es de Node (por ejemplo, Maven o Gradle sirviendo
estáticos), pregunta cómo encadenar `npm run manual:build` antes de
tocarlo.

Después completa `docs/manual/capturas/capturas.config.ts` con evidencia
del proyecto, no por suposición:

| Dato | Dónde buscarlo |
| ---- | -------------- |
| `servidor` | Configuración de Playwright y scripts de arranque. Usa un puerto propio y `reuseExistingServer: false`. **Compila y sirve el resultado** (en Vite, `vite build --outDir node_modules/.manual/dist` y `vite preview`) en lugar de usar el servidor de desarrollo: este compila al vuelo y, con las capturas en paralelo, algunas páginas se quedan a medias o agotan el tiempo. Compilar a una carpeta propia evita pisar el `dist` del usuario |
| `servidor.entorno` | Variables que cambian el aspecto según el entorno (indicadores, colores, avisos). Fíjalas para que la app se vea como en producción. **Comprueba que la aplicación sigue siendo utilizable con ellas**: un interruptor de identidad o de desarrollo que, apagado, deja solo un aviso de "inicio de sesión no disponible" produce capturas inútiles; en ese caso déjalo activo y oculta solo su elemento visual (`ocultar`) |
| `prepararPagina` | API simulada con datos ficticios **de todas las pantallas** (`capturas/datos.ts`). El soporte de los e2e suele devolver listas vacías: sirve de punto de partida (rutas, formato de respuesta), no de datos. Inventa datos coherentes entre sí (las entidades que se referencian unas a otras, como un registro y su responsable) y con casos que el manual explica: un estado de aviso, una lista con varios elementos, un historial con altas y cambios |
| `perfiles` | Perfiles o roles de la aplicación y cómo fijan la sesión los e2e |
| `ocultar` | Elementos que solo existen en desarrollo (paneles de identidad, depuración) |

Si el proyecto necesita más ficheros para las capturas (datos, utilidades),
créalos en `docs/manual/capturas/`.

Con `npm run manual:capturas` y una captura de prueba, comprueba que la
configuración funciona antes de seguir.

### Estilo de la aplicación

El manual se ve como la aplicación. Busca su estilo en el propio proyecto,
nunca lo supongas ni lo copies de otro:

| Qué | Dónde buscarlo | Dónde va en el manual |
| --- | -------------- | --------------------- |
| Colores (principal, acento, fondo, menú lateral, texto, texto secundario, bordes) en claro y en oscuro | Las variables CSS globales de la aplicación (`index.css`, `app.css`, tema de Tailwind) o, si la ficha declara un servidor MCP de sistema de diseño, sus tokens | Variables `--vp-c-*` de `.vitepress/theme/custom.css`, con un comentario que diga el token de origen |
| Tipografías de cuerpo y de títulos | Las fuentes que carga la aplicación (`@fontsource`, `@font-face`, Google Fonts) y a qué elementos las aplica | `@import` y `--vp-font-family-base` / `--manual-fuente-titulos` |
| Radio de esquinas | El token de radio (`--radius` o equivalente) | `--manual-radio` |
| Logo, nombre y favicon | Cabecera o menú de la aplicación y su carpeta pública | `logo`, `siteTitle`, `vite.publicDir` y `head` de `config.mts`. Apunta a la carpeta pública de la aplicación en lugar de copiar los ficheros |

Si la aplicación no tiene tema oscuro, deja el del manual con los colores
por defecto de VitePress y dilo en el resumen.

Compila el manual, sírvelo y captura una página con Playwright en claro, en
oscuro y a 390 px de ancho. Compara con las capturas de la aplicación y
corrige hasta que:

- Colores y tipografías coincidan con los de la aplicación.
- El título de la cabecera no se monte sobre el buscador (con un logo ancho,
  usa un `siteTitle` corto, como el que muestra la aplicación).
- Los textos sobre fondos de color se lean bien en los dos temas. Si un
  token de acento resulta demasiado intenso como fondo, usa el de las
  tarjetas o el del menú.

## 3. Qué ha cambiado

- **Sin manual previo** (no existe `docs/manual/novedades.md` con
  entradas): redacta el manual completo con las fuentes de la tabla de
  abajo.
- **Con versión anterior** `<previo>` (el último tag, tenga o no manual; en
  modo tag existente, el anterior a ese tag):
  - `git log --oneline <previo>..HEAD`
  - `git diff --stat <previo>..HEAD` sobre el código de aplicación de la
    ficha.
  - Los cambios de OpenSpec archivados en ese intervalo
    (`git diff --name-only --diff-filter=A <previo>..HEAD -- openspec/changes/archive`):
    su `proposal.md` y sus deltas dicen qué cambió para el usuario.
  - Si hay tags intermedios creados sin la skill, el intervalo empieza en
    el último tag que tiene entrada en `novedades.md`, para no perder sus
    cambios.

Cada fuente responde a una pregunta distinta:

| Fuente | Qué aporta | Qué no aporta |
| ------ | ---------- | ------------- |
| Especificaciones de OpenSpec (`openspec list --specs`, `openspec show <id> --type spec`), si el proyecto las usa | Qué hace cada función, sus reglas, permisos por perfil y casos límite | Cómo se ve ni en qué orden la encuentra el usuario: están organizadas por capacidad, no por pantalla |
| Rutas, menú y componentes de la aplicación | Qué pantallas hay, cómo se llega a ellas y qué textos, botones, columnas y avisos muestra cada una | El porqué de las reglas |
| Capturas y e2e | Cómo se ve de verdad y qué recorridos hace el usuario | Todos los casos |

Clasifica cada cambio como **visible para el usuario** (pantalla, campo,
acción o mensaje nuevos o distintos; algo que deja de existir) o
**interno** (refactorización, pruebas, configuración). Solo los visibles
llegan al manual. Comprueba en el código que cada cambio visible está
implementado tal como lo vas a describir.

## 4. Redacción

Escribe para el usuario final, en español de España y en segunda persona.

**El manual sigue lo que el usuario ve, no cómo está especificado.** Las
especificaciones son la fuente de qué hace cada función, pero el orden y
la forma del manual salen de la interfaz:

- **Orden de las páginas**: el de uso. Primero el acceso y la navegación
  general (zonas de la pantalla, menú, cabecera); después las áreas en el
  orden del menú de la aplicación; las de administración, al final. Una
  función que aparece en varias especificaciones se explica una vez, en la
  pantalla donde el usuario la usa.
- **Orden dentro de cada página**: el recorrido visual de la pantalla.
  Primero qué es y cómo se llega; después una captura de la pantalla
  completa y sus zonas de arriba abajo (filtros, listado, acciones);
  después las tareas, cada una con sus pasos en el orden en que el usuario
  pulsa; al final los avisos, mensajes y estados vacíos que puede
  encontrarse.
- **Comprueba cada descripción con la interfaz.** El nombre de un botón,
  una columna o un mensaje sale del código o de la captura, nunca de la
  especificación. Si discrepan, manda lo implementado; anota la
  discrepancia para el resumen del paso 7.

- Una página por área funcional (`docs/manual/<area>.md`), orientada a
  tareas: "Para dar de alta una aplicación, …". Numera los pasos.
- Cuando una pantalla se comporte distinto según el perfil, usa secciones
  `## Perfil <nombre>`. Lo común a todos los perfiles va antes, sin sección.
- Sin jerga técnica: nada de API, endpoints, identificadores de
  especificaciones, nombres de componentes ni variables de entorno. Usa los
  textos que el usuario ve en pantalla, en **negrita**.
- No describas funciones que no estén implementadas ni comportamientos que
  no hayas comprobado.
- Inserta las capturas con texto alternativo descriptivo:
  `![Listado de expedientes con el filtro por estado](./img/expedientes-basico.png)`.
- **Respeta las ediciones del usuario.** Con un tag anterior, modifica solo
  los párrafos afectados por los cambios visibles; no reescribas ni
  reordenes lo demás. Las páginas nuevas sí se redactan completas.
- Si algo deja de existir, elimina su texto y sus capturas.
- Mantén `themeConfig.sidebar` de `docs/manual/.vitepress/config.mts` al
  día con las páginas.

Añade en `docs/manual/novedades.md`, encima de la entrada anterior:

```markdown
## v1.2.0 (20/10/2026)

- Ahora puedes exportar el listado de expedientes a Excel. [Ver cómo](./expedientes#exportar)
- La ficha del expediente muestra su historial de cambios.
```

Usa siempre el encabezado `## <versión> (<dd/mm/aaaa>)`: la skill lo busca
para saber desde qué versión hay manual. Si no hay cambios visibles, escribe
una sola línea: "Mejoras internas sin cambios para el usuario".

## 5. Capturas

1. Añade o ajusta en `capturas.config.ts` una entrada por captura que
   referencie el texto. El nombre del fichero es
   `<pantalla>-<perfil>`, en kebab-case. Rellena `esperar` con un texto
   visible que solo aparezca cuando la pantalla ya pintó sus datos; sin él
   se pueden capturar estados de carga.
2. Ejecuta `npm run manual:capturas`. Si falla, corrige la configuración, no
   la aplicación.
3. Abre con Read **todas** las capturas nuevas o cambiadas (si son muchas,
   al menos una de cada pantalla). Comprueba que sale la pantalla esperada,
   con el perfil correcto, sin elementos de desarrollo, sin errores ni
   estados de carga, que no se corta nada por el borde (si hay contenido
   cortado, ensancha `viewport` en el `playwright.config.ts` de las
   capturas) y que no aparecen datos que parezcan reales ni textos del
   navegador en otro idioma.
4. Borra de `docs/manual/img/` las imágenes que ya no se referencian.

**Anota las anomalías de la aplicación** que veas en las capturas (títulos
de cabecera que no corresponden a la pantalla, contenido que se sale de su
sitio, textos que contradicen la especificación). No las corrijas ni las
reproduzcas en el manual: descríbelas tal como funcionan y pásalas al
resumen del paso 7.

## 6. Comprobación

Ejecuta `npm run manual:build`: VitePress falla con enlaces rotos. Corrige
hasta que pase.

Comprueba que el estilo sigue siendo el de la aplicación: compara los
valores de `.vitepress/theme/custom.css` con sus tokens de origen (los
comentarios dicen cuáles). Si la aplicación los ha cambiado desde la versión
anterior, actualízalos y repite la comprobación visual del apartado
"Estilo de la aplicación".

## 7. Revisión del usuario

Detente y presenta:

- La versión que se va a liberar y, si la calculaste, por qué. En modo tag
  existente, que no se creará ningún tag.
- Las discrepancias entre especificaciones e interfaz que hayas encontrado y
  las anomalías de la aplicación anotadas en el paso 5.
- Las páginas creadas o modificadas y un resumen de cada cambio.
- La entrada de novedades.
- Cómo revisarlo: `npm run dev` y `/manual/` en el puerto de la aplicación
  (con Vite); si no, `npm run manual:dev` en `http://localhost:5174/manual/`.

Espera la respuesta. Si el usuario edita el texto o pide cambios, aplícalos.
Si afectan a las capturas o al índice, repite los pasos 5 y 6.

## 8. Commit y tag

Solo con la confirmación explícita del usuario:

1. Sigue la skill `commit` con los ficheros de `docs/manual/` y, la primera
   vez, `package.json`, `package-lock.json` y `.gitignore`. Mensaje:
   `docs: actualiza el manual de usuario para <versión>`.
2. Crea el tag anotado sobre ese commit:
   `git tag -a <versión> -m "Versión <versión>"`.
   En modo tag existente, no: termina en el commit.
3. Confirma con `git show --stat <versión>` que el tag apunta al commit del
   manual. En modo tag existente, confirma con `git log --oneline -1` que
   el commit del manual se ha creado.

No hagas push. Indica al usuario el comando para publicarlo
(`git push origin <versión>`, o solo `git push` en modo tag existente) y
recuerda que el build de la aplicación ya incluye el manual: al desplegarla,
queda en `https://<servidor>/manual/`.

## Pendiente: Laravel con Inertia

Sin implementar hasta probarlo en un proyecto real. El procedimiento está
probado con React y Vite consumiendo una API REST. Con Inertia cambia:

1. **Datos de las capturas.** No hay API que simular: los datos llegan en la
   respuesta de Laravel. Habrá que arrancar Laravel contra una SQLite propia
   de las capturas (`database/manual.sqlite`, con `--env=manual`) rellenada
   por un seeder de datos ficticios (`ManualSeeder`), y servirlo con
   `php artisan serve`. `migrate:fresh` solo puede ejecutarse contra esa
   base. El seeder es código del proyecto: pedir permiso antes de crearlo.
2. **Perfiles.** Con el modo SSO local de la plantilla (`SSO_MODE=local`),
   cada perfil se fija con `page.setExtraHTTPHeaders` y las cabeceras
   `users` y `profiles`. Ese modo solo se activa en el servidor de capturas.
3. **Salida.** Apache publica `public/`: el manual va en `public/manual/`,
   que hay que añadir a `.gitignore`. El `.htaccess` de Laravel sirve los
   ficheros existentes, así que `/manual/` no necesita configuración. Las
   rutas que choquen se comprueban con `php artisan route:list --path=manual`.
4. **Logo y favicon.** No apuntar `vite.publicDir` a `public/`: copiaría
   `index.php`, `.htaccess`, `build/` y el propio manual. Usar la subcarpeta
   de imágenes o copiar solo el logo.
5. **Requisitos extra.** PHP y dependencias de Composer instaladas, y que no
   exista `public/hot`: con él, Laravel sirve los assets desde el servidor de
   desarrollo de Vite y las capturas vuelven a fallar por tiempo. Si el kit
   trae SSR, las capturas funcionan sin su servidor.
