## Comunicación entre contextos

En la sección anterior hemos visto un ejemplo que implicaba una operación costosa con objetos gestionados, pero esos objetos gestionados se "quedaban dentro" del contexto secundario. Las notas que se recuperaban con la *fetch request* no se usaban en la cola de operaciones principal, se manejaban solo dentro de la otra cola.

Supongamos ahora un caso distinto: una búsqueda muy costosa, que queremos hacer también en *background* para no bloquear mientras tanto la interfaz de usuario, pero cuyos resultados evidentemente queremos mostrar en pantalla, y posiblemente editar o borrar. ¿Qué problema tenemos aquí? que los resultados de la búsqueda son `NSManagedObjects` asociados a un contexto distinto al "principal", y las otras operaciones las estaríamos realizando en el contexto "principal". Con un `NSManagedObject` solo se puede operar desde el contexto al que pertenece. Nótese que todas las operaciones del ciclo de vida (`insertNewObject`, `fetch`, `save`, `delete`), siempre llevan como parámetro el contexto o directamente se ejecutan sobre el contexto. Así que no podemos simplemente pasarnos el objeto entre contextos. ¿Cómo podemos resolver esto?.

Una forma es **usando un identificador único que tienen todos los objetos gestionados**, que es accesible a través de la propiedad `objectID`. Es muy sencillo obtener un objeto a partir de su `ID` con el método `objectWithID` del contexto. Lo interesante es que el `ID` de un objeto gestionado es el mismo para todos los contextos. La idea entonces sería hacer una *fetch request* en el hilo secundario y "devolver" una lista de `ID`. Desde el contexto principal se "re-materializarían" los objetos gestionados a partir de su `ID`, pero ahora asociados al contexto "correcto".

Supongamos otro ejemplo distinto, en el que estaríamos sincronizando los datos con un servicio web, pero no solo enviando datos, sino también recibiendo, es decir, modificando objetos persistentes en *background*. Si los objetos se estuvieran visualizando en el hilo principal necesitaríamos actualizarlos. Por tanto tendríamos que hacer que el contexto principal se sincronizara con el secundario, no obtener una lista de resultados como en el caso de antes, sino ahora *refrescar* los datos. Una forma de hacer esto es gracias a las notificaciones que se generan cuando se guarda un objeto gestionado, y que ya comentamos. Afortunadamente, también se pueden "escuchar" las notificaciones que se emiten desde otro contexto de persistencia. Y también afortunadamente hay un método que "sincroniza" un objeto por nosotros, a partir de la notificación emitida por el objeto que se ha guardado: `mergeChanges(fromContextDidSave:)`

```swift

let miDelegate = UIApplication.shared.delegate as! AppDelegate
//El contexto principal, como hasta ahora
let miContexto = miDelegate.persistentContainer.viewContext
//Un contexto secundario
let contextoBg = miDelegate.persistentContainer.newBackgroundContext()
//El "notification center" de la aplicación
let nc = NotificationCenter.default
//Cuando el contextoBg emita una notificación de este tipo, ejecutamos el código
nc.addObserver(forName: .NSManagedObjectContextDidSave,
               object: contextoBg,
               queue: nil) {
     notificacion in
       miContexto.mergeChanges(fromContextDidSave: notificacion)
}
```

