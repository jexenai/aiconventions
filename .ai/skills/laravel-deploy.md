# Comprobar un despliegue de Laravel

Utiliza este procedimiento antes de desplegar un proyecto Laravel, cuando el
usuario lo pida o cuando la sección "Entrega" de
`.ai/project/development.md` lo indique. El resultado es un informe de si el
proyecto está listo para desplegarse; no despliega nada.

## Límites

- No despliegues, no publiques ni ejecutes migraciones reales: solo
  `--pretend` y comandos de consulta.
- No cambies la configuración de ningún entorno ni el `.env`.
- Si un comando necesita una base de datos o un servicio que no está
  disponible, dilo en el informe en lugar de simularlo.

## Comprobaciones

1. `composer validate`: el manifiesto y el fichero de bloqueo son coherentes.
2. `php artisan migrate:status` y `php artisan migrate --pretend`: revisa las
   migraciones pendientes, señala las destructivas (borrar tablas o columnas,
   cambiar tipos) y comprueba que tienen `down()`.
3. `php artisan config:cache`, `route:cache` y `view:cache` terminan sin
   errores. Después, limpia las cachés generadas si el entorno es local.
4. Si hay colas o tareas programadas: `php artisan schedule:list` y
   `php artisan queue:failed`.
5. Si las vistas usan Vite: `npm run build` termina sin errores.

## Informe

Una tabla con una fila por comprobación, con el comando ejecutado, el
resultado (`Correcto`, `Con avisos`, `Falla` o `No ejecutado`) y el motivo.
Termina indicando si el proyecto está listo para desplegar y qué lo impide.
