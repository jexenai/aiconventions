import { nextTick, onMounted, watch } from 'vue'
import { useRoute } from 'vitepress'
import DefaultTheme from 'vitepress/theme'
import mediumZoom from 'medium-zoom'
import './custom.css'

// Las capturas se amplían al pulsarlas, a su tamaño original y sin perder definición.
export default {
  extends: DefaultTheme,
  setup() {
    const route = useRoute()
    const activarAmpliacion = () => {
      mediumZoom('.vp-doc img', { background: 'var(--vp-c-bg)', margin: 24 })
    }
    // Solo en el navegador: al generar el sitio no hay documento. VitePress navega sin recargar,
    // así que se vuelve a activar en cada cambio de página.
    onMounted(activarAmpliacion)
    watch(() => route.path, () => nextTick(activarAmpliacion))
  },
}
