import type { Page } from '@playwright/test'

/**
 * Datos del proyecto para las capturas del manual. Los completa la skill
 * liberar-version a partir del soporte de los e2e; el recorrido genérico
 * está en capturar.spec.ts.
 */

export interface Captura {
  /** Fichero en docs/manual/img/, sin extensión: `<pantalla>-<perfil>`. */
  nombre: string
  /** Clave de `perfiles` con la que se entra. */
  perfil: string
  /** Ruta de la aplicación que se abre. */
  ruta: string
  /** Texto que debe verse antes de capturar: la pantalla ya ha pintado los datos, no un estado de carga. */
  esperar?: string
  /** Acciones tras cargar y antes de capturar: abrir un diálogo, rellenar un campo, esperar un texto... */
  preparar?: (page: Page) => Promise<void>
  /** Selector de un elemento: se captura solo ese elemento. */
  elemento?: string
  /** Captura la página entera y no solo la parte visible. */
  pantallaCompleta?: boolean
}

/**
 * Servidor propio para las capturas, con el aspecto que verá el usuario final.
 * `comando` compila y sirve el resultado, no el servidor de desarrollo: este
 * compila al vuelo y las capturas en paralelo agotan el tiempo. Ejemplo con Vite:
 * `npx vite build --outDir node_modules/.manual/dist --emptyOutDir && npx vite preview --outDir node_modules/.manual/dist --port 5175 --strictPort`
 */
export const servidor = {
  comando: 'npm run build && npm run preview -- --port 5175 --strictPort',
  url: 'http://localhost:5175',
  /**
   * Variables de entorno del servidor, p. ej. las que quitan indicadores de entorno.
   * Comprueba que la aplicación sigue siendo utilizable con ellas.
   */
  entorno: {} as Record<string, string>,
}

/** Se ejecuta antes de cada captura: simular la API, fijar la fecha... */
export async function prepararPagina(_page: Page): Promise<void> {}

/** Cómo entra cada perfil antes de abrir la ruta. */
export const perfiles: Record<string, (page: Page) => Promise<void>> = {}

/** Selectores de elementos que el usuario final no ve: se ocultan al capturar. */
export const ocultar: string[] = []

export const capturas: Captura[] = []
