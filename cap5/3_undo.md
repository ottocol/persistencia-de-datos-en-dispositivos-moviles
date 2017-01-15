## Deshacer y rehacer

Core Data nos ofrece la posibilidad de deshacer y rehacer las operaciones con objetos gestionados. Así por ejemplo aunque hayamos borrado un objeto con `delete`, por ejemplo, podemos deshacer de modo muy sencillo el borrado. De esto se encarga el *undo manager*, un objeto de la clase `UndoManager`. En principio es algo tan simple como llamar a los métodos `undo` y `redo` de este objeto. El *undo manager* es accesible a través de la propiedad `undoManager` del contexto

```swift
//suponiendo que hayamos obtenido el contexto
let miContexto = ...
//deshacemos la última operación realizada
miContexto.undoManager?.undo()
```

De hecho, podríamos simplificar todavía más el código llamando a `miContexto.undo()`, que lo que hace en realidad es llamar al *undo manager*

En iOS el *undo manager* no está activado por defecto, de modo que inicialmente es `nil`. De ahí que al acceder a la propiedad `undoManager` obtengamos un opcional. Justo despúes de crear el contexto podemos instanciar un `UndoManager` y pasárselo a éste. Si estamos usando el código que genera Xcode 8 para iOS10 al marcar la casilla "use core data", el lugar apropiado es tras crear el *persistent container*, justo antes del `return`:

```swift
container.viewContext.undoManager = UndoManager()
return container
```

Si generamos código para iOS<10, el lugar apropiado es donde se crea el contexto de persistencia.

Una vez activado el *undo manager*, cuando llamamos a `undo` por defecto se deshacen las operaciones efectuadas en la última ejecución de código por parte de la aplicación (es decir, desde que el sistema “cede el control” a la aplicación - por ejemplo en un manejador de evento - hasta que la aplicación vuelve a “pasarle el testigo” al sistema). Así por ejemplo si al pulsar un botón del interfaz se ejecuta código que borra una lista de objetos, al  deshacer se podría recuperar la lista entera, pero no cada objeto individual. No obstante, podemos llamar a `beginUndoGrouping` y `endUndoGrouping` para gestionar nosotros mismos la “atomicidad” del `undo`.

Por defecto con el *undo manager* podemos deshacer un número ilimitado de operaciones, lo que puede ser problemático con la memoria, ya que hay que “llevar la pista” de todos los cambios que se van haciendo. Para fijar el número máximo de operaciones que se puedan deshacer se puede cambiar el valor de la propiedad `levelsOfUndo:`.

