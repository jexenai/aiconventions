import { fileURLToPath } from 'node:url'
import { defineConfig, devices } from '@playwright/test'
import { servidor } from './capturas.config.ts'

// Capturas del manual: npm run manual:capturas. Separado de los e2e para que
// `npm run test:e2e` no regenere imágenes.
export default defineConfig({
  testDir: '.',
  testMatch: 'capturar.spec.ts',
  fullyParallel: true,
  reporter: 'list',
  outputDir: '../../../test-results/manual',
  use: {
    ...devices['Desktop Chrome'],
    baseURL: servidor.url,
    // Tamaño, idioma y tema fijos para que las capturas no cambien entre equipos.
    viewport: { width: 1440, height: 900 },
    deviceScaleFactor: 1,
    locale: 'es-ES',
    timezoneId: 'Europe/Madrid',
    colorScheme: 'light',
    // Idioma de la interfaz del propio navegador (p. ej. el selector de ficheros).
    channel: 'chromium',
    launchOptions: { args: ['--lang=es-ES'] },
  },
  webServer: {
    command: servidor.comando,
    url: servidor.url,
    cwd: fileURLToPath(new URL('../../../', import.meta.url)),
    // Nunca el servidor de desarrollo: tiene el aspecto y la configuración de local.
    reuseExistingServer: false,
    // El build puede tardar más de lo que Playwright espera por defecto.
    timeout: 240_000,
    env: servidor.entorno,
  },
})
