
## Inicializar el "fetched results controller" {#inicializar_frc}

Vamos a empezar con un *fetched results controller* "mínimo". Supondremos que estamos usando un *view controller* que hereda de `UITableViewController` (aunque no va a haber gran diferencia si no usamos esta clase).

Lo primero es crear el `NSFetchedResultsController`. Para ello necesitamos como mínimo dos cosas:

- Asociarle una *fetch request*, que devuelva los datos que queramos mostrar en la tabla.
- Que dicha *request* esté ordenada. Ya hemos visto que Core Data no asegura por defecto un orden determinado al obtener los resultados de una *fetch request*, pero las filas de la tabla sí tienen un orden definido, por lo que necesitamos que los resultados también lo tengan. O sea, necesitamos que la *request* use `NSSortDescriptor`.

Además podemos crear una *cache* para que sea más eficiente. Como veremos es muy sencillo y no requiere casi trabajo por nuestra parte. 

Continuaremos con el ejemplo de los usuarios, las conversaciones y los mensajes. Vamos a hacer por ejemplo una tabla que muestre los mensajes (entidad y clase `Mensaje`). Para simplificar el código, gestionaremos el `NSFetchedResultsController` en el *controller* de la pantalla con la tabla. Lo primero es definirnos una propiedad para almacenarlo, ya que lo usaremos en diversos métodos:

```swift
import UIKit
import CoreData

class MiController : UITableViewController {
  var frc : NSFetchedResultsController<Mensaje>! 

  ...
}
```

> En el ejemplo hemos usado un `UITableViewController`, pero nos serviría cualquier `ViewController`.

Ahora podemos inicializar el *fetched results controller* en el `viewDidLoad`

```swift
override func viewDidLoad() {
    super.viewDidLoad()

    let miDelegate = UIApplication.shared.delegate! as! AppDelegate
    let miContexto = miDelegate.persistentContainer.viewContext
    
    let consulta = NSFetchRequest<Mensaje>(entityName: "Mensaje")
    let sortDescriptors = [NSSortDescriptor(key:"fecha", ascending:false)]
    consulta.sortDescriptors = sortDescriptors
    self.frc = NSFetchedResultsController<Mensaje>(fetchRequest: consulta, managedObjectContext: miContexto, sectionNameKeyPath: nil, cacheName: "miCache")

    //ejecutamos el fetch
    try! self.frc.performFetch()
}
```

Nótese que al inicializador debemos pasarle cuatro parámetros:

- La *fetch request* para filtrar los datos, que además debe estar ordenada con `sortDescriptors`
- El contexto de persistencia
- Un sitio de donde sacar cómo se divide la tabla en secciones. Por el momento generamos una única sección por lo que ponemos esto a `nil`
- Una *cache* a usar. Aunque hablaremos luego de ella, es tan sencillo crearla que ya lo hemos hecho aquí. Basta con elegir un nombre que no usemos para otro *fetched results controller*.
 
Una vez inicializado el *controller* llamamos a `performFetch` para que se ejecute la consulta.

Para comprobar que funciona podemos imprimir provisionalmente los datos en la consola:

```swift
//Esto vendría también dentro del viewDidLoad, a continuación de lo anterior
if let resultados = frc.fetchedObjects {
    print("Hay \(resultados.count) mensajes")
    for mensaje in resultados {
        print (mensaje.texto!)
    }
}
```

Como puede verse, para ejecutar la *query* hay que llamar a `performFetch()`. Los resultados estarán accesibles en forma de array en `fetchedObjects`. No obstante esta no es la forma típica de obtener los resultados, para eso hubiéramos ejecutado el *fetch* directamente. En la siguiente sección vamos a "comunicar" el *fetched results controller* con la tabla para que sea ella la que le pida los datos conforme los vaya necesitando. 