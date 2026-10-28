import { fileURLToPath } from 'node:url'
import { test, type Page } from '@playwright/test'
import { capturas, ocultar, perfiles, prepararPagina } from './capturas.config.ts'

// Recorrido genérico: los datos de cada proyecto están en capturas.config.ts.

const IMAGENES = new URL('../img/', import.meta.url)

async function ocultarElementos(page: Page) {
  if (ocultar.length === 0) return
  await page.addStyleTag({ content: `${ocultar.join(', ')} { display: none !important; }` })
}

for (const captura of capturas) {
  test(`${captura.nombre}`, async ({ page }) => {
    const entrar = perfiles[captura.perfil]
    if (!entrar) throw new Error(`El perfil "${captura.perfil}" no está en capturas.config.ts`)

    await prepararPagina(page)
    await entrar(page)
    await page.goto(captura.ruta)
    await page.waitForLoadState('networkidle')
    if (captura.esperar) await page.getByText(captura.esperar).first().waitFor()
    await captura.preparar?.(page)
    // Después de preparar, por si ha navegado o abierto algo nuevo.
    await ocultarElementos(page)

    const opciones = {
      path: fileURLToPath(new URL(`${captura.nombre}.png`, IMAGENES)),
      animations: 'disabled',
      caret: 'hide',
    } as const
    if (captura.elemento) {
      await page.locator(captura.elemento).screenshot(opciones)
    } else {
      await page.screenshot({ ...opciones, fullPage: captura.pantallaCompleta ?? false })
    }
  })
}
