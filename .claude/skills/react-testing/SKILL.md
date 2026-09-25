---
name: react-testing
description: Pruebas de componentes y hooks de React con React Testing Library, Vitest o Jest y MSW - configuración, proveedores, red simulada, asincronía, accesibilidad con axe y cuándo pasar a Playwright. Úsala al escribir o corregir pruebas de componentes, hooks o páginas React.
disable-model-invocation: true
---

# Pruebas en React

Complementa `.claude/rules/react/pruebas.md`, que fija herramientas,
prioridad de consultas, `userEvent` y la regla de no usar *snapshots*. Con
OpenSpec, el orden de pruebas primero lo fija `openspec/config.yaml`.

## Red simulada con MSW

```ts
// src/test/servidor.ts
import { setupServer } from "msw/node";
import { http, HttpResponse } from "msw";

export const servidor = setupServer(
  http.get("/api/pedidos", () => HttpResponse.json({ data: [] })),
);

// src/test/setup.ts (setupFiles de Vitest)
beforeAll(() => servidor.listen({ onUnhandledRequest: "error" }));
afterEach(() => servidor.resetHandlers());
afterAll(() => servidor.close());
```

- Cada prueba cambia solo lo que necesita con `servidor.use(...)`: error
  500, lista vacía, respuesta lenta.

## Proveedores

```tsx
// src/test/render.tsx
export function renderConProveedores(ui: React.ReactElement, { ruta = "/" } = {}) {
  const queryClient = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  return render(
    <QueryClientProvider client={queryClient}>
      <MemoryRouter initialEntries={[ruta]}>{ui}</MemoryRouter>
    </QueryClientProvider>,
  );
}
```

- Los mismos proveedores que en producción; no simules los *hooks* de las
  librerías.

## Ejemplo completo

```tsx
test("muestra un error si falla el guardado", async () => {
  servidor.use(http.post("/api/pedidos", () => new HttpResponse(null, { status: 500 })));
  const user = userEvent.setup();
  renderConProveedores(<FormularioPedido />);

  await user.type(screen.getByLabelText("Referencia"), "PED-1");
  await user.click(screen.getByRole("button", { name: /guardar/i }));

  expect(await screen.findByRole("alert")).toHaveTextContent(/no se ha podido guardar/i);
});
```

- `userEvent.setup()` una vez por prueba y cada acción con `await`.
- `queryBy*` para comprobar que algo **no** está;
  `waitForElementToBeRemoved` para lo que desaparece.
- Los avisos de `act()` indican un fallo real (actualización tras desmontar,
  asincronía sin esperar): corrígelos, no los silencies.

## *Hooks* con contexto

```tsx
const queryClient = new QueryClient({ defaultOptions: { queries: { retry: false } } });
const wrapper = ({ children }: { children: React.ReactNode }) => (
  <QueryClientProvider client={queryClient}>{children}</QueryClientProvider>
);
const { result } = renderHook(() => usePedido("1"), { wrapper });
await waitFor(() => expect(result.current.isSuccess).toBe(true));
```

Crea el cliente fuera del `wrapper`: dentro, se recrea en cada render.

## Accesibilidad con axe

```tsx
import { axe } from "vitest-axe"; // o jest-axe

test("el formulario no tiene infracciones de accesibilidad", async () => {
  const { container } = renderConProveedores(<FormularioPedido />);
  expect(await axe(container)).toHaveNoViolations();
});
```

Detecta etiquetas y `alt` que faltan, ARIA incorrecto y orden de
encabezados. No mide el contraste real: JSDOM no aplica CSS.

## Cuándo pasar a Playwright

JSDOM no tiene maquetación real, *scroll*, arrastrar y soltar, portapapeles,
descargas ni navegación entre páginas. Para eso, o para un flujo completo de
usuario, usa Playwright.

## Comandos

Usa los de `development.md`. Una sola prueba:
`npx vitest run src/pedidos/FormularioPedido.test.tsx`.
