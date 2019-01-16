## Ejercicios

En las plantillas de la sesión hay un proyecto llamado `PruebaContextosMultiples` que servirá como base para los ejercicios de la sesión. La aplicación solo tiene una pantalla con un listado de notas (no se pueden crear ni modificar). Hay dos operaciones costosas: exportar las notas y refrescar el listado con datos que vengan del servidor. En ambos casos el coste es simulado ya que ni se exportan de verdad ni se actualizan desde ningún servidor (ejem). El coste se simula "durmiendo" al hilo actual con la instrucción `usleep`.

Cuando la aplicación se carga, si no hay datos automáticamente inserta 500 objetos en la base de datos.


### Contextos múltiples para operaciones en *background* (2 puntos)

Pulsa sobre el botón de "exportar". Verás que la operación tarda 2-3 segundos. Si intentas hacer *scroll* de la pantalla durante este tiempo no podrás, ya que se queda bloqueada. Hay que solucionar esto.

verás que en el método `botonExportarPulsado` del *view controller* se llama a un método que (de modo simulado) exporta las notas y que es el "culpable" del bloqueo. El método admite como parámetro el contexto de persistencia. **Cambia el código para que esta operación se haga en un nuevo contexto en background**. Recuerda que las operaciones de interfaz (como mostrar el alert tras la exportación) deben hacerse en el *thread* principal.


### Comunicar contextos entre sí (3 puntos)

Si haces "pull to refresh" de la tabla, de modo simulado se conecta con el servidor para recibir los datos. La operación tarda unos segundos, durante los que se bloquea la interfaz, problema que tendrás que arreglar igual que en el apartado anterior.

Para que puedas ver que efectivamente se insertan datos, puedes pulsar primero el botón "Borrar todas", que elimina todos los datos

Cuando se hace "pull to refresh" se llama al método `handleRefresh` del *view controller*. En este se llama a `refrescarDatosDeServidor`, que supuestamente conecta con el servidor y inserta los nuevos datos en el contexto de persistencia. 

> Los datos se actualizan en pantalla automáticamente porque usamos un *fetched results controller* que los está escuchando, y puedes ver en el código que el *view controller* actúa como su `delegate`, actualizando la tabla si es necesario.

Tendrás que hacer dos cambios en el código:

- Igual que hiciste antes, la operación de `refrescarDatosDeServidor` se debería hacer en *background* para que no bloqueara la interfaz de usuario
- Una vez hecho lo anterior no se bloqueará la interfaz, pero los objetos se estarán recibiendo en otro contexto distinto al principal. Para enviar los datos al contexto principal y que aparezcan allí puedes usar notificaciones como has visto en la sesión de hoy
