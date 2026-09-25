---
name: e2e-testing
description: Pruebas de extremo a extremo con Playwright - organización, localizadores, esperas, sesión reutilizada, configuración, pruebas intermitentes y artefactos en GitLab CI.
disable-model-invocation: true
---

# Pruebas de extremo a extremo con Playwright

Solo para los flujos críticos (`.claude/rules/comun/pruebas.md`). En
Laravel con vistas React son las únicas pruebas que recorren backend y
vistas juntos; con Inertia, el contrato entre controlador y página ya lo
cubre `assertInertia`.

## Organización

```text
tests/e2e/
├── auth.setup.ts          # inicia sesión una vez y guarda el estado
├── pedidos/
│   └── crear-pedido.spec.ts
└── paginas/               # Page Objects, solo para pantallas reutilizadas
    └── PedidosPage.ts
playwright.config.ts
```

Un fichero por flujo de usuario, con nombres que describen el caso.

## Localizadores y esperas

```ts
test("crea un pedido y lo muestra en el listado", async ({ page }) => {
  await page.goto("/pedidos/nuevo");
  await page.getByLabel("Referencia").fill("PED-1");
  await page.getByRole("button", { name: "Guardar" }).click();

  await expect(page.getByRole("alert")).toHaveText(/pedido creado/i);
  await expect(page.getByRole("row", { name: /PED-1/ })).toBeVisible();
});
```

- Localizadores por rol, etiqueta y texto, en el mismo orden que Testing
  Library; `getByTestId` como último recurso.
- Las acciones y los `expect` de Playwright esperan solos. Nunca
  `page.waitForTimeout()`; si hace falta esperar una respuesta concreta,
  `page.waitForResponse()`.
- Comprueba lo que ve el usuario, no el estado interno ni la base de datos,
  salvo que el efecto no sea visible.

## Sesión y datos

- Inicia sesión una sola vez en un proyecto `setup` y reutiliza el estado
  con `storageState`; no repitas el inicio de sesión en cada prueba.
- Cada prueba crea sus propios datos, por la API o con un *seeder*
  específico, y no depende del orden ni de datos de otra prueba.
- Nunca contra producción ni con datos personales reales.

## Configuración mínima

```ts
export default defineConfig({
  testDir: "./tests/e2e",
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  use: {
    baseURL: process.env.BASE_URL ?? "http://localhost:8000",
    trace: "on-first-retry",
    screenshot: "only-on-failure",
  },
  projects: [
    { name: "setup", testMatch: /.*\.setup\.ts/ },
    { name: "chromium", use: { ...devices["Desktop Chrome"], storageState: "playwright/.auth/usuario.json" }, dependencies: ["setup"] },
  ],
  webServer: {
    command: "php artisan serve",   // en una SPA de React sola, el servidor de desarrollo o la vista previa
    url: "http://localhost:8000",
    reuseExistingServer: !process.env.CI,
  },
});
```

- En Laravel con vistas React, compila antes las vistas (`npm run build`) para probar lo
  que se despliega, y usa una base de datos de pruebas.
- Añade otros navegadores solo si el proyecto lo exige.
- `playwright/.auth/` va en `.gitignore`: contiene la sesión.

## Pruebas intermitentes

- Para confirmar que una prueba es intermitente:
  `npx playwright test crear-pedido --repeat-each=10`.
- Corrige la causa (espera fija, datos compartidos, orden entre pruebas).
  Si hay que apartarla temporalmente, `test.fixme()` con el motivo y la
  incidencia, nunca borrarla.
- Un reintento que pasa en CI es un aviso, no un éxito: revisa la traza.

## GitLab CI

```yaml
e2e:
  image: mcr.microsoft.com/playwright:<versión igual a la de package.json>
  script:
    - npm ci
    - npx playwright test
  artifacts:
    when: always
    paths: [playwright-report/, test-results/]
    expire_in: 7 days
```

Las trazas de `test-results/` se abren con `npx playwright show-trace`.
