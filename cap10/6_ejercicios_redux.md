## Ejercicios de arquitecturas iOS, parte III: Redux

En las plantillas de la sesión tenemos una aplicación que implementa una "lista de la compra" para apuntar cosas pendientes de comprar y que está desarrollada siguiendo el paradigma MVC. Queremos pasarla a Redux con la ayuda de ReSwift.

> IMPORTANTE: **Abre el `.xcworkspace`**, no el `.xcodeproj` como habitualmente. Tras abrirlo deberías ver dos proyectos: el principal `ListaCompra` y otro "secundario" `Pods` con las librerías adicionales (`ReSwift` en este caso). Haz un `build` del proyecto antes de empezar a trabajar con él, para que se compilen las dependencias.

En todos los archivos que uses la librería `ReSwift` necesitarás un 

```swift
import ReSwift
```

### El estado (1 punto)

Crea un *group* llamado `State` (`File > New group...`) para guardar el *struct* que implementa el estado. Por convenio en `ReSwift` se suele llamar `AppState`
  - Declara que es conforme al protocolo `StateType`
  - Añádele un campo llamado `lista` de tipo `ListaCompra`

### Las acciones (1 punto)

En el ejercicio únicamente implementaremos una acción para añadir un item a la lista.

Crea un *group* llamado `Actions` (`File > New group...`) para guardar un *struct* `AddItem` que representará esta acción
 
  - Declara que es conforme al protocolo `Action`
  - Añádele un campo de tipo `Item` para representar el item añadido 

### El *reducer* (1.5 puntos)

Crea un *group* llamado `Reducers` (`File > New group...`) para almacenar los *reducers*. Como es una aplicación muy sencilla podemos hacerlo todo en un único *reducer*. 

En el group `Reducers` crea un archivo `AppReducer` y en él define la función `appReducer(accion: Action, estado: AppState?) -> AppState`. Para implementarla puedes ayudarte de las transparencias.

### El `store` (0.5 puntos)

Típicamente se suele definir en el `AppDelegate` simplemente porque es accesible desde cualquier parte de la aplicación

```swift
let store = Store<AppState>(reducer: appReducer, state: nil)
```

### Suscribirse a los cambios de estado (1.5 puntos)

El `ListaViewController` es el *view controller* de la pantalla que muestra la lista de notas, y puede encargarse de recibir los cambios de estado.

- En la cabecera del `ListaViewController` indica que es conforme al protocolo `StoreSubscriber`. Quedará:

```swift
class ListaViewController: UITableViewController, StoreSubscriber {
```

- Al poner el protocolo la clase está "obligada" a:

  + Especificar el tipo del estado con `StoreSubscriberStateType` . Simplemente hay que poner en la clase `typealias StoreSubscriberStateType = AppState`
  + Implementar el método `newState(state:)` donde se reciben los cambios de estado. En este método tendrás que hacer

```swift
listaDataSource.setLista(state.lista)
self.tableView.reloadData()
```

> CAMBIOS DEL CODIGO ANTERIOR: en el método `unwind` sobra todo el código que era el que antes recibía el nuevo item creado, ahora puedes dejarlo vacío (pero no lo elimines, si no no se podrá volver a esta pantalla desde la de edición del item)

# Despachar las acciones (1.5 puntos)

Todavía nos falta disparar todo el proceso, es decir, despachar la acción de "añadir item". Esto tendrás que hacerlo desde la pantalla de editar item, controlada por el `NuevoItemViewController`. En el método `shouldPerformSegue`, dentro del `if identifier=="guardar"` añade código que despache la acción al *store*. 

> CAMBIOS DEL CODIGO ANTERIOR: elimina la propiedad `nuevoItem` del controller ,ya no es necesaria, antes era el objeto que tomaba la pantalla principal para añadirlo a la lista, pero ahora esta información no se la pasa este view controller sino el *store*.

Una vez hecho todo esto la parte de añadir