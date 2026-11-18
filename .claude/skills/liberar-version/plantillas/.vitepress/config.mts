import { defineConfig } from 'vitepress'

// Manual de usuario. Lo mantiene la skill liberar-version.
// Se publica con la aplicación: su build lo compila dentro de la carpeta que
// se despliega y queda en https://<servidor>/manual/. En local, con Vite, lo
// sirve `npm run dev` en /manual/ por el puerto de la aplicación; si no,
// `npm run manual:dev` en http://localhost:5174/manual/.
const RUTA = '/manual/'

export default defineConfig({
  lang: 'es-ES',
  title: 'Manual de usuario',
  description: 'Cómo usar la aplicación',
  base: RUTA,
  // Dentro de la carpeta que genera el build de la aplicación (en Vite, dist/).
  outDir: '../../dist/manual',
  // Logo y favicon de la aplicación sin copiarlos: apunta a su carpeta pública
  // (en Vite, `public/` de la raíz) y descomenta `logo` y `head`.
  // vite: { publicDir: '../../public' },
  // head: [['link', { rel: 'icon', href: `${RUTA}favicon.svg` }]],
  // capturas/ contiene la configuración de Playwright, no páginas.
  srcExclude: ['capturas/**'],
  themeConfig: {
    // Como en la cabecera de la aplicación: su logo (claro y oscuro) y su nombre.
    // logo: { light: '/logo-claro.svg', dark: '/logo-oscuro.svg', alt: '' },
    // siteTitle: '<nombre de la aplicación>',
    nav: [{ text: 'Novedades', link: '/novedades' }],
    // Una entrada por página del manual, en el orden de uso.
    sidebar: [
      {
        text: 'Manual',
        items: [
          { text: 'Introducción', link: '/' },
          { text: 'Novedades', link: '/novedades' },
        ],
      },
    ],
    search: {
      provider: 'local',
      options: {
        translations: {
          button: { buttonText: 'Buscar', buttonAriaLabel: 'Buscar' },
          modal: {
            displayDetails: 'Mostrar detalles',
            resetButtonTitle: 'Borrar la búsqueda',
            backButtonTitle: 'Cerrar la búsqueda',
            noResultsText: 'No hay resultados para',
            footer: { selectText: 'seleccionar', navigateText: 'moverse', closeText: 'cerrar' },
          },
        },
      },
    },
    outline: { level: [2, 3], label: 'En esta página' },
    docFooter: { prev: 'Anterior', next: 'Siguiente' },
    darkModeSwitchLabel: 'Apariencia',
    lightModeSwitchTitle: 'Cambiar a tema claro',
    darkModeSwitchTitle: 'Cambiar a tema oscuro',
    sidebarMenuLabel: 'Menú',
    returnToTopLabel: 'Volver arriba',
    notFound: {
      title: 'Página no encontrada',
      quote: 'La página que buscas no existe o ha cambiado de sitio.',
      linkLabel: 'Ir al inicio',
      linkText: 'Ir al inicio',
    },
  },
})
